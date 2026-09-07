import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/features/profile/change_password/screen/change_password_screen.dart';
import 'package:ZipBee_Driver/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              "Profile",
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Name
              label("Raider Name*"),
              inputBox(controller.raiderName),

              const SizedBox(height: 15),

              /// Mobile Number
              label("Mobile Number*"),
              inputBox(controller.contactNumber),

              const SizedBox(height: 15),

              /// Email Address
              label("Email Address*"),
              inputBox(controller.emailAddress),

              const SizedBox(height: 15),

              /// Date of Birth
              label("Date of Birth*"),
              inputBox(controller.dob, readOnly: true),

              const SizedBox(height: 15),

              /// Gender
              label("Gender*"),
              _buildGenderDropdown(),

              const SizedBox(height: 15),

              /// Emergency Contact Name
              label("Emergency Contact Name*"),
              inputBox(controller.emergencyContactName),

              const SizedBox(height: 15),

              /// Emergency Contact Number
              label("Emergency Contact Number*"),
              inputBox(controller.emergencyContactNumber),

              const SizedBox(height: 25),

              /// Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Change Password
              InkWell(
                onTap: () => Get.to(() => ChangePasswordScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              /// Delete Account
              GestureDetector(
                onTap: controller.deleteProfile,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      "Delete Account",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Obx(
        () => DropdownButtonFormField<String>(
          value: controller.gender.value.isEmpty
              ? null
              : controller.gender.value,
          items: ['MALE', 'FEMALE', 'OTHER']
              .map(
                (gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)),
              )
              .toList(),
          onChanged: (value) => controller.gender.value = value ?? '',
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            isDense: true,
          ),
          hint: const Text('Select Gender'),
        ),
      ),
    );
  }

  Widget label(String text) => Text(
    text,
    style: getTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );

  Widget inputBox(
    TextEditingController textController, {
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: textController,
        readOnly: readOnly,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
