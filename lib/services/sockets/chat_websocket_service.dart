import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final chatWebsocketProvider = Provider<ChatWebsocketService>((ref) {
  final service = ChatWebsocketService();
  ref.onDispose(() {
    service.disconnect();
  });
  return service;
});

class ChatWebsocketService {
  WebSocketChannel? _channel;
  Stream<dynamic>? _broadcastStream;

  // Stream to listen to incoming chat events/messages globally
  Stream<dynamic>? get stream => _broadcastStream;

  Future<void> connect() async {
    try {
      if (_channel != null) {
        return; // Already connected
      }

      String token = await StorageServices.instance.getToken();
      if (token.isEmpty) {
        errorLog("Chat Websocket", "Cannot connect without token");
        return;
      }

      final wsUrl = Uri.parse('ws://api.nexprimeapp.com/chat/ws/$token');

      _channel = WebSocketChannel.connect(wsUrl);
      _broadcastStream = _channel!.stream.asBroadcastStream();
      appLog("WebSocket connected to $wsUrl");

    } catch (e) {
      errorLog('WebSocket connection error', e);
    }
  }

  void sendMessage(String jsonMessage) {
    if (_channel != null) {
      _channel!.sink.add(jsonMessage);
      appLog("WebSocket Sent: $jsonMessage");
    } else {
      errorLog("Chat Websocket", "Cannot send message. Channel is null.");
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      _broadcastStream = null;
      appLog("WebSocket disconnected");
    }
  }
}
