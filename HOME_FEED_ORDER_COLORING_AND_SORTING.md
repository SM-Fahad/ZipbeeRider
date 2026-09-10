# Home Feed Order Coloring & Multi-Level Sorting Documentation

This document outlines how orders are dynamically **colored**, **spotlighted**, and **multi-level sorted** in the Home Feed of the ZipBee Driver application.

---

## 1. Architecture Overview

Order coloring, spotlight lifecycle, and multi-level sorting logic are centralized to maintain consistent UI visual states across the app.

```
                  ┌───────────────────────────────┐
                  │      HomeFeedSocketService    │
                  └──────────────┬────────────────┘
                                 │ Real-time Feed Stream (WebSocket)
                                 ▼
                  ┌───────────────────────────────┐
                  │         HomeController        │
                  │  (Spotlight Timer & Sorter)   │
                  └──────────────┬────────────────┘
                                 │
         ┌───────────────────────┴───────────────────────┐
         ▼                                               ▼
┌───────────────────────────┐               ┌───────────────────────────┐
│     OrderColorHelper      │               │   Multi-Level Comparator  │
│ (Dynamic Lifecycle Color) │               │   (Spotlight→Color→Time)  │
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

## 2. Dynamic Color-Coding Lifecycles (`OrderColorHelper`)

Scheduled orders are fluid based on the time remaining until collection. Once a scheduled order "crosses 12:00 AM" of the delivery day, it transitions out of the long-term holding state.

Source file: [`order_color_helper.dart`](file:///Users/Fahad/Documents/Fahad/nicholaslim80Rider/lib/core/utils/order_color_helper.dart)

### Color Palette & State Reference

| Remaining Time / Context | Color Code | Visual Indicator | System State / Section | Rank |
| :--- | :--- | :--- | :--- | :--- |
| **New Order Arrival** (First $X$ seconds) | Flash / Top Pin | 🟡 Spotlight | Temporary Spotlight | **Pinned to Top** |
| **Collection is <= 45 mins away / ASAP** | `#FFCC00` (`AppColors.primaryButtonColor`) | 🧡 Yellow | Current (Urgent / Active) | **Rank 1** |
| **Same Day** (Crossed 12:00 AM of collection day) | `#3B82F6` (`OrderColorHelper.laterBlue`) | 💙 Blue | Later (Medium-term) | **Rank 2** |
| **Collection is > 1 day away** | `#D8D8D8` (`AppColors.greyButtonColor`) | 💜 Grey | Scheduled (Long-term) | **Rank 3** |

---

## 3. Multi-Level Order Sorting Hierarchy

The order list is sorted according to the following strict hierarchy:

### 🌟 Priority 0: New Order Exception (Temporary Spotlight)
- When a new Current, Later, or Scheduled order is received, it temporarily pops to the **very top of the list** for $X$ seconds so the driver immediately notices it.
- **Configurable Refresh Rate**: The duration $X$ in seconds (e.g. 5, 10, 15s) is customizable by the driver in **Driver Preferences** and the **Home Screen More Menu**, saved to local preferences and synced to the backend API.
- **Auto-Refresh**: When the spotlight expires, the timer automatically re-sorts the list and places the order into its defined color section.

### 🥇 Sort Level 1: Primary Section Color (Category Rank)
- **1st**: 🧡 **Current Orders (Yellow)**
- **2nd**: 💙 **Later Orders (Blue)**
- **3rd**: 💜 **Scheduled Orders (Grey)**

### 🥈 Sort Level 2: Collection Urgency (Time)
- Within each color section, orders are sorted ascending by soonest collection time:
  - For Scheduled: `order.scheduledTime ?? order.placedAt ?? order.createdAt`
  - For ASAP: `order.placedAt ?? order.createdAt`
- Soonest collection time climbs to the top of its color section.

### 🥉 Sort Level 3: Proximity (Distance)
- If collection times match, the job closest to the driver's current GPS location ranks higher.
- Calculated using `order.raiderToPickupKm` or `Geolocator.distanceBetween` from the driver's live GPS coordinates to the pickup coordinates.

---

## 4. Decline & Reset Mechanism

### Slide to Decline
- When the driver slides to decline an order on `SwipeButtonWidget`, the order is immediately removed from the active list, recorded in local declined IDs, and dispatched via the backend decline API.
- The order will not appear in subsequent feed updates.

### Order Feed Reset
- Accessible from the **Home Screen popup menu** and **Driver Preference screen**.
- Calls `PATCH /order/decline/reset` (`ApiEndPoint.orderDeclineReset`), clears local declined order IDs, and pulls the fresh feed.
- Any declined orders that **have not been accepted by another driver** will reappear in the feed. Orders accepted by another driver will not reappear.

---

## Summary Checklist
- [x] **Dynamic Lifecycles**: Current (<= 45m / ASAP, Yellow), Later (Same day, Blue), Scheduled (> 1d, Grey).
- [x] **Multi-Level Sorting**: Spotlight Pin → Current (Yellow) → Later (Blue) → Scheduled (Grey) → Collection Time → Proximity Distance.
- [x] **New Order Spotlight**: Temporary top pinning with auto-refresh after configurable duration.
- [x] **Configurable Refresh Rate**: Adjustable in Driver Preferences & Home Screen popup menu.
- [x] **Decline & Reset**: Immediate removal on decline, with reset restoring available unaccepted orders.
