import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RiderSocketService {
  // Singleton
  static final RiderSocketService _instance = RiderSocketService._internal();
  factory RiderSocketService() => _instance;
  RiderSocketService._internal();

  IO.Socket? socket;
  var token = ''.obs;
  var isConnected = false.obs;

  /// Load token from local storage
  Future<void> loadToken() async {
    String accessToken = await SharedPreferencesHelper.getAccessToken() ?? '';
    token.value = accessToken;
    if (kDebugMode) {
      debugPrint(
        "📌 Rider Socket Token Loaded: ${token.value.isNotEmpty ? 'Yes' : 'No'}",
      );
    }
  }

  // final String baseUrl = 'http://10.10.20.130:3000/api/v1/messages';

  final String baseUrl = '${ApiEndPoint.baseUrl}/messages';

  /// CONNECT SOCKET
  void connect({required String? userId}) {
    if (token.value.isEmpty) {
      debugPrint("⚠️ Rider token not loaded yet.");
      return;
    }

    if (socket != null && socket!.connected) {
      debugPrint("✅ Rider socket already connected");
      return;
    }

    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'forceNew': true,
      // 'extraHeaders': {'Cookie': token.value},
      'auth': {'token': token.value}, //setAuth({'token': token})
      'reconnection': true,
      'reconnectionDelayMax': 5000,
      'pingInterval': 25000,
      'pingTimeout': 60000,
    });

    socket?.connect();

    // ✅ Connected
    socket?.onConnect((_) {
      isConnected.value = true;
      debugPrint('✅ Rider socket connected');
      if (userId != null) {
        emit('register', {'userId': userId, 'role': 'rider'});
        debugPrint('📝 Rider registered with userId: $userId');
      }
    });

    // ❌ Disconnected
    socket?.onDisconnect((_) {
      isConnected.value = false;
      debugPrint('❌ Rider socket disconnected');
    });

    // ⚠ Errors
    socket?.onConnectError(
      (e) => debugPrint('⚠️ Rider socket connect error: $e'),
    );
    socket?.onError((e) => debugPrint('⚠️ Rider socket error: $e'));

    // Error events from server
    socket?.on('error', (data) {
      debugPrint('🚨 Rider socket error event: $data');
    });

    socket?.on('message_error', (data) {
      debugPrint('🚨 Rider message error: $data');
    });

    // 🔁 Reconnect
    socket?.onReconnectAttempt(
      (attempt) => debugPrint('🔄 Rider reconnect attempt #$attempt'),
    );
    socket?.onReconnect((_) {
      debugPrint('🔁 Rider socket reconnected');
      if (userId != null) {
        emit('register', {'userId': userId, 'role': 'rider'});
      }
    });
  }

  /// GENERIC EMIT
  void emit(String event, dynamic data, {Function(dynamic)? ack}) {
    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ Rider socket not connected. Cannot emit "$event"');
      return;
    }

    if (ack != null) {
      socket?.emitWithAck(event, data, ack: ack);
      debugPrint('📤 Rider event----------- "$event" sent with ack: $data');
    } else {
      socket?.emit(event, data);
      debugPrint('📤 Rider event********* "$event" sent: $data');
    }
  }

  /// GENERIC LISTENER
  void on(String event, Function(dynamic) callback) {
    socket?.on(event, (data) {
      debugPrint(
        '📩 Rider event 000000000000 "$event" received0000000000: $data',
      );
      callback(data);
    });
  }

  /// Remove a listener
  void off(String event) {
    socket?.off(event);
    debugPrint('🔇 Rider listener "$event" removed');
  }

  /// Mark conversation messages as read
  void markAsRead(String conversationId) {
    if (conversationId.isEmpty) return;
    debugPrint('📖 Rider emitting mark_as_read for conversation: $conversationId');
    emit('mark_as_read', {'conversationId': conversationId}, ack: (response) {
      debugPrint('✅ Rider mark_as_read ack: $response');
    });
  }

  /// DISCONNECT SOCKET
  void dispose() {
    socket?.dispose();
    socket = null;
    isConnected.value = false;
    debugPrint('🔌 Rider socket disposed');
  }
}
