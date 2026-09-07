import 'package:ZipBee_Driver/features/auth/login/controller/profile_check_controller.dart';
import 'package:ZipBee_Driver/features/auth/login/widgets/profile_check.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileCheckScreen extends StatelessWidget {
  ProfileCheckScreen({super.key});

  final ProfileCheckController controller =
      Get.isRegistered<ProfileCheckController>()
      ? Get.find<ProfileCheckController>()
      : Get.put(ProfileCheckController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF1),
      body: ProfileCheck(controller: controller),
    );
  }
}
