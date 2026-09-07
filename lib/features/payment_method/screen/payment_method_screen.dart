// ignore_for_file: deprecated_member_use

import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/features/account/controller/account_controller.dart';
import 'package:ZipBee_Driver/features/payment_method/controller/payment_method_controller.dart';
import 'package:ZipBee_Driver/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodScreen extends StatelessWidget {
  final PaymentMethodController controller = Get.put(PaymentMethodController());
  final AccountController accountController = Get.put(AccountController());
  final ProfileController profileCtrl = Get.put(ProfileController());

  PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: Get.back,
            ),
            title: Text(
              "Wallet",
              style: getTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),

      // ---------------- BODY ----------------
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),

            // ---------- BALANCE ----------
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryButtonColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Total Balance",
                      style: getTextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),

                    // ---------- FIXED OBX ----------
                    Obx(
                      () => Text(
                        "\$${controller.currentWalletBalance.value.toStringAsFixed(2)}",
                        style: getTextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- ACTION BUTTONS ----------
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    actionButton(IconPath.topup, "Top Up", controller.topUp),
                    actionButton(
                      IconPath.withdraw,
                      "Withdraw",
                      controller.withdraw,
                    ),
                    actionButton(
                      IconPath.receive,
                      "Receive",
                      controller.received,
                    ),
                    actionButton(
                      IconPath.statement,
                      "Statistics",
                      controller.Statistics,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),

            // ---------- BANK DETAILS ----------
            Obx(() {
              final bool hasStripe =
                  accountController.stripeAccountId.value.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: hasStripe ? null : controller.connectBankDetails,
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance, color: Colors.black),
                              SizedBox(width: 10),
                              Text(
                                "Bank details",
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          // যদি স্ট্রাইপ না থাকে তবে 'Add Stripe' বাটন দেখাবে
                          if (!hasStripe)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .primaryButtonColor, // আপনার অ্যাপের প্রাইমারি কালার
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Add Stripe",
                                style: getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: controller.resetStripe,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Reset Stripe",
                                  style: getTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Stripe Status Message
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      hasStripe
                          ? "Connected Stripe Account ID: ${accountController.stripeAccountId.value}"
                          : "No Stripe account connected",
                      style: getTextStyle(
                        fontSize: 13,
                        color: hasStripe ? Colors.green : Colors.black54,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // Bank details box (Profile Data)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          dense: true,
                          title: Text(
                            "Bank Name",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            profileCtrl.bankNameRx.value.isEmpty
                                ? "Not Provided"
                                : profileCtrl.bankNameRx.value,
                          ),
                        ),
                        Divider(height: 1, indent: 15, endIndent: 15),
                        ListTile(
                          dense: true,
                          title: Text(
                            "Account Number",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            profileCtrl.accountNumberRx.value.isEmpty
                                ? "Not Provided"
                                : profileCtrl.accountNumberRx.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---------- ACTION BUTTON WIDGET ----------
  Widget actionButton(String iconPath, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 22,
            child: Image.asset(iconPath, width: 24, height: 24),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
