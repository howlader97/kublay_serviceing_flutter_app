import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/chat_model.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';

class ChatSocketService {
  ChatSocketService._privateConstructor();
  static final ChatSocketService _instance =
      ChatSocketService._privateConstructor();
  static ChatSocketService get instance => _instance;

  io.Socket? _socket;
  bool _isConnecting = false;
  String? _currentUserId;

  final StreamController<ChatMessageModel> _messageStreamController =
      StreamController<ChatMessageModel>.broadcast();
  final StreamController<dynamic> _rawEventStreamController =
      StreamController<dynamic>.broadcast();

  Stream<ChatMessageModel> get onMessageReceived =>
      _messageStreamController.stream;
  Stream<dynamic> get onRawEvent => _rawEventStreamController.stream;

  bool get isConnected => _socket?.connected == true;

  Future<void> initSocket() async {
    if (isConnected || _isConnecting) return;
    await _connect();
  }

  Future<void> _connect() async {
    try {
      if (isConnected || _isConnecting) return;
      _isConnecting = true;

      final token = await StorageServices.instance.getToken();
      _currentUserId = await StorageServices.instance.getUserId();

      appLog("ChatSocket: Connecting to ${AppApiUrl.socket} with userId: $_currentUserId");

      final authPayload = <String, dynamic>{
        if (token.isNotEmpty) 'token': token,
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        if (token.isNotEmpty) 'bearer': token,
      };

      if (_socket != null) {
        _socket?.disconnect();
        _socket?.dispose();
        _socket = null;
      }

      _socket = io.io(
        AppApiUrl.socket,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(1000)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setExtraHeaders({
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            })
            .setQuery({
              if (token.isNotEmpty) 'token': token,
              if (_currentUserId != null && _currentUserId!.isNotEmpty)
                'userId': _currentUserId,
            })
            .setAuth(authPayload)
            .build(),
      );

      _socket?.onConnect((_) async {
        _isConnecting = false;
        appLog("ChatSocket: Successfully CONNECTED! Socket ID: ${_socket?.id}");

        if (_currentUserId == null || _currentUserId!.isEmpty) {
          _currentUserId = await StorageServices.instance.getUserId();
        }

        _registerUserRooms();
        _setupEventListeners();
      });

      _socket?.onConnectError((data) {
        _isConnecting = false;
        errorLog("ChatSocket: Connect Error", data);
      });

      _socket?.onError((data) {
        _isConnecting = false;
        errorLog("ChatSocket: General Error", data);
      });

      _socket?.onDisconnect((reason) {
        _isConnecting = false;
        appLog("ChatSocket: Disconnected: $reason");
      });

      _socket?.onReconnect((attempt) {
        appLog("ChatSocket: Reconnected on attempt $attempt");
        _registerUserRooms();
        _setupEventListeners();
      });

      _socket?.connect();
    } catch (e, st) {
      _isConnecting = false;
      errorLog("ChatSocket: _connect exception $e", st);
    }
  }

  void _registerUserRooms() {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      appLog("ChatSocket: Registering room for userId: $_currentUserId");
      _socket?.emit('join', _currentUserId);
      _socket?.emit('join_user', _currentUserId);
      _socket?.emit('join_room', _currentUserId);
      _socket?.emit('setup', _currentUserId);
      _socket?.emit('register', _currentUserId);
      _socket?.emit('user_connected', _currentUserId);
      _socket?.emit('identify', {'userId': _currentUserId});
    }
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    // 1. Wildcard onAny listener to capture ALL events from the server
    _socket?.onAny((event, data) {
      appLog("ChatSocket onAny [Event: $event] Data: $data");
      _rawEventStreamController.add({'event': event, 'data': data});
      _tryParseAndBroadcastMessage(data);
    });

    // 2. Explicit standard chat events
    final standardEvents = [
      'new_message',
      'receive_message',
      'message',
      'chat_message',
      'new_chat_message',
      'receive-message',
      'send_message',
      'get_message',
      'message_received',
      'chat',
      if (_currentUserId != null && _currentUserId!.isNotEmpty) ...[
        'new_message::$_currentUserId',
        'receive_message::$_currentUserId',
        'message::$_currentUserId',
        'chat::$_currentUserId',
        'get_message::$_currentUserId',
      ],
    ];

    for (final event in standardEvents) {
      _socket?.off(event);
      _socket?.on(event, (data) {
        appLog("ChatSocket Standard Event [$event]: $data");
        _tryParseAndBroadcastMessage(data);
      });
    }
  }

  void joinConversation(String partnerId) {
    if (isConnected && partnerId.isNotEmpty) {
      _socket?.emit('join_conversation', partnerId);
      _socket?.emit('join_chat', partnerId);
    }
  }

  void leaveConversation(String partnerId) {
    if (isConnected && partnerId.isNotEmpty) {
      _socket?.emit('leave_conversation', partnerId);
      _socket?.emit('leave_chat', partnerId);
    }
  }

  void _tryParseAndBroadcastMessage(dynamic rawData) {
    try {
      if (rawData == null) return;

      Map<String, dynamic>? msgMap;
      if (rawData is Map<String, dynamic>) {
        if (rawData['data'] is Map<String, dynamic>) {
          msgMap = rawData['data'] as Map<String, dynamic>;
        } else if (rawData['message'] is Map<String, dynamic>) {
          msgMap = rawData['message'] as Map<String, dynamic>;
        } else if (rawData['payload'] is Map<String, dynamic>) {
          msgMap = rawData['payload'] as Map<String, dynamic>;
        } else {
          msgMap = rawData;
        }
      }

      if (msgMap != null) {
        // Verify it contains sender/receiver or message text
        final hasSender = msgMap.containsKey('senderId') ||
            msgMap.containsKey('sender_id') ||
            msgMap.containsKey('sender');
        final hasReceiver = msgMap.containsKey('receiverId') ||
            msgMap.containsKey('receiver_id') ||
            msgMap.containsKey('receiver');
        final hasMessage = msgMap.containsKey('message') ||
            msgMap.containsKey('text') ||
            msgMap.containsKey('fileUrl');

        if ((hasSender || hasReceiver) && hasMessage) {
          final chatMsg = ChatMessageModel.fromJson(
            msgMap,
            currentUserId: _currentUserId,
          );
          if (chatMsg.message.isNotEmpty || chatMsg.fileUrl.isNotEmpty) {
            appLog("ChatSocket: Broadcasting ChatMessageModel -> ID: ${chatMsg.id}, text: ${chatMsg.message}");
            _messageStreamController.add(chatMsg);
          }
        }
      }
    } catch (e) {
      errorLog("ChatSocket: _tryParseAndBroadcastMessage error", e);
    }
  }

  void emit(String event, dynamic data) {
    try {
      if (isConnected) {
        _socket?.emit(event, data);
        appLog("ChatSocket: Emitted [$event]: $data");
      } else {
        initSocket().then((_) {
          _socket?.emit(event, data);
        });
      }
    } catch (e) {
      errorLog("ChatSocket: emit error ($event)", e);
    }
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnecting = false;
  }
}
