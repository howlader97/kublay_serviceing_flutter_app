import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class AppSocketAllOperation {
  AppSocketAllOperation._privateConstructor();
  static final AppSocketAllOperation _instance = AppSocketAllOperation._privateConstructor();
  static AppSocketAllOperation get instance => _instance;

  io.Socket? appRootSocket;
  bool _isConnecting = false;
  final Map<String, Set<void Function(dynamic)>> _eventHandlers = {};

  bool get isConnected => appRootSocket?.connected == true;

  Future<void> initializeSocket() async {
    if (appRootSocket != null && (isConnected || _isConnecting)) return;
    await _connectSocketToServer();
  }

  void readEvent({required String event, required void Function(dynamic) handler}) {
    try {
      _eventHandlers.putIfAbsent(event, () => <void Function(dynamic)>{}).add(handler);
      if (isConnected) {
        _ensureNativeListener(event);
      } else {
        initializeSocket();
      }
    } catch (e, stackTrace) {
      errorLog("readEvent ($event) $e", stackTrace);
    }
  }

  void removeEventListener({required String event, required void Function(dynamic) handler}) {
    try {
      if (_eventHandlers.containsKey(event)) {
        _eventHandlers[event]?.remove(handler);
        if (_eventHandlers[event]?.isEmpty == true) {
          _eventHandlers.remove(event);
          appRootSocket?.off(event);
        }
      }
    } catch (e, stackTrace) {
      errorLog("removeEventListener ($event) $e", stackTrace);
    }
  }

  void _ensureNativeListener(String event) {
    if (appRootSocket == null) return;
    appRootSocket?.off(event);
    appRootSocket?.on(event, (data) {
      appLog("Socket [Event: $event] Data: $data");
      final handlers = _eventHandlers[event];
      if (handlers != null) {
        for (final handler in List<void Function(dynamic)>.from(handlers)) {
          try {
            handler(data);
          } catch (e, st) {
            errorLog("Handler error for event $event: $e", st);
          }
        }
      }
    });
  }

  void emitEvent(String event, dynamic data) {
    try {
      if (isConnected) {
        appRootSocket?.emit(event, data);
        appLog("Socket Emitted [$event]: $data");
      } else {
        initializeSocket().then((_) {
          _onceConnected(() {
            appRootSocket?.emit(event, data);
            appLog("Socket Emitted after connect [$event]: $data");
          });
        });
      }
    } catch (e, stackTrace) {
      errorLog("emitEvent ($event) $e", stackTrace);
    }
  }

  void _onceConnected(void Function() callback) {
    if (isConnected) {
      callback();
      return;
    }

    void listener(dynamic _) {
      try {
        callback();
        appRootSocket?.off('connect', listener);
      } catch (e) {
        errorLog("_onceConnected listener", e);
      }
    }

    appRootSocket?.on('connect', listener);
  }

  Future<void> _connectSocketToServer() async {
    try {
      if (isConnected || _isConnecting) return;
      _isConnecting = true;
      appLog("Attempting to connect socket to ${AppApiUrl.socket}...");

      final token = await StorageServices.instance.getToken();
      final authPayload = <String, dynamic>{
        if (token.isNotEmpty) 'token': token,
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      if (appRootSocket != null) {
        appRootSocket?.disconnect();
        appRootSocket?.dispose();
        appRootSocket = null;
      }

      appRootSocket = io.io(
        AppApiUrl.socket,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(100)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setExtraHeaders({
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            })
            .setQuery({
              if (token.isNotEmpty) 'token': token,
            })
            .setAuth(authPayload)
            .build(),
      );

      appRootSocket?.onConnect((_) {
        _isConnecting = false;
        appLog("Socket successfully connected! Socket ID: ${appRootSocket?.id}");

        for (final event in _eventHandlers.keys) {
          _ensureNativeListener(event);
        }
      });

      appRootSocket?.onDisconnect((reason) {
        _isConnecting = false;
        appLog("Socket disconnected: $reason");
      });

      appRootSocket?.onConnectError((data) {
        _isConnecting = false;
        errorLog("Socket Connect Error", data);
      });

      appRootSocket?.onError((data) {
        _isConnecting = false;
        errorLog("Socket General Error", data);
      });

      appRootSocket?.onReconnect((attempt) {
        appLog("Socket reconnected on attempt: $attempt");
        for (final event in _eventHandlers.keys) {
          _ensureNativeListener(event);
        }
      });

      appRootSocket?.connect();
    } catch (e, stackTrace) {
      _isConnecting = false;
      errorLog("_connectSocketToServer $e", stackTrace);
    }
  }

  void reconnect() {
    _isConnecting = false;
    _connectSocketToServer();
  }

  void dispose() {
    if (appRootSocket != null) {
      appRootSocket?.disconnect();
      appRootSocket?.dispose();
      appRootSocket = null;
    }
    _eventHandlers.clear();
    _isConnecting = false;
  }
}
