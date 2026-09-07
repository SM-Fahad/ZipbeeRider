import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:flutter/rendering.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RiderCompetitionSocketService {
  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// Connect to namespace `/raider` with auth token
  void connect({
    required String token,
  }) {
    
    final url = '${ApiEndPoint.socketUrl}/raider'; // backend uses /raider in example
    debugPrint('Connecting to socket at: $url with token: $token');

    _socket?.dispose();
    _socket = IO.io(
      url,
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

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ---------- listen helpers ----------
  void on(String event, Function(dynamic data) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void onAny(void Function(String event, dynamic data) handler) {
    _socket?.onAny((event, data) => handler(event, data));
  }

  // ---------- emit helpers ----------
  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  /// Join competition (CHANGE event name if backend differs)
  void joinCompetition(int orderId) {
    emit('rider:join_competition', {'orderId': orderId});
    debugPrint("Joined competition: $orderId");
  }

  /// Optional: cancel competition (only if backend supports)
  void cancelCompetition(int orderId) {
    emit('rider:competition_cancel', {'orderId': orderId});
  }
}

