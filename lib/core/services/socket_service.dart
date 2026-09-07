import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;
  final logger = Logger();
  bool isConnected = false;

  final Map<String, List<Function(dynamic)>> _listeners = {};

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  /// Initialize socket connection
  /// [serverUrl] - Backend server URL (e.g., 'https://api.zipbee.sg')
  /// [token] - Authentication token
  Future<void> connect(String serverUrl, String token) async {
    debugPrint('Connecting to socket: $serverUrl');
    debugPrint('Using token: $token');
    try {
      // Namespace is included in the URL for socket.io
      final socketUrl = '$serverUrl/raider';

      socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setPath('/socket.io/')
            .setAuth({'token': token})
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(10)
            .enableForceNew()
            .build(),
      );

      _attachStoredListeners();

      socket?.onConnect((_) {
        logger.i('✅ Socket connected');
        isConnected = true;
        _attachStoredListeners();
      });

      socket?.onDisconnect((_) {
        logger.i('❌ Socket disconnected');
        isConnected = false;
      });

      socket?.onConnectError((data) {
        logger.e('❌ Socket connection error: $data');
        isConnected = false;
      });

      socket?.onError((data) {
        logger.e('❌ Socket error: $data');
      });

      socket?.onAny((event, data) {
        debugPrint('📡 [SOCKET EVENT INCOMING] $event : $data');
      });

      socket?.connect();
      logger.i('Socket connection attempt started');
    } catch (e) {
      logger.e('❌ Error connecting to socket: $e');
      isConnected = false;
    }
  }

  void _attachStoredListeners() {
    if (socket == null) return;
    _listeners.forEach((event, callbacks) {
      for (final cb in callbacks) {
        socket?.off(event, cb);
        socket?.on(event, cb);
      }
    });
  }

  /// Send location to backend
  void sendLocation({
    required double lat,
    required double lng,
    double? heading,
  }) {
    if (socket != null && socket!.connected && isConnected) {
      try {
        socket!.emit('rider:location', {
          'lat': lat,
          'lng': lng,
          if (heading != null) 'heading': heading,
        });
        logger.i('Location sent: lat=$lat, lng=$lng, heading=$heading');
      } catch (e) {
        logger.e('Error sending location: $e');
      }
    } else {
      logger.w('Socket not connected, location not sent');
    }
  }

  /// Disconnect socket
  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
      isConnected = false;
      logger.i('Socket disconnected');
    }
  }

  void emit(String event, dynamic data) {
    debugPrint('📤 [SOCKET EMIT] $event : $data');
    socket?.emit(event, data);
  }

  void onAny(void Function(String event, dynamic data) handler) {
    socket?.onAny((event, data) => handler(event, data));
  }

  /// Listen to specific events
  void on(String event, Function(dynamic) callback) {
    final list = _listeners.putIfAbsent(event, () => []);
    if (!list.contains(callback)) {
      list.add(callback);
    }
    if (socket != null) {
      socket!.on(event, callback);
    }
  }

  void joinCompetition(int orderId) {
    emit('rider:join_competition', {'orderId': orderId});
    //debugPrint("Joined competition: $orderId");
  }

  /// Off listener
  void off(String event) {
    _listeners.remove(event);
    if (socket != null) {
      socket!.off(event);
    }
  }
}
