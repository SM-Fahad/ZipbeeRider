// ignore_for_file: deprecated_member_use

import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/driver_preference/distance_radius/controller/distance_radius_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ZipBee_Driver/core/utils/custom_map_marker_helper.dart';



class DistanceRadiusScreen extends StatelessWidget {
  final DistanceRadiusController ctrl = Get.put(DistanceRadiusController());

  DistanceRadiusScreen({super.key});

  final String argumentsRank = Get.arguments ?? 'null';

  @override
  Widget build(BuildContext context) {
    debugPrint("  argumentsRank: $argumentsRank");
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primaryFontColor,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: Text(
            "Distance",
            style: TextStyle(
              color: AppColors.primaryFontColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          // actions: [
          //   Obx(
          //     () => Switch(
          //       value: ctrl.isOffline.value,
          //       onChanged: ctrl.toggleOffline,
          //       activeThumbColor: Colors.black,
          //     ),
          //   ),
          // ],
        ),
      ),
      body: Stack(
        children: [
          // Real Google Map
          Obx(() {
            if (ctrl.isLoadingLocation.value) {
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (ctrl.currentLocation.value == null) {
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 40),
                      SizedBox(height: 8),
                      Text('Location not available'),
                    ],
                  ),
                ),
              );
            }

            return GoogleMap(
              mapType: MapType.normal,
              onMapCreated: ctrl.onMapCreated,
              initialCameraPosition: CameraPosition(
                target: ctrl.currentLocation.value!,
                zoom: 15,
              ),
              markers: ctrl.markerIcon.value == null
                  ? <Marker>{}
                  : {
                      Marker(
                        markerId: MarkerId(
                          'current_location_${ctrl.markerIcon.value.hashCode}',
                        ),
                        position: ctrl.currentLocation.value!,
                        anchor: CustomMapMarkerHelper.defaultAnchor,
                        infoWindow: InfoWindow(
                          title: 'Your Location',
                        ),
                        icon: ctrl.markerIcon.value!,
                      ),
                    },
              // ignore: invalid_use_of_protected_member
              circles: ctrl.circles.value.toSet(),
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
            );
          }),

          // Zoom controls
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add,
                  onTap: ctrl.zoomIn,
                ),
                const SizedBox(height: 10),
                _buildZoomButton(
                  icon: Icons.remove,
                  onTap: ctrl.zoomOut,
                ),
              ],
            ),
          ),

          // Bottom radius controller
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: ctrl.decreaseRadius,
                          borderRadius: BorderRadius.circular(40),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: AppColors.onboardingIndicatorActive,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors.transparent,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: AppColors.primaryFontColor,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IntrinsicWidth(
                                child: TextFormField(
                                  controller: ctrl.radiusTextController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    final parsed = double.tryParse(value.trim());
                                    if (parsed != null) {
                                      ctrl.setRadiusFromText(parsed);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Km',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40),

                        InkWell(
                          onTap: ctrl.increaseRadius,
                          borderRadius: BorderRadius.circular(40),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: AppColors.onboardingIndicatorActive,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors.transparent,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.primaryFontColor,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: AppColors.onboardingIndicatorActive,
                      minimumSize: const Size(290, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      ctrl.updateRadius();
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}
