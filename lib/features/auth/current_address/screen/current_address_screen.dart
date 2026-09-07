import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/auth/current_address/controller/current_address_controller.dart';
import 'package:ZipBee_Driver/features/auth/current_address/widget/address_picker_dialog.dart';
import 'package:ZipBee_Driver/features/auth/login/controller/profile_check_controller.dart';
import 'package:ZipBee_Driver/features/auth/registration/controller/registration_controller.dart';
import 'package:ZipBee_Driver/features/google_map/service/one_map_service.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class CurrentAddressScreen extends StatelessWidget {
  final CurrentAddressController controller = Get.put(
    CurrentAddressController(),
  );
  final regCtrl = Get.put(RegistrationController(), tag: 'registration');

  CurrentAddressScreen({super.key});

  String _buildInitialQuery(
    TextEditingController postalController,
    TextEditingController addressController,
  ) {
    final postal = postalController.text.trim();
    if (postal.isNotEmpty) return postal;
    return addressController.text.trim();
  }

  Future<void> _openAddressPicker({
    required BuildContext context,
    required String title,
    required TextEditingController postalController,
    required TextEditingController addressController,
    required ValueChanged<OneMapResolvedAddress> onSelected,
  }) async {
    final resolved = await showDialog<OneMapResolvedAddress>(
      context: context,
      builder: (_) => AddressPickerDialog(
        title: title,
        initialQuery: _buildInitialQuery(postalController, addressController),
      ),
    );

    if (resolved != null) {
      onSelected(resolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Registration',
          style: getTextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------------- STEP INDICATOR ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: index == 0 ? 0 : 4,
                    ),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index <= 4
                          ? AppColors.onboardingIndicatorActive
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 26),

            // Current Address section--
            // -------------------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Current Address",
                    style: getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: 4),

                label("Postal Code*"),
                pickerInput(
                  context: context,
                  controller: controller.currentZipController,
                  hint: "Select Postal Code",
                  onTap: () => _openAddressPicker(
                    context: context,
                    title: 'Select Current Address',
                    postalController: controller.currentZipController,
                    addressController: controller.currentAddressController,
                    onSelected: controller.setCurrentResolvedAddress,
                  ),
                ),

                label("Address*"),
                pickerInput(
                  context: context,
                  controller: controller.currentAddressController,
                  hint: "Select your address",
                  onTap: () => _openAddressPicker(
                    context: context,
                    title: 'Select Current Address',
                    postalController: controller.currentZipController,
                    addressController: controller.currentAddressController,
                    onSelected: controller.setCurrentResolvedAddress,
                  ),
                ),

                label("Apartment, Suite, Unit, Building, Floor, etc"),
                input(
                  controller.currentApartmentController,
                  "Apartment, suite, unit",
                ),

                // label("State/Province*"),
                // Obx(
                //   () => dropdown(
                //     value: controller.currentState.value.isEmpty
                //         ? null
                //         : controller.currentState.value,
                //     items: controller.stateList,
                //     onChanged: (v) => controller.currentState.value = v ?? '',
                //   ),
                // ),
                label("Country*"),
                Obx(
                  () => countryDropdown(
                    context: context,
                    value: controller.currentCountry.value,
                    items: controller.availableCountries,
                    onChanged: (value) {
                      if (value == null) return;
                      controller.currentCountry.value = value;
                      if (controller.sameAsCurrent.value) {
                        controller.permanentCountry.value = value;
                      }
                    },
                  ),
                ),
                SizedBox(height: 25),

                Center(
                  child: Text(
                    "Permanent Address",
                    style: getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            //  PERMANENT ADDRESS SECTION
            // -------------------------------------------
            SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Row(
                    children: [
                      Text(
                        "Same as Current Address",
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          shape: CircleBorder(),
                          activeColor: AppColors.onboardingIndicatorActive,
                          value: controller.sameAsCurrent.value,
                          onChanged: (value) =>
                              controller.copyCurrentToPermanent(value ?? false),
                        ),
                      ),
                    ],
                  ),
                ),

                label("Postal Code*"),
                Obx(
                  () => pickerInput(
                    context: context,
                    controller: controller.permanentZipController,
                    hint: "Select Postal Code",
                    enabled: !controller.sameAsCurrent.value,
                    onTap: !controller.sameAsCurrent.value
                        ? () => _openAddressPicker(
                            context: context,
                            title: 'Select Permanent Address',
                            postalController: controller.permanentZipController,
                            addressController:
                                controller.permanentAddressController,
                            onSelected: controller.setPermanentResolvedAddress,
                          )
                        : null,
                  ),
                ),

                label("Address*"),
                Obx(
                  () => pickerInput(
                    context: context,
                    controller: controller.permanentAddressController,
                    hint: "Select Address",
                    enabled: !controller.sameAsCurrent.value,
                    onTap: !controller.sameAsCurrent.value
                        ? () => _openAddressPicker(
                            context: context,
                            title: 'Select Permanent Address',
                            postalController: controller.permanentZipController,
                            addressController:
                                controller.permanentAddressController,
                            onSelected: controller.setPermanentResolvedAddress,
                          )
                        : null,
                  ),
                ),

                label("Apartment, Suite, Unit, Building, Floor, etc*"),
                Obx(
                  () => input(
                    controller.permanentApartmentController,
                    "Enter Apartment",
                    enabled: !controller.sameAsCurrent.value,
                  ),
                ),

                // label("State/Province*"),
                // Obx(
                //   () => dropdown(
                //     value: controller.permanentState.value.isEmpty
                //         ? null
                //         : controller.permanentState.value,
                //     items: controller.stateList,
                //     onChanged: controller.sameAsCurrent.value
                //         ? null
                //         : (v) => controller.permanentState.value = v ?? '',
                //   ),
                // ),
                label("Country*"),
                Obx(
                  () => countryDropdown(
                    context: context,
                    value: controller.permanentCountry.value,
                    items: controller.availableCountries,
                    enabled: !controller.sameAsCurrent.value,
                    onChanged: controller.sameAsCurrent.value
                        ? null
                        : (value) {
                            if (value != null) {
                              controller.permanentCountry.value = value;
                            }
                          },
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Bank Details",
                    style: getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // SizedBox(height: 12),
                label("Bank Name*"),
                input(controller.bankNameController, "Enter Bank Name"),

                label("Account Number*"),
                input(
                  controller.accountNumberController,
                  "Enter Account Number",
                ),
              ],
            ),

            SizedBox(height: 30),

            Obx(
              () => SizedBox(
                width: width,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (controller.currentZipController.text.trim().isEmpty) {
                      EasyLoading.showError('Please enter current postal code');
                      return;
                    }
                    if (controller.currentAddressController.text
                        .trim()
                        .isEmpty) {
                      EasyLoading.showError('Please enter current address');
                      return;
                    }
                    if (controller.currentCountry.value.trim().isEmpty) {
                      EasyLoading.showError('Please select current country');
                      return;
                    }
                    if (controller.permanentZipController.text.trim().isEmpty) {
                      EasyLoading.showError(
                        'Please enter permanent postal code',
                      );
                      return;
                    }
                    if (controller.permanentAddressController.text
                        .trim()
                        .isEmpty) {
                      EasyLoading.showError('Please enter permanent address');
                      return;
                    }
                    if (controller.permanentCountry.value.trim().isEmpty) {
                      EasyLoading.showError('Please select permanent country');
                      return;
                    }
                    if (controller.bankNameController.text.trim().isEmpty) {
                      EasyLoading.showError('Please enter bank name');
                      return;
                    }
                    if (controller.accountNumberController.text
                        .trim()
                        .isEmpty) {
                      EasyLoading.showError('Please enter account number');
                      return;
                    }

                    // populate address fields
                    regCtrl.currentAddress.value = controller
                        .currentAddressController
                        .text
                        .trim();
                    regCtrl.currentApartment.value = controller
                        .currentApartmentController
                        .text
                        .trim();
                    regCtrl.currentStateProvince.value =
                        controller.currentState.value;
                    regCtrl.currentCountry.value =
                        controller.currentCountry.value;
                    regCtrl.currentZipPostCode.value = controller
                        .currentZipController
                        .text
                        .trim();

                    regCtrl.permanentAddress.value = controller
                        .permanentAddressController
                        .text
                        .trim();
                    regCtrl.permanentApartment.value = controller
                        .permanentApartmentController
                        .text
                        .trim();
                    regCtrl.permanentStateProvince.value =
                        controller.permanentState.value;
                    regCtrl.permanentCountry.value =
                        controller.permanentCountry.value;
                    regCtrl.permanentZipPostCode.value = controller
                        .permanentZipController
                        .text
                        .trim();

                    // Set bank details
                    regCtrl.bankName.value = controller.bankNameController.text
                        .trim();
                    regCtrl.accountNumber.value = controller
                        .accountNumberController
                        .text
                        .trim();

                    // Debug: print collected registration summary
                    debugPrint('Submitting registration with:');
                    debugPrint(
                      'name=${regCtrl.raiderName.value}, contact=${regCtrl.contactNumber.value}, email=${regCtrl.email.value}',
                    );
                    debugPrint(
                      'driver_photos=${regCtrl.driverPhotos.length}, nidFront=${regCtrl.nidFront.value != null}, dlFront=${regCtrl.dlFront.value != null}',
                    );

                    // Show loading
                    final success = await regCtrl.submitRegistration();

                    if (success) {
                      final profileCheckController =
                          Get.isRegistered<ProfileCheckController>()
                              ? Get.find<ProfileCheckController>()
                              : Get.put(ProfileCheckController(autoCheckOnInit: false));
                      await profileCheckController.checkProfile();
                      if (Get.isDialogOpen ?? false) Get.back();
                    } else {
                      EasyLoading.showError('Failed to submit registration');
                    }
                  },
                  child: regCtrl.isLoading.value
                      ? CircularProgressIndicator()
                      : Text(
                          "Continue",
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 26, bottom: 10),
      child: Text(
        text,
        style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget input(
    TextEditingController controller,
    String hint, {
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.2),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 1.2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget pickerInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      canRequestFocus: enabled,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(
          Icons.location_on_outlined,
          color: enabled ? Colors.black : Colors.black54,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.2),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 1.2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget dropdown({
    required List<String> items,
    required Function(String?)? onChanged,
    required String? value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: SizedBox(),
        hint: Text("Select "),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget countryDropdown({
    required BuildContext context,
    required List<CountryOption> items,
    required String value,
    required ValueChanged<String?>? onChanged,
    bool enabled = true,
  }) {
    CountryOption? selectedCountry;
    for (final country in items) {
      if (country.name == value) {
        selectedCountry = country;
        break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled && onChanged != null
              ? () => showCountryPickerSheet(
                  context: context,
                  items: items,
                  selectedValue: value,
                  onChanged: onChanged,
                )
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCountry != null
                        ? '${selectedCountry.flag} ${selectedCountry.name}'
                        : value,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: enabled ? Colors.black : Colors.black54,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled ? Colors.black : Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showCountryPickerSheet({
    required BuildContext context,
    required List<CountryOption> items,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
  }) async {
    if (controller.isCountryPickerOpen.value) return;

    controller.isCountryPickerOpen.value = true;

    try {
      final selectedCountry = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _CountryPickerBottomSheet(
          items: items,
          selectedValue: selectedValue,
        ),
      );

      if (selectedCountry != null && selectedCountry.trim().isNotEmpty) {
        onChanged(selectedCountry);
      }
    } finally {
      controller.isCountryPickerOpen.value = false;
    }
  }
}

class _CountryPickerBottomSheetController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      query.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class _CountryPickerBottomSheet extends StatelessWidget {
  const _CountryPickerBottomSheet({
    required this.items,
    required this.selectedValue,
  });

  final List<CountryOption> items;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_CountryPickerBottomSheetController>(
      init: _CountryPickerBottomSheetController(),
      builder: (controller) {
        return Obx(() {
          final queryStr = controller.query.value.trim().toLowerCase();
          final filteredCountries = items.where((country) {
            return country.name.toLowerCase().contains(queryStr);
          }).toList();

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Select Country',
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search country',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: controller.query.value.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  controller.searchController.clear();
                                },
                                icon: Icon(Icons.close),
                              )
                            : null,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black26, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 1.2),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: filteredCountries.isEmpty
                          ? Center(
                              child: Text(
                                'No country found',
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredCountries.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: Colors.black12),
                              itemBuilder: (context, index) {
                                final country = filteredCountries[index];
                                final isSelected =
                                    country.name == selectedValue;

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${country.flag} ${country.name}',
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: AppColors.primaryButtonColor,
                                        )
                                      : null,
                                  onTap: () {
                                    Navigator.of(context).pop(country.name);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
