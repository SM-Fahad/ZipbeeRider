import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../controller/login_controller.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.textController,
    required this.selectedCountryCode,
    this.onClear,
    this.initialSelection = 'SG',
    this.favorite = const ['+65'],
    this.hintText = 'Enter phone number',
  });

  final TextEditingController textController;
  final RxString selectedCountryCode;
  final VoidCallback? onClear;
  final String initialSelection;
  final List<String> favorite;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: textController,
      builder: (context, value, _) => Container(
        height: 52,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.subtitleFontColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CountryCodePicker(
              onChanged: (country) {
                selectedCountryCode.value = country.dialCode ?? '+65';
              },
              initialSelection: initialSelection,
              favorite: favorite,
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
            ),
            Container(
              width: 1,
              height: 32,
              color: Colors.grey.shade400,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            Expanded(
              child: TextField(
                controller: textController,
                keyboardType: TextInputType.phone,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  isDense: true,
                  suffixIcon: value.text.isNotEmpty
                      ? GestureDetector(
                          onTap: onClear ?? textController.clear,
                          child: const Icon(Icons.clear_outlined, size: 20),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneField extends StatelessWidget {
  const PhoneField({super.key, required this.controller});

  final LoginSignupController controller;

  @override
  Widget build(BuildContext context) {
    return PhoneInputField(
      textController: controller.phoneController,
      selectedCountryCode: controller.selectedCountryCode,
      onClear: controller.clearPhone,
    );
  }
}
