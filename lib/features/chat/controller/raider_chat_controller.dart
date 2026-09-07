import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/chat/models/message_model.dart';
import 'package:ZipBee_Driver/features/chat/service/history.dart';
import 'package:ZipBee_Driver/features/chat/socket_service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class RiderMessageController extends GetxController {
  final messages = <MessageModel>[].obs;
  final isLoading = false.obs;
  final isSocketConnected = false.obs;
  final conversationId = RxnString();

  late final String orderId;

  final textController = TextEditingController();
  final scrollController = ScrollController();

  String? currentUserId;
  String? currentReceiverId;

  @override
  void onInit() {
    super.onInit();

    orderId = Get.arguments != null && Get.arguments['orderId'] != null
        ? Get.arguments['orderId'].toString()
        : '';

    _init();
    ever(messages, (_) => _scrollToBottom());
  }

  /// Internal async initializer to ensure socket is ready before loading history
  Future<void> _init() async {
    final userId = (await SharedPreferencesHelper.getUserId())?.toString().trim();
    currentUserId = userId;

    await initSocket();

    // If a receiver id was passed via Get.arguments, load history
    final argReceiver = Get.arguments != null
        ? (Get.arguments['receiverId'] ?? Get.arguments['otherUserId'])
        : null;

    if (argReceiver != null) {
      currentReceiverId = argReceiver.toString();
      await loadChatHistory(currentReceiverId!);
    }
  }

  /// Initialize socket connection
  Future<void> initSocket() async {
    debugPrint("🚀 Rider: Initializing socket connection...");
    isLoading.value = true;

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final userId = (await SharedPreferencesHelper.getUserId())?.toString().trim();

      if (token == null) {
        debugPrint("❌ Rider: Token missing");
        isLoading.value = false;
        return;
      }

      currentUserId = userId;
      debugPrint("👤 Rider userId: $userId");

      await RiderSocketService().loadToken();
      RiderSocketService().connect(userId: userId);

      // Listen to connection status
      ever(RiderSocketService().isConnected, (connected) {
        isSocketConnected.value = connected;
        debugPrint("📡 Rider socket connected: $connected");
        if (connected && conversationId.value != null && conversationId.value!.isNotEmpty) {
          markConversationAsRead();
        }
      });

      // Listen for incoming messages
      RiderSocketService().on('receive_message', (data) {
        debugPrint("📩 Rider received message: $data");

        try {
          final messageData = Map<String, dynamic>.from(data);
          final cId = messageData['conversationId']?.toString();
          if (cId != null && cId.isNotEmpty) {
            conversationId.value = cId;
          }

          final newMessage = MessageModel.fromSocket(
            data: messageData,
            isMe: false,
          );

          messages.add(newMessage);
          debugPrint("✅ Rider message added to list");

          // Auto-mark conversation as read when receiving a message while looking at chat
          markConversationAsRead();
        } catch (e) {
          debugPrint("❌ Rider error parsing message: $e");
        }
      });

      // Listen for messages read receipt (opposite party viewed message)
      RiderSocketService().on('messages_seen', (data) {
        debugPrint("👁️ Rider messages_seen receipt received: $data");
        try {
          if (data is Map) {
            final seenConvId = data['conversationId']?.toString();
            if (seenConvId == null ||
                conversationId.value == null ||
                seenConvId == conversationId.value) {
              for (var i = 0; i < messages.length; i++) {
                if (messages[i].isMe && !messages[i].isRead) {
                  messages[i].isRead = true;
                }
              }
              messages.refresh();
            }
          }
        } catch (e) {
          debugPrint("❌ Rider error processing messages_seen: $e");
        }
      });

      // Listen for message sent confirmation
      RiderSocketService().on('message_sent', (data) {
        debugPrint("✅ Rider message sent confirmation: $data");
      });

      isLoading.value = false;
    } catch (e) {
      debugPrint("❌ Rider socket init error: $e");
      isLoading.value = false;
    }
  }

  /// Mark conversation as read via Socket and REST fallback
  void markConversationAsRead() {
    final cId = conversationId.value;
    if (cId == null || cId.isEmpty) return;

    debugPrint("📖 Rider marking conversation as read: $cId");
    RiderSocketService().markAsRead(cId);
    ChatApiService.markAsRead(cId);
  }

  /// Send message
  void sendMessage(String receiverId) {
    if (receiverId.isEmpty) {
      debugPrint("⚠️ Rider: receiverId is empty");
      return;
    }

    final text = textController.text.trim();
    if (text.isEmpty) {
      debugPrint("⚠️ Rider: message text is empty");
      return;
    }

    if (!isSocketConnected.value) {
      debugPrint("⚠️ Rider: Socket not connected, cannot send message");
      EasyLoading.showError('Not connected to chat server');
      return;
    }

    currentReceiverId = receiverId;

    final payload = {
      "receiverId": receiverId,
      "content": text,
      "orderId": orderId,
      "messageType": "TEXT",
    };

    debugPrint("📤 Rider sending message to: $receiverId");
    debugPrint("📦 Rider payload: $payload");

    RiderSocketService().emit('send_message', payload);

    // Add message to local list with current time & pending read status
    final now = DateTime.now();
    messages.add(
      MessageModel(
        conversationId: conversationId.value,
        text: text,
        isMe: true,
        time: MessageModel.formatTime(now),
        createdAt: now,
        isRead: false,
      ),
    );

    textController.clear();
  }

  /// Load chat history from API for given receiver and current orderId
  Future<void> loadChatHistory(String receiverId) async {
    isLoading.value = true;
    try {
      currentReceiverId = receiverId;
      final dataMap = await ChatApiService.getChatHistoryData(
        receiverId: receiverId,
        orderId: orderId,
      );

      messages.clear();

      if (dataMap == null) {
        debugPrint("⚠️ Rider: No chat history returned");
        isLoading.value = false;
        return;
      }

      // Extract conversationId from history response
      final convId = dataMap['conversationId'] ??
          dataMap['id'] ??
          (dataMap['conversation'] is Map ? dataMap['conversation']['id'] : null);
      if (convId != null) {
        conversationId.value = convId.toString();
      }

      final rawList = dataMap['messages'] as List<dynamic>? ?? [];

      for (final item in rawList) {
        try {
          final map = Map<String, dynamic>.from(item);
          if (conversationId.value == null && map['conversationId'] != null) {
            conversationId.value = map['conversationId'].toString();
          }

          final msg = MessageModel.fromJson(map, currentUserId: currentUserId);
          messages.add(msg);
        } catch (e) {
          debugPrint("❌ Rider: failed to parse history item: $e");
        }
      }

      debugPrint("📜 Rider loaded ${messages.length} messages. ConvId: ${conversationId.value}");

      // Mark messages as read since rider has opened the chat screen
      if (conversationId.value != null && conversationId.value!.isNotEmpty) {
        markConversationAsRead();
      }
    } catch (e) {
      debugPrint("❌ Rider: loadChatHistory error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Retry connection
  Future<void> retryConnection() async {
    debugPrint("🔄 Rider: Retrying connection...");
    await initSocket();
  }

  /// Clear messages (optional utility)
  void clearMessages() {
    messages.clear();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    RiderSocketService().dispose();
    super.onClose();
  }
}
