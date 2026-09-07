import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:ZipBee_Driver/core/services/external_launcher_service.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import '../controller/order_process_controller.dart';

class NavigationGuidelineScreen extends StatelessWidget {
  const NavigationGuidelineScreen({super.key});

  Color _getOrderColor(OrderModel? order) {
    if (order == null) {
      return AppColors.onboardingIndicatorActive;
    }

    final isCompleted =
        order.isCompleted || order.orderStatus.toUpperCase() == 'COMPLETED';
    if (isCompleted) {
      return Colors.grey.shade100;
    }

    return OrderColorHelper.getOrderBackgroundColor(
      collectTime: order.collectTime,
      scheduledTime: order.scheduledTime,
      placedAt: order.placedAt,
      defaultColor: AppColors.onboardingIndicatorActive,
      order: order,
    );
  }

  /// Maps Google Navigation Maneuver enums to appropriate Material Icons
  IconData _getManeuverIcon(Maneuver? maneuver) {
    if (maneuver == null) return Icons.directions;
    switch (maneuver) {
      case Maneuver.turnLeft:
      case Maneuver.offRampLeft:
      case Maneuver.onRampLeft:
        return Icons.turn_left;
      case Maneuver.turnRight:
      case Maneuver.offRampRight:
      case Maneuver.onRampRight:
        return Icons.turn_right;
      case Maneuver.turnSharpLeft:
      case Maneuver.roundaboutSharpLeftClockwise:
      case Maneuver.roundaboutSharpLeftCounterclockwise:
        return Icons.turn_sharp_left;
      case Maneuver.turnSharpRight:
      case Maneuver.roundaboutSharpRightClockwise:
      case Maneuver.roundaboutSharpRightCounterclockwise:
        return Icons.turn_sharp_right;
      case Maneuver.turnSlightLeft:
      case Maneuver.offRampSlightLeft:
      case Maneuver.onRampSlightLeft:
      case Maneuver.forkLeft:
      case Maneuver.mergeLeft:
        return Icons.turn_slight_left;
      case Maneuver.turnSlightRight:
      case Maneuver.offRampSlightRight:
      case Maneuver.onRampSlightRight:
      case Maneuver.forkRight:
      case Maneuver.mergeRight:
        return Icons.turn_slight_right;
      case Maneuver.turnUTurnClockwise:
      case Maneuver.turnUTurnCounterclockwise:
      case Maneuver.offRampUTurnClockwise:
      case Maneuver.offRampUTurnCounterclockwise:
      case Maneuver.onRampUTurnClockwise:
      case Maneuver.onRampUTurnCounterclockwise:
      case Maneuver.roundaboutUTurnClockwise:
      case Maneuver.roundaboutUTurnCounterclockwise:
        return Icons.u_turn_left;
      case Maneuver.roundaboutClockwise:
      case Maneuver.roundaboutCounterclockwise:
      case Maneuver.roundaboutExitClockwise:
      case Maneuver.roundaboutExitCounterclockwise:
      case Maneuver.roundaboutLeftClockwise:
      case Maneuver.roundaboutLeftCounterclockwise:
      case Maneuver.roundaboutRightClockwise:
      case Maneuver.roundaboutRightCounterclockwise:
      case Maneuver.roundaboutStraightClockwise:
      case Maneuver.roundaboutStraightCounterclockwise:
        return Icons.roundabout_left;
      case Maneuver.destination:
      case Maneuver.destinationLeft:
      case Maneuver.destinationRight:
        return Icons.pin_drop;
      case Maneuver.straight:
      case Maneuver.depart:
      case Maneuver.nameChange:
      case Maneuver.offRampKeepLeft:
      case Maneuver.offRampKeepRight:
      case Maneuver.offRampUnspecified:
      case Maneuver.onRampKeepLeft:
      case Maneuver.onRampKeepRight:
      case Maneuver.onRampUnspecified:
      case Maneuver.turnKeepLeft:
      case Maneuver.turnKeepRight:
      case Maneuver.mergeUnspecified:
      case Maneuver.ferryBoat:
      case Maneuver.ferryTrain:
      case Maneuver.unknown:
      default:
        return Icons.straight;
    }
  }

  /// Formats distance in meters into human-readable string
  String _formatDistance(int? meters) {
    if (meters == null || meters <= 0) return '';
    if (meters < 1000) {
      return '$meters m';
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return '$km km';
  }

  /// Formats time in seconds into human-readable string
  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final minutes = (seconds / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remMin = minutes % 60;
    return '${hours}h ${remMin}m';
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required Color iconColor,
    required String instruction,
    required String distance,
    required bool isLast,
    String? roadName,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  instruction,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
                if (roadName != null && roadName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    roadName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
                if (distance.isNotEmpty && !isLast) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        distance,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.12),
                          thickness: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Turn-by-Turn Road-wise instructions bottom sheet
  void _showRouteInstructionsBottomSheet(
    BuildContext context,
    OrderProcessController controller,
  ) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF18181B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final stop = controller.selectedStop.value;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Text(
                      stop != null
                          ? (stop.isPickup
                              ? 'Pickup Road Guidance'
                              : 'Delivery Road Guidance')
                          : 'Turn-by-Turn Guidance',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              );
            }),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: Obx(() {
                final navInfo = controller.currentNavInfo.value;
                final currentStep = navInfo?.currentStep;
                final remainingSteps = navInfo?.remainingSteps ?? [];

                if (currentStep == null && remainingSteps.isEmpty) {
                  // Fallback to stop list if NavInfo has not streamed yet
                  final stops = controller.stopList;
                  if (stops.isEmpty) {
                    return const Center(
                      child: Text(
                        'No active turn instructions',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(
                      top: 8,
                      bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                    ),
                    itemCount: stops.length,
                    itemBuilder: (context, index) {
                      final stop = stops[index];
                      return _buildInstructionItem(
                        icon: stop.isPickup
                            ? Icons.store
                            : Icons.person_pin_circle,
                        iconColor: Colors.white,
                        instruction:
                            '${stop.isPickup ? "Pickup" : "Drop"} Stop: ${stop.address}',
                        distance: '',
                        isLast: index == stops.length - 1,
                      );
                    },
                  );
                }

                // Render live SDK turn steps
                final allSteps = <StepInfo>[];
                if (currentStep != null) {
                  allSteps.add(currentStep);
                }
                allSteps.addAll(remainingSteps);

                return ListView.builder(
                  padding: EdgeInsets.only(
                    top: 12,
                    bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                  ),
                  itemCount: allSteps.length,
                  itemBuilder: (context, index) {
                    final step = allSteps[index];
                    final isFirst = index == 0;
                    final isLast = index == allSteps.length - 1;
                    final icon = _getManeuverIcon(step.maneuver);
                    final instruction = (step.fullInstructions != null &&
                            step.fullInstructions!.trim().isNotEmpty)
                        ? step.fullInstructions!
                        : (step.fullRoadName ?? 'Continue straight');
                    final distanceText = isFirst
                        ? _formatDistance(navInfo?.distanceToCurrentStepMeters)
                        : _formatDistance(step.distanceFromPrevStepMeters);

                    return _buildInstructionItem(
                      icon: icon,
                      iconColor: isFirst ? const Color(0xFF4CAF50) : Colors.white,
                      instruction: isFirst ? 'Next: $instruction' : instruction,
                      roadName: step.fullRoadName,
                      distance: distanceText,
                      isLast: isLast,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  /// Stops Sequence Bottom Sheet
  void _showAllRoutesBottomSheet(
    BuildContext context,
    OrderProcessController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stops Sequence',
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: Scrollbar(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.sortedStops.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final stop = controller.sortedStops[index];
                    final isCurrent =
                        controller.selectedStop.value?.id == stop.id;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: isCurrent
                            ? _getOrderColor(controller.orderDetail.value)
                            : Colors.grey.shade200,
                        foregroundColor: isCurrent
                            ? Colors.black
                            : Colors.grey.shade800,
                        child: Text(
                          '${stop.sequence}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        stop.isPickup ? 'Pickup' : 'Drop-off',
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isCurrent
                              ? Colors.black
                              : Colors.grey.shade800,
                        ),
                      ),
                      subtitle: Text(
                        stop.address,
                        style: getTextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Icon(
                        stop.isCompleted
                            ? Icons.check_circle
                            : stop.isFailed
                            ? Icons.error
                            : Icons.radio_button_unchecked,
                        color: stop.isCompleted
                            ? Colors.green
                            : stop.isFailed
                            ? Colors.red
                            : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final OrderProcessController controller =
        Get.find<OrderProcessController>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, result) async {
        if (didPop) {
          await controller.stopInAppNavigation();
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              // 1. Google Maps Navigation SDK View
              Positioned.fill(
                child: GoogleMapsNavigationView(
                  onViewCreated: (GoogleNavigationViewController navCtrl) async {
                    controller.navigationViewController = navCtrl;
                    try {
                      // Enable visual live location indicator
                      await navCtrl.setMyLocationEnabled(true);

                      // Trigger turn-by-turn voice and directional guidance
                      await GoogleMapsNavigator.startGuidance();

                      // Setup listener to capture road-wise turn instructions stream
                      controller.startListeningToNavInfo();
                    } catch (e) {
                      debugPrint('Error starting guidance on view created: $e');
                    }
                  },
                  initialNavigationUIEnabledPreference:
                      NavigationUIEnabledPreference.automatic,
                ),
              ),

              // 2. Dynamic Turn-by-Turn Maneuver Overlay Card (Top)
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Obx(() {
                  final navInfo = controller.currentNavInfo.value;
                  final currentStep = navInfo?.currentStep;
                  final selectedStop = controller.selectedStop.value;

                  final nextDistance = _formatDistance(
                    navInfo?.distanceToCurrentStepMeters,
                  );
                  final etaTime = _formatDuration(
                    navInfo?.timeToNextDestinationSeconds ??
                        navInfo?.timeToFinalDestinationSeconds,
                  );
                  final etaDistance = _formatDistance(
                    navInfo?.distanceToNextDestinationMeters ??
                        navInfo?.distanceToFinalDestinationMeters,
                  );

                  final instruction = (currentStep?.fullInstructions != null &&
                          currentStep!.fullInstructions!.trim().isNotEmpty)
                      ? currentStep.fullInstructions!
                      : (currentStep?.fullRoadName ??
                          (selectedStop != null
                              ? 'Navigating to ${selectedStop.isPickup ? "Pickup" : "Drop"} Stop'
                              : 'Navigating to destination'));

                  final maneuverIcon = _getManeuverIcon(currentStep?.maneuver);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                maneuverIcon,
                                color: const Color(0xFF38BDF8),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (nextDistance.isNotEmpty) ...[
                                    Text(
                                      'In $nextDistance',
                                      style: const TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    instruction,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _showRouteInstructionsBottomSheet(
                                  context,
                                  controller,
                                );
                              },
                              icon: const Icon(
                                Icons.format_list_bulleted,
                                color: Colors.white70,
                                size: 22,
                              ),
                              tooltip: 'Turn Instructions',
                            ),
                          ],
                        ),
                        if (etaTime.isNotEmpty || etaDistance.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_filled,
                                      color: Color(0xFF4ADE80),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      etaTime.isNotEmpty ? etaTime : 'Calculating...',
                                      style: const TextStyle(
                                        color: Color(0xFF4ADE80),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    if (etaDistance.isNotEmpty) ...[
                                      const Text(
                                        ' • ',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        etaDistance,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (selectedStop != null)
                                  Text(
                                    'Stop ${controller.currentStopNumber}/${controller.sortedStops.length}',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),

              // 3. Floating Action Buttons (Re-center / Follow GPS)
              Positioned(
                right: 16,
                bottom: 220,
                child: FloatingActionButton(
                  heroTag: 'recenter_nav_btn',
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.black87,
                    size: 20,
                  ),
                  onPressed: () {
                    try {
                      controller.navigationViewController?.followMyLocation(
                        CameraPerspective.tilted,
                      );
                    } catch (e) {
                      debugPrint('Could not recenter camera: $e');
                    }
                  },
                ),
              ),

              // 4. Collapsible Bottom Panel for Current Stop Details & Actions
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Obx(() {
                  final isExpanded = controller.isBottomPanelExpanded.value;
                  final stop = controller.selectedStop.value;
                  if (stop == null) return const SizedBox.shrink();

                  final displayPhone =
                      stop.destinationContactNumber.isNotEmpty
                          ? stop.destinationContactNumber
                          : controller.customerPhone;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta! < -7) {
                        controller.isBottomPanelExpanded.value = true;
                      } else if (details.primaryDelta! > 7) {
                        controller.isBottomPanelExpanded.value = false;
                      }
                    },
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  controller.isBottomPanelExpanded.toggle();
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 28,
                                  alignment: Alignment.center,
                                  color: Colors.transparent,
                                  child: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_up,
                                    color: Colors.grey.shade600,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                            if (!isExpanded) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: stop.isPickup
                                                    ? Colors.blue.shade50
                                                    : Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Stop ${controller.currentStopNumber}/${controller.sortedStops.length}',
                                                style: getTextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: stop.isPickup
                                                      ? Colors.blue.shade700
                                                      : Colors.green.shade700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              stop.isPickup
                                                  ? 'Pickup'
                                                  : 'Drop-off',
                                              style: getTextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          stop.address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: getTextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (displayPhone.isNotEmpty)
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.green.shade50,
                                        foregroundColor: Colors.green.shade700,
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      icon: const Icon(Icons.call, size: 22),
                                      onPressed: () {
                                        ExternalLauncherService.openDialer(
                                          displayPhone,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                            if (isExpanded) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: stop.isPickup
                                                  ? Colors.blue.shade100
                                                  : Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Stop ${controller.currentStopNumber} of ${controller.sortedStops.length}',
                                              style: getTextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: stop.isPickup
                                                    ? Colors.blue.shade800
                                                    : Colors.green.shade800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              stop.isPickup
                                                  ? 'Pickup'
                                                  : 'Drop-off',
                                              style: getTextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          stop.destinationContactName
                                                  .trim()
                                                  .isNotEmpty
                                              ? stop.destinationContactName
                                              : 'No name available',
                                          style: getTextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          stop.address,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: getTextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            _showAllRoutesBottomSheet(
                                              context,
                                              controller,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.alt_route,
                                            size: 18,
                                          ),
                                          label: const Text('Routes'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                Colors.blue.shade700,
                                            side: BorderSide(
                                              color: Colors.blue.shade300,
                                            ),
                                            padding:
                                                const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      if (displayPhone.isNotEmpty)
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              ExternalLauncherService.openDialer(
                                                displayPhone,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.phone,
                                              size: 18,
                                            ),
                                            label: const Text('Call'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await controller.stopInAppNavigation();
                                  Get.back();
                                },
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: Text(
                                  'Back to Overview',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _getOrderColor(controller.orderDetail.value),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
