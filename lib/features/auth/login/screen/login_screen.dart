import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
import 'package:ZipBee_Driver/features/auth/login/controller/login_controller.dart';
import 'package:ZipBee_Driver/features/auth/login/widgets/password_field_widget.dart';
import 'package:ZipBee_Driver/features/auth/login/widgets/phone_field_widget.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginSignupScreen extends StatelessWidget {
  const LoginSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginSignupController>(
      init: LoginSignupController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Container(
                    height: 205,
                    width: 375,
                    margin: EdgeInsets.only(bottom: 20),
                    child: ClipRRect(
                      child: Image.asset(ImagePath.background2, fit: BoxFit.cover),
                    ),
                  ),

                  // Floating Shadow Box
                  Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(12),
                    shadowColor: Colors.black38,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(() {
                        final isLogin = controller.isLoginSelected.value;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Login / Signup Toggle
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.fromLTRB(
                                isLogin ? 6 : 12,
                                6,
                                isLogin ? 12 : 6,
                                6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.subtitleFontColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => controller.toggleSelection(true),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLogin
                                            ? AppColors.primaryButtonColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Login',
                                        style: getTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => controller.toggleSelection(false),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: !isLogin
                                            ? AppColors.primaryButtonColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Sign Up',
                                        style: getTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                            // Login/Signup Form Section
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 400),
                              child: isLogin
                                  ? buildLoginFields(controller)
                                  : buildSignupFields(controller),
                            ),

                            SizedBox(height: 20),

                            // Main Button
                            ElevatedButton(
                              onPressed: () {
                                if (controller.isLoginSelected.value) {
                                  controller.onLoginPressed();
                                } else {
                                  controller.onSignUpContinuePressed();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryButtonColor,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                isLogin ? 'Login' : 'Continue',
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            if (isLogin) ...[
                              SizedBox(height: 15),
                              OutlinedButton(
                                onPressed: () {
                                  controller.toggleSelection(false);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: Size(double.infinity, 50),
                                  side: BorderSide(color: Colors.black, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Register",
                                  style: getTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                    ),
                  ),

                  // Terms & Conditions (Outside Box)
                  Obx(() {
                    if (controller.isLoginSelected.value) {
                      return SizedBox.shrink();
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: getTextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                              children: [
                                TextSpan(
                                  text: "By clicking continue, you agree to our ",
                                ),
                                TextSpan(
                                  text: "Terms and Conditions",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.black,
                                    decorationThickness: 2.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------- LOGIN FIELDS ----------------------
  Widget buildLoginFields(LoginSignupController controller) {
    return Column(
      key: ValueKey('loginFields'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your email, phone or username',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        buildTextField(
          controller.emailController,
          'Email, Phone or Username',
          keyboardType: TextInputType.text,
          prefixIcon: Icons.person_outline,
        ),
        SizedBox(height: 20),
        Text(
          'Password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        PasswordField(controller: controller.passwordController),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.forgotPasswordScreen),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onboardingIndicatorActive,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryButtonColor,
                decorationThickness: 2.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------- SIGNUP FIELDS ----------------------
  Widget buildSignupFields(LoginSignupController controller) {
    return Column(
      key: ValueKey('signupFields'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your User Name',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        buildTextField(
          controller.nameController,
          'Your Name',
          prefixIcon: Icons.person,
        ),
        SizedBox(height: 10),
        Text(
          'Your e-mail address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        buildTextField(
          controller.emailController,
          'Your e-mail address',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email,
        ),
        SizedBox(height: 10),
        Text(
          'Mobile Number',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        PhoneField(controller: controller),
        SizedBox(height: 10),
        Text(
          'Referral Code (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        buildTextField(
          controller.referralCodeController,
          'Referral Code',
          prefixIcon: Icons.card_giftcard,
        ),
        SizedBox(height: 10),
        Text(
          'Enter your password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        PasswordField(controller: controller.passwordController),
        SizedBox(height: 10),
        Text(
          'Confirm your password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        PasswordField(controller: controller.confirmPasswordController),
      ],
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return Container(
      height: 50,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.subtitleFontColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            isDense: true,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: Colors.grey.shade700)
                : null,
          ),
        ),
      ),
    );
  }
}
