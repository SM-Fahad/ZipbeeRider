import 'dart:async';
import 'dart:convert';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/services/socket_service.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/auto_popup/controller/auto_popup_controller.dart';
import 'package:ZipBee_Driver/features/order_details/screen/order_details_screen.dart';
import 'package:ZipBee_Driver/core/utils/app_route_observer.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ZipBee_Driver/core/utils/location_helper.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../model/order_model.dart';
import '../service/order_feed_service.dart';
import '../service/home_feed_socket_service.dart';

import '../service/deliverytype_service.dart';
import 'package:ZipBee_Driver/features/account/controller/account_controller.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';

class HomeController extends GetxController with WidgetsBindingObserver, RouteAware {
  // ================= STATE =================
  final orders = <OrderModel>[].obs;
  final isOnline = false.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  final currentPage = 1.obs;
  final limit = 20.obs;
  final totalPages = 1.obs;
  final hasMoreData = true.obs;

  late final ScrollController scrollController;
  final OrderFeedService orderFeedService = OrderFeedService();
  final Logger logger = Logger();

  // Socket related
  final SocketService _socketService = SocketService();
  final HomeFeedSocketService _feedSocketService = HomeFeedSocketService();
  late final AutoPopupController _autoPopupController;
  //final RiderCompetitionSocketService competitionSocketService = RiderCompetitionSocketService();
  Timer? _locationTimer;
  var currentLocation = Rx<LatLng?>(null);
  final currentHeading = 0.0.obs;
  int _socketRetryCount = 0;

  bool _apiCalledOnce = false; // 🔐 important
  // bool _refreshRequestedWhileLoading = false;
  // int _homeReloadVersion = 0;

  // Dialog UI state
  final competitorCount = 0.obs;
  final timeRemaining = 0.obs;
  final progressValue = 0.0.obs; // 0.0 to 1.0

  var isWin = false.obs;
  var isLoss = false.obs;

  Timer? _progressTimer;

  final unreadNotificationCount = 0.obs;

  // New Order Spotlight & Decline Tracking
  final Map<int, DateTime> _spotlightOrders = {};
  final Set<int> _knownOrderIds = {};
  final Set<int> _declinedOrderIds = {};
  Timer? _spotlightRefreshTimer;

  int get feedRefreshRateSeconds {
    if (Get.isRegistered<AccountController>()) {
      return Get.find<AccountController>().orderFeedRefreshRateSeconds.value;
    }
    return 10;
  }

  // ================= LIFECYCLE =================
  bool _isRouteObserverSubscribed = false;

  void subscribeRoute(BuildContext context) {
    if (!_isRouteObserverSubscribed) {
      final route = ModalRoute.of(context);
      if (route != null) {
        appRouteObserver.subscribe(this, route);
        _isRouteObserverSubscribed = true;
      }
    }
  }

  @override
  void didPopNext() {
    refreshOrders();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshOrders();
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _autoPopupController = Get.isRegistered<AutoPopupController>()
        ? Get.find<AutoPopupController>()
        : Get.put(AutoPopupController());
    _initializeScrollController();
    _initializeUserLocation();
    connectSocketIfLoggedIn();
    DeliveryTypeService().fetchDeliveryTypes();
    //initCompetitionSocket(baseUrl: ApiEndPoint.baseUrl);
  }

  Future<void> connectSocketIfLoggedIn() async {
    final token = await SharedPreferencesHelper.getToken();
    if (token != null && token.isNotEmpty) {
      await connectSocket();
    }
  }

  @override
  void onReady() {
    super.onReady();
    _fetchOrdersSafely();
    fetchUnreadNotificationCount();
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse(ApiEndPoint.notificationUnreadCount),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        unreadNotificationCount.value = decoded['data']?['count'] ?? 0;
      } else {
        debugPrint(
          'fetchUnreadNotificationCount failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('fetchUnreadNotificationCount error: $e');
    }
  }

  @override
  void onClose() {
    if (_isRouteObserverSubscribed) {
      appRouteObserver.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    _stopSendingLocation();
    _stopProgressTimer();
    _spotlightRefreshTimer?.cancel();
    _feedSocketService.dispose();
    _socketService.disconnect();
    super.onClose();
  }

  // ================= INIT HELPERS =================
  void _initializeScrollController() {
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final threshold = scrollController.position.maxScrollExtent - 100;
    if (scrollController.position.pixels >= threshold) {
      loadMore();
    }
  }

  Future<void> _fetchOrdersSafely() async {
    if (_apiCalledOnce) return;

    final token = await SharedPreferencesHelper.getToken();
    if (token == null || token.isEmpty) {
      logger.w("⛔ Token not found, skipping order fetch");
      return;
    }

    _apiCalledOnce = true;
    // HTTP API feed fetch is commented out:
    // await fetchOrdersFromApi();

    // If already online and socket is connected, request feed
    if (isOnline.value && _socketService.socket != null && _socketService.socket!.connected) {
      _feedSocketService.refreshFeed(page: 1, limit: limit.value);
    }
  }

  // ================= API =================
  Future<void> fetchOrdersFromApi({bool isRefresh = false}) async {
    debugPrint('[API FEED] HTTP fetch is disabled. Using socket feed instead.');
    /*
    if (isLoading.value || isLoadingMore.value) {
      if (isRefresh) {
        _refreshRequestedWhileLoading = true;
      }
      return;
    }

    try {
      if (isRefresh) {
        _refreshRequestedWhileLoading = false;
        currentPage.value = 1;
        orders.clear();
        hasMoreData.value = true;
      }

      final isFirstPage = currentPage.value == 1;
      if (isFirstPage) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final response = await orderFeedService.fetchOrderFeed(
        page: currentPage.value,
        limit: limit.value,
      );

      if (response.data.isNotEmpty) {
        if (isFirstPage) {
          orders.assignAll(response.data);
        } else {
          orders.addAll(response.data);
        }

        totalPages.value = response.totalPages;
        hasMoreData.value = currentPage.value < totalPages.value;

        logger.i(
          "📦 Orders loaded: ${response.data.length}, page ${currentPage.value}/${totalPages.value}",
        );
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      logger.e("❌ Error fetching orders: $e");

      if (orders.isEmpty) {
        fetchOrders(); // mock fallback
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;

      if (_refreshRequestedWhileLoading) {
        await fetchOrdersFromApi(isRefresh: true);
      }
    }
    */
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMoreData.value) return;

    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      if (isOnline.value && _socketService.socket != null && _socketService.socket!.connected) {
        debugPrint('[SOCKET] Requesting more feed via socket for page ${currentPage.value}');
        isLoadingMore.value = true;
        _feedSocketService.refreshFeed(page: currentPage.value, limit: limit.value);
      } else {
        // HTTP fallback is disabled
        debugPrint('[SOCKET] Cannot load more, socket is disconnected.');
      }
    }
  }

  Future<void> refreshOrders() async {
    _apiCalledOnce = false;
    currentPage.value = 1;
    hasMoreData.value = true;
    
    if (isOnline.value && _socketService.socket != null && _socketService.socket!.connected) {
      debugPrint('[SOCKET] Pull-to-refresh: Requesting feed via socket');
      isLoading.value = true;
      _feedSocketService.refreshFeed(page: 1, limit: limit.value);
    } else {
      debugPrint('[SOCKET] Socket not connected. Cannot refresh feed.');
    }
  }

  Future<void> reloadOrdersForHomeUpdate() async {
    _apiCalledOnce = false;
    // _refreshRequestedWhileLoading = false;
    currentPage.value = 1;
    isLoadingMore.value = false;
    hasMoreData.value = true;
    orders.clear();
    isLoading.value = true;

    if (isOnline.value && _socketService.socket != null && _socketService.socket!.connected) {
      debugPrint('[SOCKET] Requesting feed via socket for home update...');
      _feedSocketService.refreshFeed(page: 1, limit: limit.value);
    } else {
      isLoading.value = false;
      debugPrint('[SOCKET] Socket not connected for reloadOrdersForHomeUpdate.');
    }
  }

  void clearOrdersState() {
    orders.clear();
    _spotlightOrders.clear();
    _knownOrderIds.clear();
    _spotlightRefreshTimer?.cancel();
    currentPage.value = 1;
    totalPages.value = 1;
    hasMoreData.value = true;
    isLoading.value = false;
    isLoadingMore.value = false;
    _apiCalledOnce = false;
  }

  // ================= ORDER FEED RESET & REFRESH RATE =================
  Future<void> resetOrderFeed() async {
    try {
      EasyLoading.show(status: 'Resetting order feed...');
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showError('Authentication token not found');
        return;
      }

      final response = await http.patch(
        Uri.parse(ApiEndPoint.orderDeclineReset),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final bool isSuccess = decoded['success'] == true;
        final String message =
            decoded['message'] ?? '0 declined order(s) restored successfully';

        if (isSuccess) {
          _declinedOrderIds.clear();
          _knownOrderIds.clear();
          _spotlightOrders.clear();
          EasyLoading.showSuccess(message);
          await refreshOrders();
        } else {
          EasyLoading.showError(message);
        }
      } else {
        final decoded = jsonDecode(response.body);
        final message = decoded['message'] ?? 'Failed to reset order feed';
        EasyLoading.showError(message);
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('resetOrderFeed error: $e');
      EasyLoading.showError('Error resetting order feed: $e');
    }
  }

  void showFeedRefreshRateBottomSheet(BuildContext context) {
    final accountCtrl = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());

    final textController = TextEditingController(
      text: accountCtrl.orderFeedRefreshRateSeconds.value.toString(),
    );
    final isModified = false.obs;

    void checkIfModified() {
      final input = textController.text.trim();
      final saved = accountCtrl.orderFeedRefreshRateSeconds.value.toString();
      isModified.value = input.isNotEmpty && input != saved;
    }

    textController.addListener(checkIfModified);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.onboardingIndicatorActive,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.refresh, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Feed Refresh Rate (sec)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: TextFormField(
                        controller: textController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onFieldSubmitted: (_) async {
                          await _saveFeedRefreshRate(
                            textController.text,
                            accountCtrl,
                          );
                        },
                      ),
                    ),
                    if (isModified.value ||
                        accountCtrl.isFeedRefreshRateUpdating.value) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: accountCtrl.isFeedRefreshRateUpdating.value
                            ? null
                            : () async {
                                await _saveFeedRefreshRate(
                                  textController.text,
                                  accountCtrl,
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.onboardingIndicatorActive,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: accountCtrl.isFeedRefreshRateUpdating.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.black,
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    ).whenComplete(() {
      textController.removeListener(checkIfModified);
      textController.dispose();
    });
  }

  Future<void> _saveFeedRefreshRate(
    String input,
    AccountController accountCtrl,
  ) async {
    final seconds = int.tryParse(input.trim());
    if (seconds == null || seconds <= 0) {
      EasyLoading.showError('Please enter a valid refresh rate in seconds');
      return;
    }
    if (seconds.toString() ==
        accountCtrl.orderFeedRefreshRateSeconds.value.toString()) {
      Get.back();
      return;
    }
    EasyLoading.show(status: 'Updating...');
    final success = await accountCtrl.updateFeedRefreshRate(seconds);
    EasyLoading.dismiss();
    if (success) {
      Get.back();
      EasyLoading.showSuccess('Feed refresh rate updated successfully');
      _scheduleSpotlightAutoRefresh();
      if (orders.isNotEmpty) {
        orders.assignAll(sortOrdersList(orders));
        orders.refresh();
      }
    }
  }

  // ================= MULTI-LEVEL SORTING & SPOTLIGHT HELPERS =================
  List<OrderModel> sortOrdersList(List<OrderModel> list) {
    final now = DateTime.now();
    final sorted = List<OrderModel>.from(list);

    sorted.sort((a, b) {
      final aExpires = _spotlightOrders[a.id];
      final bExpires = _spotlightOrders[b.id];
      final aIsSpotlight = aExpires != null && aExpires.isAfter(now);
      final bIsSpotlight = bExpires != null && bExpires.isAfter(now);

      // New Order Exception: temporary spotlight pops to the very top
      if (aIsSpotlight && !bIsSpotlight) return -1;
      if (!aIsSpotlight && bIsSpotlight) return 1;
      if (aIsSpotlight && bIsSpotlight) {
        final cmp = bExpires!.compareTo(aExpires!);
        if (cmp != 0) return cmp;
      }

      // Sort Level 1: Primary Section Color / Category Rank
      // 1st: Current (Yellow) -> 2nd: Later (Blue) -> 3rd: Scheduled (Grey)
      final rankA = OrderColorHelper.getOrderCategoryRank(a, currentTime: now);
      final rankB = OrderColorHelper.getOrderCategoryRank(b, currentTime: now);
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }

      // Sort Level 2: Collection Urgency (Time)
      // Soonest collection time climbs to the top of its color section
      final timeA = (a.scheduledTime ?? a.placedAt ?? a.createdAt).toLocal();
      final timeB = (b.scheduledTime ?? b.placedAt ?? b.createdAt).toLocal();
      final timeDiff = timeA.compareTo(timeB);
      if (timeDiff != 0) {
        return timeDiff;
      }

      // Sort Level 3: Proximity (Distance)
      // If collection times match, job closest to driver's GPS location ranks higher
      final distA = _getDistanceToDriver(a);
      final distB = _getDistanceToDriver(b);
      return distA.compareTo(distB);
    });

    return sorted;
  }

  double _getDistanceToDriver(OrderModel order) {
    if (order.raiderToPickupKm != null) {
      return order.raiderToPickupKm!;
    }

    if (currentLocation.value != null && order.orderStops.isNotEmpty) {
      try {
        final pickup = order.orderStops.firstWhere(
          (s) => s.isPickup,
          orElse: () => order.orderStops.first,
        );
        final distanceInMeters = Geolocator.distanceBetween(
          currentLocation.value!.latitude,
          currentLocation.value!.longitude,
          pickup.latitude,
          pickup.longitude,
        );
        return distanceInMeters / 1000.0;
      } catch (_) {}
    }

    return order.effectiveDistanceKm;
  }

  void _scheduleSpotlightAutoRefresh() {
    _spotlightRefreshTimer?.cancel();
    final now = DateTime.now();

    // Clean up expired spotlights
    _spotlightOrders.removeWhere((id, expires) => expires.isBefore(now));

    if (_spotlightOrders.isEmpty) return;

    DateTime earliest = _spotlightOrders.values.first;
    for (final expires in _spotlightOrders.values) {
      if (expires.isBefore(earliest)) earliest = expires;
    }

    final remainingMs = earliest.difference(now).inMilliseconds;
    final delay = remainingMs > 0 ? remainingMs + 50 : 100;

    _spotlightRefreshTimer = Timer(Duration(milliseconds: delay), () {
      final currentNow = DateTime.now();
      _spotlightOrders.removeWhere((id, expires) => expires.isBefore(currentNow));
      if (orders.isNotEmpty) {
        orders.assignAll(sortOrdersList(orders));
        orders.refresh();
      }
      _scheduleSpotlightAutoRefresh();
    });
  }

  // ================= HELPERS =================
  String getFirstWords(String text, {int wordCount = 2}) {
    final words = text.split(' ');
    return words.take(wordCount).join(' ');
  }

  // ================= UI ACTIONS =================
  void acceptOrder(int index) {
    final order = orders[index];
    showAcceptDialog(order, index);
  }

  void declineOrder(int index) {
    final order = orders[index];
    showDeclineDialog(order, index);
  }

  /// Show accept dialog and call API
  void showAcceptDialog(OrderModel order, int index) async {
    if (_socketService.socket == null) {
      EasyLoading.showError('Go to online first');
      return;
    }

    // Reset states for new competition
    competitorCount.value = 0;
    timeRemaining.value = 0;
    progressValue.value = 0.0;
    isWin.value = false;
    isLoss.value = false;
    _stopProgressTimer();

    // Show single reactive dialog that transitions through states
    Get.dialog(
      Obx(() => _buildCompetitionDialog(order, index)),
      barrierDismissible: false,
    );

    // Call API to join competition
    _acceptOrderViaAPI(order, index);
  }

  /// Build competition dialog that reacts to socket events
  Widget _buildCompetitionDialog(OrderModel order, int index) {
    // State 1: Waiting for competition to start
    if (competitorCount.value == 0 && !isWin.value && !isLoss.value) {
      return _buildLoadingCompetitionDialog();
    }

    // State 2: Competition active with competitor count
    if (competitorCount.value > 0 && !isWin.value && !isLoss.value) {
      return _buildActiveCompetitionDialog();
    }

    // State 3: Won competition
    if (isWin.value) {
      return _buildWinDialog(order, index);
    }

    // State 4: Lost competition
    if (isLoss.value) {
      return _buildLossDialog();
    }

    // Fallback
    return _buildLoadingCompetitionDialog();
  }

  /// Dialog: Initial loading state
  Widget _buildLoadingCompetitionDialog() {
    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: 0.1,
              strokeWidth: 5,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Accepting Order",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text("In progress..."),
        ],
      ),
    );
  }

  /// Dialog: Competition active with drivers count and progress
  Widget _buildActiveCompetitionDialog() {
    // Start progress timer when transitioning to this state
    if (timeRemaining.value > 0) {
      _startProgressTimer(timeRemaining.value);
    }

    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          Obx(
            () => SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progressValue.value,
                    strokeWidth: 6,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                  Text(
                    "${(progressValue.value * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Accepting Order...",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "${competitorCount.value} Driver${competitorCount.value != 1 ? 's' : ''} Joined",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          const Text("Please wait..."),
        ],
      ),
    );
  }

  /// Dialog: Won competition
  Widget _buildWinDialog(OrderModel order, int index) {
    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 55, color: Colors.green),
          const SizedBox(height: 12),
          const Text(
            "You got the Order!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Get.back(); // Close dialog

              // Get.to(() => CompleteOrderScreen(), arguments: order)?.then((
              //   result,
              // ) {
              //   if (result == 'completed') {
              //     logger.i('Order completed, refreshing orders list...');
              //     refreshOrders();
              //   }
              // });
              Get.to(() => OrderDetailsScreen(), arguments: order);
            },
            child: const Text("Done", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// Dialog: Lost competition
  Widget _buildLossDialog() {
    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.close_rounded, size: 55, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            "Try again",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: const Text("Done", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// Show decline dialog and call API
  void showDeclineDialog(OrderModel order, int index) {
    declineDialogStep.value = 0;

    Get.dialog(
      Obx(() => _buildDeclineDialogUI(order, index)),
      barrierDismissible: false,
    );

    // Immediately call API to decline order
    _declineOrderViaAPI(order, index);
  }

  Widget _buildDeclineDialogUI(OrderModel order, int index) {
    if (declineDialogStep.value == 0) return _loadingDialog();
    if (declineDialogStep.value == 1) return _middleDialog();
    return _declineSuccessDialog(order, index);
  }

  Widget _loadingDialog() {
    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          const Text(
            "Processing...",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text("Please wait..."),
        ],
      ),
    );
  }

  Widget _middleDialog() {
    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 40),
          const SizedBox(height: 10),
          const Text(
            "Hold On",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Finalizing your request..."),
        ],
      ),
    );
  }

  Widget _declineSuccessDialog(OrderModel order, int index) {
    return _dialogBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 55, color: Colors.green),
          const SizedBox(height: 12),
          const Text(
            "Order Declined",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Dialog step management
  RxInt declineDialogStep = 0.obs;

  Widget _dialogBase(Widget child) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }

  /// Accept order via API
  Future<void> _acceptOrderViaAPI(OrderModel order, int index) async {
    try {
      debugPrint('Accepting order via socket: Order #${order.id}');
      _socketService.joinCompetition(order.id);
      // logger.i('Accepting order via API: Order #${order.id}');

      // // Call the API to accept the order
      // final response = await orderFeedService.acceptOrderCompetition(order.id);

      // if (response['success'] == true) {
      //   logger.i('Order accepted successfully: Order #${order.id}');
      //   logger.i('Response: $response');

      //   // Extract the response data
      //   final data = response['data'] ?? {};
      //   final shouldAutoConfirm = data['shouldAutoConfirm'] ?? false;
      //   final requiresManualConfirmation =
      //       data['requiresManualConfirmation'] ?? false;

      //   logger.i(
      //     'Auto confirm: $shouldAutoConfirm, Manual confirmation required: $requiresManualConfirmation',
      //   );

      //   // Update order in list
      //   orders[index] = _copyOrderWithUpdates(order, buttonText: 'ACCEPTED');

      //   acceptDialogStep.value = 2; // Show success dialog
      // } else {
      //   logger.e('Failed to accept order: ${response['message']}');
      //   acceptDialogStep.value = 2; // Show error state
      //   Get.back(); // Close dialog
      //   Get.snackbar(
      //     'Error',
      //     response['message'] ?? 'Failed to accept order',
      //     snackPosition: SnackPosition.BOTTOM,
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //     duration: const Duration(seconds: 3),
      //   );
      // }
    } catch (e) {
      logger.e('Error accepting order: $e');
      Get.back(); // Close dialog
      EasyLoading.showError(e.toString());
    }
  }

  /// Decline order via API
  Future<void> _declineOrderViaAPI(OrderModel order, int index) async {
    try {
      logger.i('Declining order via API: Order #${order.id}');

      // Immediately track declined order and remove from list and spotlight
      _declinedOrderIds.add(order.id);
      _spotlightOrders.remove(order.id);
      orders.removeWhere((o) => o.id == order.id);
      orders.refresh();

      // Call the API to decline the order
      final response = await orderFeedService.declineOrder(order.id);

      if (response['success'] == true) {
        logger.i('Order declined successfully: Order #${order.id}');
        logger.i('Response: $response');

        declineDialogStep.value = 2; // Show success dialog
      } else {
        logger.e('Failed to decline order: ${response['message']}');
        declineDialogStep.value = 2; // Show error state
        Get.back(); // Close dialog
        EasyLoading.showError(response['message'] ?? 'Failed to decline order');
      }
    } catch (e) {
      logger.e('Error declining order: $e');
      declineDialogStep.value = 2; // Show error state
      Get.back(); // Close dialog
      EasyLoading.showError(e.toString());
    }
  }

  Future<void> toggleOnline(bool value) async {
    await handleOnlineSwitchChange(value);
  }

  Future<void> handleOnlineSwitchChange(bool value) async {
    final isValid = await checkTokenValidity();
    if (!isValid) {
      EasyLoading.dismiss();
      Get.offAllNamed(AppRoutes.loginSignupScreen);
      return;
    }
    if (_socketService.socket == null || !_socketService.isConnected) {
      EasyLoading.show(status: 'Connecting to server...');
      await connectSocket();
    }

    EasyLoading.show(status: value ? 'Going online...' : 'Going offline...');
    if (value) {
      logger.i('Emitting rider:go_online');
      _socketService.emit('rider:go_online', {});
    } else {
      logger.i('Emitting rider:go_offline');
      _socketService.emit('rider:go_offline', {});
    }
  }

  /// Initialize user location tracking
  Future<void> _initializeUserLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w('Location services are disabled.');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          logger.w('Location permissions are denied.');
          return;
        }
      }

      final locationSettings = getLocationSettings();

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      currentHeading.value = position.heading;

      // Listen to location changes
      Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        currentLocation.value = LatLng(position.latitude, position.longitude);
        currentHeading.value = position.heading;
      });
    } catch (e) {
      logger.e('Error getting location: $e');
    }
  }

  Future<bool> checkTokenValidity() async {
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }
    try {
      final response = await http.get(
        Uri.parse(ApiEndPoint.getProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        await SharedPreferencesHelper.clearAllData();
        return false;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Connect to socket server
  Future<void> connectSocket() async {
    final isValid = await checkTokenValidity();
    if (!isValid) {
      EasyLoading.dismiss();
      Get.offAllNamed(AppRoutes.loginSignupScreen);
      return;
    }
    final token = await SharedPreferencesHelper.getToken() ?? '';
    try {
      // Extract base URL without /api/v1 path
      String baseUrl = ApiEndPoint.baseUrl;
      if (baseUrl.contains('/api/')) {
        baseUrl = baseUrl.split('/api/')[0];
      }

      logger.i('Connecting to socket at: $baseUrl');
      await _socketService.connect(baseUrl, token);
      _autoPopupController.attachSocket(_socketService);
      logger.i('Socket connection initiated');

      _socketService.on('rider:status_updated', (data) {
        logger.i('rider:status_updated received: $data');
        EasyLoading.dismiss();
        final status = data['status']?.toString();
        if (status == 'online') {
          isOnline.value = true;
          _startSendingLocation();
          EasyLoading.showSuccess(data['message']?.toString() ?? 'You are now online.');
        } else if (status == 'offline') {
          isOnline.value = false;
          _stopSendingLocation();
          orders.clear();
          EasyLoading.showSuccess(data['message']?.toString() ?? 'You are now offline.');

          // If switch off on Home Screen, go to preference screen
          if (Get.currentRoute == AppRoutes.bottomNavbarScreen || Get.currentRoute == AppRoutes.homeScreen) {
            Get.offAllNamed(AppRoutes.driverPreferenceScreen);
          }
        }
      });

      _socketService.on('rider:status_error', (data) {
        logger.e('rider:status_error received: $data');
        EasyLoading.dismiss();
        EasyLoading.showError(data['message']?.toString() ?? 'Status update failed.');
      });

      // Joined competition
      _socketService.on('rider:competition_joined', (data) {
        logger.i('rider Joined competition: $data');

        competitorCount.value = (data['competitorCount'] ?? 0) as int;
        final remaining = (data['timeRemaining'] ?? 0) as int;
        timeRemaining.value = remaining;

        ///_startTimer(remaining);

        // UI text update on list (optional)
        //_updateOrderButtonText('ACCEPTING...');
      });

      // Join error
      _socketService.on('rider:competition_error', (data) {
        logger.e('Failed to join competition: $data');
        //_stopTimer();

        // Optional: show message
        final msg = data['message']?.toString() ?? 'Failed to join competition';
        Get.back(); // Close the dialog first
        EasyLoading.showError(msg);

        //_updateOrderButtonText('ACCEPT'); // revert
      });

      // Won
      _socketService.on('rider:competition_won', (data) {
        logger.i('Competition won: $data');
        isWin.value = true;

        //_stopTimer();

        //_updateOrderButtonText('WON');
      });

      // Lost
      _socketService.on('rider:competition_lost', (data) {
        logger.i('Competition lost: $data');
        isLoss.value = true;

        //_stopTimer();

        //_updateOrderButtonText('TRY AGAIN');
      });

      // Assigned (often final)
      _socketService.on('rider:order_assigned', (data) {
        logger.i('Order assigned: $data');

        // Some backends send assigned after won (or instead of won)

        //_stopTimer();

        //_updateOrderButtonText('ASSIGNED');
        // You can store trip/order details here from data
      });

      _socketService.on('rider:order_auto_confirmed', (data) {
        logger.i('Order auto confirmed: $data');

        // Optional: update status / show toast
        // _updateOrderButtonText('CONFIRMED');
      });

      // Initialize HomeFeedSocketService with callbacks
      _feedSocketService.initialize(
        onFeedUpdate: (List<OrderModel> parsedOrders, int total, Map<String, dynamic>? raiderInfo) {
          logger.i('[SOCKET FEED] Received feed update. Count: ${parsedOrders.length}, Total: $total');
          
          isLoading.value = false;
          isLoadingMore.value = false;
          
          // Filter out locally declined orders
          final filteredOrders = parsedOrders
              .where((order) => !_declinedOrderIds.contains(order.id))
              .toList();

          final now = DateTime.now();
          final rateSeconds = feedRefreshRateSeconds;

          // Detect new orders that weren't known before and spotlight them
          for (final order in filteredOrders) {
            if (!_knownOrderIds.contains(order.id)) {
              _knownOrderIds.add(order.id);
              _spotlightOrders[order.id] = now.add(Duration(seconds: rateSeconds));
            }
          }

          if (currentPage.value == 1) {
            orders.assignAll(sortOrdersList(filteredOrders));
          } else {
            // Append unique orders to avoid duplicates
            final Set<int> existingIds = orders.map((o) => o.id).toSet();
            final List<OrderModel> newOrders = filteredOrders.where((o) => !existingIds.contains(o.id)).toList();
            final combined = [...orders, ...newOrders];
            orders.assignAll(sortOrdersList(combined));
          }
          orders.refresh();
          _scheduleSpotlightAutoRefresh();
          
          totalPages.value = (total / limit.value).ceil();
          if (totalPages.value == 0) totalPages.value = 1;
          hasMoreData.value = currentPage.value < totalPages.value;

          if (raiderInfo != null) {
            final String? expressWarning = raiderInfo['expressWarning']?.toString();
            final List<dynamic>? performanceWarnings = raiderInfo['performanceWarnings'] as List<dynamic>?;
            
            if (expressWarning != null && expressWarning.isNotEmpty) {
              // Don't remove it. 
              // EasyLoading.showInfo(expressWarning);
            }
            
            if (performanceWarnings != null && performanceWarnings.isNotEmpty) {
              Get.defaultDialog(
                title: 'Warning',
                middleText: performanceWarnings.join('\n'),
                textConfirm: 'OK',
                confirmTextColor: Colors.white,
                onConfirm: () => Get.back(),
              );
            }
          }
        },
        onFeedError: (String errorMsg, int? code) {
          logger.e('[SOCKET FEED ERROR] Code: $code, Msg: $errorMsg');
          
          isLoading.value = false;
          isLoadingMore.value = false;
          
          if (code == 401) {
            Get.offAllNamed(AppRoutes.loginSignupScreen);
          } else if (code == 429) {
            EasyLoading.showToast('Please wait before refreshing');
          } else {
            EasyLoading.showError(errorMsg);
          }
        },
        onOrderDeclined: (int orderId, String message) {
          logger.i('[SOCKET FEED] Order declined: removing orderId $orderId');
          _declinedOrderIds.add(orderId);
          _spotlightOrders.remove(orderId);
          orders.removeWhere((order) => order.id == orderId);
          orders.refresh();
          EasyLoading.showInfo(message);
        },
      );

      // Helper to send location and request feed
      Future<void> sendLocationAndFetchFeed() async {
        debugPrint('[SOCKET] sendLocationAndFetchFeed called');
        
        // 1. Fetch location if not available
        if (currentLocation.value == null) {
          debugPrint('[SOCKET] Location is null, trying to get current position before feed request...');
          try {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              forceAndroidLocationManager: true,
              timeLimit: const Duration(seconds: 5),
            );
            currentLocation.value = LatLng(position.latitude, position.longitude);
            currentHeading.value = position.heading;
          } catch (e) {
            logger.e('Error getting location: $e');
          }
        }
        
        // 2. Send location if available
        if (currentLocation.value != null) {
          debugPrint('[SOCKET] Sending location before feed request: lat=${currentLocation.value!.latitude}, lng=${currentLocation.value!.longitude}');
          _socketService.sendLocation(
            lat: currentLocation.value!.latitude,
            lng: currentLocation.value!.longitude,
            heading: currentHeading.value,
          );
          // Wait 200ms to ensure server registers the location before we ask for the feed
          await Future.delayed(const Duration(milliseconds: 200));
        } else {
          logger.w('[SOCKET] Location is still null. Feed request might fail.');
          EasyLoading.showError('Location not available. Please enable GPS.');
        }
        
        // 3. Request feed
        debugPrint('[SOCKET] Requesting feed via socket...');
        _feedSocketService.refreshFeed(page: 1, limit: limit.value);
      }

      if (_socketService.isConnected) {
        sendLocationAndFetchFeed();
      }

      _socketService.on('connect', (_) {
        debugPrint('[SOCKET] Connect event received.');
        _socketRetryCount = 0;
        sendLocationAndFetchFeed();
      });

      // Listen for socket errors
      _socketService.on('connect_error', (data) {
        logger.e('[SOCKET] Connection error: $data');
        isLoading.value = false;
        EasyLoading.dismiss();
        
        final errorStr = data.toString().toLowerCase();
        if (errorStr.contains('unauthorized') || errorStr.contains('auth') || errorStr.contains('expired') || errorStr.contains('token')) {
          SharedPreferencesHelper.clearAllData();
          Get.offAllNamed(AppRoutes.loginSignupScreen);
        } else {
          _socketRetryCount++;
          if (_socketRetryCount > 5) {
            logger.w('[SOCKET] Connection failed repeatedly, restarting socket connection...');
            _socketRetryCount = 0;
            _socketService.disconnect();
            Future.delayed(const Duration(seconds: 3), () {
              connectSocket();
            });
          }
        }
      });

      _socketService.on('error', (data) {
        logger.e('[SOCKET] Error: $data');
        isLoading.value = false;
        EasyLoading.dismiss();
        
        final errorStr = data.toString().toLowerCase();
        if (errorStr.contains('unauthorized') || errorStr.contains('auth') || errorStr.contains('expired') || errorStr.contains('token')) {
          SharedPreferencesHelper.clearAllData();
          Get.offAllNamed(AppRoutes.loginSignupScreen);
        } else {
          // Suppressed generic socket errors
        }
      });

      // Debug: see all events
      _socketService.onAny((event, data) {
        logger.e('[EVENT] $event -> $data');
      });
    } catch (e) {
      logger.e('Error connecting socket: $e');
    }
  }

  /// Start sending location continuously
  void _startSendingLocation() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (currentLocation.value != null && isOnline.value) {
        _socketService.sendLocation(
          lat: currentLocation.value!.latitude,
          lng: currentLocation.value!.longitude,
          heading: currentHeading.value,
        );
      }
    });
    logger.i('Started sending location');
  }

  /// Stop sending location
  void _stopSendingLocation() {
    _locationTimer?.cancel();
    _locationTimer = null;
    logger.i('Stopped sending location');
  }

  /// Start progress timer that animates from 0 to 1.0 over timeRemaining
  void _startProgressTimer(int totalSeconds) {
    _stopProgressTimer(); // Cancel any existing timer

    if (totalSeconds <= 0) return;

    int elapsedMilliseconds = 0;
    final totalMilliseconds = totalSeconds * 1000;
    const timerInterval = Duration(
      milliseconds: 100,
    ); // Update every 100ms for smooth animation

    _progressTimer = Timer.periodic(timerInterval, (timer) {
      elapsedMilliseconds += 100;

      // Calculate progress (0.0 to 1.0)
      progressValue.value = (elapsedMilliseconds / totalMilliseconds).clamp(
        0.0,
        1.0,
      );

      // Stop timer when progress reaches 100%
      if (progressValue.value >= 1.0) {
        _stopProgressTimer();
      }
    });

    logger.i('Progress timer started: $totalSeconds seconds');
  }

  /// Stop progress timer
  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  // ================= MOCK =================
  void fetchOrders() {
    orders.clear();
  }
}

// ------------------- SOCKET INIT -------------------
