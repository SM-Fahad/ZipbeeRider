// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use

import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
import 'package:ZipBee_Driver/features/scan_and_pay/screen/scan_and_pay_screen.dart';
import 'package:ZipBee_Driver/features/unload1/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OrderScreen extends StatelessWidget {
  final OrderController ctrl = Get.put(OrderController());

  OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double leftGap = 12;
    double maxDrag = width - 80;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.onboardingIndicatorActive,
        elevation: 0,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          "Unload",
          style: getTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),

      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),

              /// Title Bar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Unload Item’s',
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              /// Grid
              Expanded(
                child: Obx(
                  () => GridView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: ctrl.images.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.grey.shade200,
                          image: DecorationImage(
                            image: AssetImage(ctrl.images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // DRAGGABLE SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.20,
            minChildSize: 0.20,
            maxChildSize: 0.72,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      Center(
                        child: Container(
                          height: 5,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 18),

                      /// Rider Profile
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(ImagePath.profile),
                          ),
                          SizedBox(width: 12),
                          Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ctrl.riderName.value,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${ctrl.pastOrders.value} Past Orders",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18),

                      /// Message + Call
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.message),
                              label: Text("Message (1)"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.call),
                              label: Text("Call"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      /// Order Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Order Confirmed",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "EXPRESS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(Icons.bolt, size: 18, color: Colors.orange),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 18),

                      /// Pickup Locations
                      Obx(
                        () => Column(
                          children: ctrl.pickupLocations.map((loc) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 14),
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    loc["isActive"] == true
                                        ? IconPath.location_blue
                                        : IconPath.location_red,
                                    height: 18,
                                  ),
                                  SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                loc["title"],
                                                style: getTextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            if (loc["tag"] != "")
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  loc["tag"],
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),

                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                loc["address"],
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                            if (loc["subTag"] != "")
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  loc["subTag"],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 10),

                      /// Slide to Unload
                      Obx(() {
                        double progress = (ctrl.dragX.value / maxDrag).clamp(
                          0.0,
                          1.0,
                        );

                        Color backgroundColor = Color.lerp(
                          AppColors.onboardingIndicatorActive,
                          Colors.blue.shade200,
                          progress,
                        )!;

                        double textOpacity = 1.0 - progress;

                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 68,
                              width: width,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),

                            // Text Fade Effect
                            Opacity(
                              opacity: textOpacity,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 26),
                                child: Row(
                                  children: [
                                    SizedBox(width: 54),
                                    Text(
                                      "Completed",
                                      style: getTextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Slider Handle
                            Positioned(
                              left: ctrl.dragX.value + leftGap,
                              top: 12,
                              bottom: 12,
                              child: GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  ctrl.dragX.value += details.delta.dx;

                                  if (ctrl.dragX.value < 0)
                                    ctrl.dragX.value = 0;
                                  if (ctrl.dragX.value > maxDrag)
                                    ctrl.dragX.value = maxDrag;
                                },

                                onHorizontalDragEnd: (details) {
                                  if (ctrl.dragX.value >= maxDrag - 5) {
                                    Get.to(() => ScanAndPayScreen());

                                    Future.delayed(
                                      Duration(milliseconds: 300),
                                      () => ctrl.resetSlider(),
                                    );
                                  } else {
                                    ctrl.resetSlider();
                                  }
                                },

                                child: Container(
                                  height: 44,
                                  width: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      IconPath.playicon,
                                      height: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                      SizedBox(height: 22),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
