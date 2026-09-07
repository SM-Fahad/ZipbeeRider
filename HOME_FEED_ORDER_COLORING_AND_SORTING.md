# Home Feed Order Coloring & Sorting Documentation

This document outlines how orders are dynamically **colored** and **sorted** in the Home Feed of the ZipBee Driver application.

---

## 1. Architecture Overview

Order coloring and sequence sorting logic are centralized to maintain consistent UI visual states across the app.

```
                  ┌───────────────────────────────┐
                  │      HomeFeedSocketService    │
                  └──────────────┬────────────────┘
                                 │ Real-time Feed Stream (WebSocket)
                                 ▼
                  ┌───────────────────────────────┐
                  │         HomeController        │
                  └──────────────┬────────────────┘
                                 │
         ┌───────────────────────┴───────────────────────┐
         ▼                                               ▼
┌───────────────────────────┐               ┌───────────────────────────┐
│     OrderColorHelper      │               │     Stop Sequence Sort    │
│ (Dynamic Color Logic)     │               │  (a.sequence.compareTo)   │
└────────┬──────────────────┘               └────────┬──────────────────┘
         │                                           │
         └───────────────────────┬───────────────────┘
                                 ▼
                  ┌───────────────────────────────┐
                  │       RiderCardWidget /       │
                  │   SwipeButtonWidget (UI)      │
                  └───────────────────────────────┘
```

---

## 2. Order Coloring Logic (`OrderColorHelper`)

The order background & button colors are dynamically calculated based on the order's collection type (`ASAP` vs `SCHEDULED`), creation time (`placedAt`), target time (`scheduledTime`), and the current device time (`DateTime.now()`).

Source file: [`order_color_helper.dart`](file:///Users/nuhan/Shahriar_Shanto/nicholaslim80Rider/lib/core/utils/order_color_helper.dart)

### Color Palette Reference

| Color Key | Hex Code | Visual Indicator | Usage Meaning |
| :--- | :--- | :--- | :--- |
| `pastColor` | `#FFA500` | 🟠 Amber / Orange | Overdue or delayed order |
| `primaryButtonColor` | `#FFCC00` | 🟡 Bright Yellow | Urgent / Immediate action required |
| `seconderyButtonColor` | `#6DB1E0` | 🔵 Sky Blue | Scheduled for later today |
| `greyButtonColor` | `#D8D8D8` | ⚪ Light Grey | Scheduled for tomorrow or future dates |

---

### A. ASAP Orders (`collect_time == "ASAP"`)

ASAP orders require immediate pickup attention. The system checks `placedAt` (or `scheduledTime` if `placedAt` is missing):

```
                       ASAP Order Received
                                │
                 Is placedAt > 24 hours ago?
                       /                 \
                     YES                 NO
                     /                     \
      🟠 pastColor (#FFA500)       🟡 primaryButtonColor (#FFCC00)
       (Overdue/Delayed)                  (Active/Immediate)
```

1. **Overdue / Delayed (`> 24 hours old`)**:
   - **Color**: `pastColor` (`#FFA500` - Orange)
   - **Condition**: `currentTime.difference(placedAt) >= Duration(days: 1)`
2. **Active / Immediate (`<= 24 hours old`)**:
   - **Color**: `AppColors.primaryButtonColor` (`#FFCC00` - Yellow)
   - **Condition**: Order created within the last 24 hours.

---

### B. Scheduled Orders (`collect_time == "SCHEDULED"`)

Scheduled orders have designated future pickup timestamps (`scheduledTime`). The system evaluates `scheduledTime` against local device time:

```
                            Scheduled Order Received
                                       │
                         Is scheduledTime in the past?
                               /               \
                             YES               NO
                             /                   \
              🟠 pastColor (#FFA500)       Is scheduledTime <= 1 hour away?
                                                 /              \
                                               YES              NO
                                               /                  \
                               🟡 primaryButtonColor (#FFCC00)  Is same calendar date?
                                                                 /            \
                                                               YES            NO
                                                               /                \
                                                🔵 seconderyButtonColor      ⚪ greyButtonColor (#D8D8D8)
                                                      (#6DB1E0)
```

1. **Past / Overdue (`scheduledTime < currentTime`)**:
   - **Color**: `pastColor` (`#FFA500` - Orange)
   - **Condition**: Target time has passed.
2. **Imminent / Urgent (`within 1 hour`)**:
   - **Color**: `AppColors.primaryButtonColor` (`#FFCC00` - Yellow)
   - **Condition**: `scheduledTime.difference(currentTime) <= Duration(hours: 1)`
3. **Same Day / Today (`scheduledTime` date == `currentTime` date)**:
   - **Color**: `AppColors.seconderyButtonColor` (`#6DB1E0` - Blue)
   - **Condition**: Target time is later today (> 1 hour away, same calendar day).
4. **Future Date (`Tomorrow or beyond`)**:
   - **Color**: `AppColors.greyButtonColor` (`#D8D8D8` - Grey)
   - **Condition**: Target time is set for tomorrow or later.

---

## 3. Order & Stop Sorting Logic

### A. Feed Level Order Updates & Ordering
- **Real-Time WebSocket Feed**: Managed via [`home_controller.dart`](file:///Users/nuhan/Shahriar_Shanto/nicholaslim80Rider/lib/features/home/controller/home_controller.dart) and [`home_feed_socket_service.dart`](file:///Users/nuhan/Shahriar_Shanto/nicholaslim80Rider/lib/features/home/service/home_feed_socket_service.dart).
- **Socket Stream Listener**: Listens to `rider:feed_update` events and emits `rider:get_feed` request with `page` and `limit`.
- **Deduplication**: When appending paginated/streamed orders, duplicate order IDs are filtered out:
  ```dart
  final Set<int> existingIds = orders.map((o) => o.id).toSet();
  final List<OrderModel> newOrders = parsedOrders.where((o) => !existingIds.contains(o.id)).toList();
  orders.addAll(newOrders);
  ```

### B. Order Stop Sequence Sorting
Within each individual order, pickup and delivery stops (`orderStops`) are sorted in natural ascending sequence order:

```dart
List<OrderStopModel> _sortStops(List<OrderStopModel> stops) {
  final sorted = [...stops];
  sorted.sort((a, b) => a.sequence.compareTo(b.sequence));
  return sorted;
}
```

- **Pickup Stops**: Filtered where `stop.isPickup == true` and sorted by `sequence`.
- **Drop Stops**: Filtered where `stop.isDrop == true` and sorted by `sequence`.

---

## 4. UI Components Utilizing Color & Sorting

| Component | Description | File Link |
| :--- | :--- | :--- |
| `RiderCardWidget` | Main card item displayed in home feed | [`rider_card_widget.dart`](file:///Users/nuhan/Shahriar_Shanto/nicholaslim80Rider/lib/features/home/widgets/rider_card_widget.dart) |
| `SwipeButtonWidget` | Slide-to-accept action button on home feed | [`swipe_button_widget.dart`](file:///Users/nuhan/Shahriar_Shanto/nicholaslim80Rider/lib/features/home/widgets/swipe_button_widget.dart) |
| `OrderDetailsScreen` | Detailed breakdown of route & stops | [`order_details_screen.dart`](file:///Users/nuhan/Shahriar_Shanto/nicholaslim80Rider/lib/features/order_details/screen/order_details_screen.dart) |
| `TakeNowScreen` | Take now order screen for riders | [`take_now_screen.dart`](file:///Users/nuhan/Shahriar_Shanto/nicholaslim80Rider/lib/features/take_now/screen/take_now_screen.dart) |

---

## Summary Checklist

- [x] **ASAP Orders**: Colored Yellow (`#FFCC00`) if created within 24h, Orange (`#FFA500`) if older.
- [x] **Scheduled Orders**: Colored Orange (`#FFA500`) if past, Yellow (`#FFCC00`) if within 1 hour, Blue (`#6DB1E0`) if today, Grey (`#D8D8D8`) if future.
- [x] **Stop Sequencing**: Sorted numerically by `stop.sequence`.
- [x] **Feed Syncing**: Streaming real-time WebSocket updates via `HomeFeedSocketService`.
