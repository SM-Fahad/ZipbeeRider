# Chat & Real-Time Read Receipts (Seen Status) - App Integration Guide

This guide provides the complete specification, event contracts, and code snippets for integrating the real-time chat and message "seen" (read receipts) feature into the mobile app (Flutter / React Native / iOS / Android).

---

## 1. WebSocket Connection Setup

* **Namespace:** `/api/v1/messages` (or `http(s)://<your-backend-host>/api/v1/messages`)
* **Transport:** `websocket` / `polling`
* **Authentication:** Pass the JWT token inside the socket `auth` object upon connection.

### Connection Example:
```javascript
import { io } from "socket.io-client";

const socket = io("https://your-api-domain.com/api/v1/messages", {
  auth: {
    token: "YOUR_JWT_ACCESS_TOKEN",
  },
  transports: ["websocket"],
});

socket.on("connect", () => {
  console.log("Connected to Chat Gateway with ID:", socket.id);
});

socket.on("connected", (data) => {
  console.log("Authenticated as user:", data.userId);
});
```

---

## 2. Real-Time "Message Seen" (Read Receipts)

When User B opens a chat conversation sent by User A, User B's app should mark the messages as read. The backend will automatically inform User A in real-time.

### Step A: Marking Messages as Read (Reader Side)

You can mark a conversation as read via **WebSocket (Recommended)** or **REST API**.

#### Option 1: Via WebSocket (Instant)
Emit the `mark_as_read` event with the `conversationId`:

```javascript
// Emit when the user opens or focuses on the chat screen
socket.emit("mark_as_read", {
  conversationId: "c3b9b4f2-1234-4567-89ab-cdef01234567"
}, (response) => {
  console.log("Mark as read acknowledgment:", response);
  // response = { success: true, count: 3, conversationId: "...", readerId: 12 }
});
```

#### Option 2: Via REST API
Alternatively, call the REST endpoint:
* **Method:** `PATCH`
* **Endpoint:** `/chat/read/:conversationId`
* **Headers:** `Authorization: Bearer <token>`
* **Response:**
  ```json
  {
    "status": true,
    "message": "Messages marked as read",
    "data": {
      "message": "Messages marked as read",
      "count": 3,
      "conversationId": "c3b9b4f2-1234-4567-89ab-cdef01234567",
      "readerId": 12,
      "otherUserId": 5
    }
  }
  ```
*(Note: Calling the REST endpoint will also trigger the real-time socket event to the sender automatically).*

---

### Step B: Listening for "Seen" Status (Sender Side)

When the other party reads your messages, the backend emits the `messages_seen` event to your socket.

#### Listen for `messages_seen`:
```javascript
socket.on("messages_seen", (payload) => {
  console.log("Messages read receipt received:", payload);
  /*
    Payload Schema:
    {
      "conversationId": "c3b9b4f2-1234-4567-89ab-cdef01234567",
      "readerId": 12,
      "readAt": "2026-08-18T13:14:00.000Z"
    }
  */

  // Update UI: change sent message ticks from grey to blue (or single to double tick)
  if (currentActiveConversationId === payload.conversationId) {
    markLocalMessagesAsSeen(payload.conversationId, payload.readAt);
  }
});
```

---

## 3. Sending & Receiving Messages

For completeness, here is the reference for regular message exchange.

### Sending a Message:
```javascript
socket.emit("send_message", {
  receiverId: 12, // ID of the other user
  content: "Hello, where are you?",
  messageType: "TEXT", // "TEXT" | "IMAGE" | "PDF"
  orderId: "109", // Optional: link chat to an order
  fileUrl: null,
  fileName: null,
  fileSize: null,
}, (ack) => {
  console.log("Message sent acknowledgment:", ack);
});
```

### Receiving a Message:
```javascript
socket.on("receive_message", (message) => {
  console.log("New message incoming:", message);
  /*
    message = {
      id: "uuid",
      conversationId: "uuid",
      senderId: 5,
      receiverId: 12,
      content: "Hello, where are you?",
      messageType: "TEXT",
      isRead: false,
      createdAt: "2026-08-18T13:10:00.000Z",
      status: "delivered"
    }
  */

  // If user is actively looking at this conversation, immediately mark it as read!
  if (currentActiveConversationId === message.conversationId) {
    socket.emit("mark_as_read", { conversationId: message.conversationId });
  }

  appendMessageToChatUI(message);
});
```

---

## 4. Summary of Socket Events

| Event Name | Direction | Payload Description |
| :--- | :--- | :--- |
| `send_message` | Client ➡️ Server | Send a new message to a recipient. |
| `receive_message` | Server ➡️ Client | Received when someone sends you a message. |
| `mark_as_read` | Client ➡️ Server | Emitted by reader when opening/viewing a conversation. |
| `messages_seen` | Server ➡️ Client | Received by sender when recipient reads their messages. |
| `user_offline` | Server ➡️ Client | Notifies when a chat partner disconnects. |
