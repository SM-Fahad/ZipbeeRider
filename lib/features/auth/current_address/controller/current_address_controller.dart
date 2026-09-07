import 'package:ZipBee_Driver/features/auth/registration/controller/registration_controller.dart';
import 'package:ZipBee_Driver/features/google_map/service/one_map_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountryOption {
  const CountryOption({required this.name, required this.code});

  final String name;
  final String code;

  String get flag {
    return String.fromCharCodes(
      code.toUpperCase().codeUnits.map((char) => char + 127397),
    );
  }
}

class CurrentAddressController extends GetxController {
  /// Current Address Controllers
  final currentAddressController = TextEditingController();
  final currentApartmentController = TextEditingController();
  final currentState = ''.obs;
  final currentZipController = TextEditingController();
  final currentCountry = 'Singapore'.obs;

  final sameAsCurrent = false.obs;

  final permanentAddressController = TextEditingController();
  final permanentApartmentController = TextEditingController();
  final permanentState = ''.obs;
  final permanentZipController = TextEditingController();
  final permanentCountry = 'Singapore'.obs;

  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bank = ''.obs;
  final isCountryPickerOpen = false.obs;
  final availableCountries = const [
    CountryOption(name: 'Afghanistan', code: 'AF'),
    CountryOption(name: 'Albania', code: 'AL'),
    CountryOption(name: 'Algeria', code: 'DZ'),
    CountryOption(name: 'Andorra', code: 'AD'),
    CountryOption(name: 'Angola', code: 'AO'),
    CountryOption(name: 'Antigua and Barbuda', code: 'AG'),
    CountryOption(name: 'Argentina', code: 'AR'),
    CountryOption(name: 'Armenia', code: 'AM'),
    CountryOption(name: 'Australia', code: 'AU'),
    CountryOption(name: 'Austria', code: 'AT'),
    CountryOption(name: 'Azerbaijan', code: 'AZ'),
    CountryOption(name: 'Bahamas', code: 'BS'),
    CountryOption(name: 'Bahrain', code: 'BH'),
    CountryOption(name: 'Bangladesh', code: 'BD'),
    CountryOption(name: 'Barbados', code: 'BB'),
    CountryOption(name: 'Belarus', code: 'BY'),
    CountryOption(name: 'Belgium', code: 'BE'),
    CountryOption(name: 'Belize', code: 'BZ'),
    CountryOption(name: 'Benin', code: 'BJ'),
    CountryOption(name: 'Bhutan', code: 'BT'),
    CountryOption(name: 'Bolivia', code: 'BO'),
    CountryOption(name: 'Bosnia and Herzegovina', code: 'BA'),
    CountryOption(name: 'Botswana', code: 'BW'),
    CountryOption(name: 'Brazil', code: 'BR'),
    CountryOption(name: 'Brunei', code: 'BN'),
    CountryOption(name: 'Bulgaria', code: 'BG'),
    CountryOption(name: 'Burkina Faso', code: 'BF'),
    CountryOption(name: 'Burundi', code: 'BI'),
    CountryOption(name: 'Cabo Verde', code: 'CV'),
    CountryOption(name: 'Cambodia', code: 'KH'),
    CountryOption(name: 'Cameroon', code: 'CM'),
    CountryOption(name: 'Canada', code: 'CA'),
    CountryOption(name: 'Central African Republic', code: 'CF'),
    CountryOption(name: 'Chad', code: 'TD'),
    CountryOption(name: 'Chile', code: 'CL'),
    CountryOption(name: 'China', code: 'CN'),
    CountryOption(name: 'Colombia', code: 'CO'),
    CountryOption(name: 'Comoros', code: 'KM'),
    CountryOption(name: 'Congo', code: 'CG'),
    CountryOption(name: 'Costa Rica', code: 'CR'),
    CountryOption(name: "Cote d'Ivoire", code: 'CI'),
    CountryOption(name: 'Croatia', code: 'HR'),
    CountryOption(name: 'Cuba', code: 'CU'),
    CountryOption(name: 'Cyprus', code: 'CY'),
    CountryOption(name: 'Czech Republic', code: 'CZ'),
    CountryOption(name: 'Democratic Republic of the Congo', code: 'CD'),
    CountryOption(name: 'Denmark', code: 'DK'),
    CountryOption(name: 'Djibouti', code: 'DJ'),
    CountryOption(name: 'Dominica', code: 'DM'),
    CountryOption(name: 'Dominican Republic', code: 'DO'),
    CountryOption(name: 'Ecuador', code: 'EC'),
    CountryOption(name: 'Egypt', code: 'EG'),
    CountryOption(name: 'El Salvador', code: 'SV'),
    CountryOption(name: 'Equatorial Guinea', code: 'GQ'),
    CountryOption(name: 'Eritrea', code: 'ER'),
    CountryOption(name: 'Estonia', code: 'EE'),
    CountryOption(name: 'Eswatini', code: 'SZ'),
    CountryOption(name: 'Ethiopia', code: 'ET'),
    CountryOption(name: 'Fiji', code: 'FJ'),
    CountryOption(name: 'Finland', code: 'FI'),
    CountryOption(name: 'France', code: 'FR'),
    CountryOption(name: 'Gabon', code: 'GA'),
    CountryOption(name: 'Gambia', code: 'GM'),
    CountryOption(name: 'Georgia', code: 'GE'),
    CountryOption(name: 'Germany', code: 'DE'),
    CountryOption(name: 'Ghana', code: 'GH'),
    CountryOption(name: 'Greece', code: 'GR'),
    CountryOption(name: 'Grenada', code: 'GD'),
    CountryOption(name: 'Guatemala', code: 'GT'),
    CountryOption(name: 'Guinea', code: 'GN'),
    CountryOption(name: 'Guinea-Bissau', code: 'GW'),
    CountryOption(name: 'Guyana', code: 'GY'),
    CountryOption(name: 'Haiti', code: 'HT'),
    CountryOption(name: 'Honduras', code: 'HN'),
    CountryOption(name: 'Hungary', code: 'HU'),
    CountryOption(name: 'Iceland', code: 'IS'),
    CountryOption(name: 'India', code: 'IN'),
    CountryOption(name: 'Indonesia', code: 'ID'),
    CountryOption(name: 'Iran', code: 'IR'),
    CountryOption(name: 'Iraq', code: 'IQ'),
    CountryOption(name: 'Ireland', code: 'IE'),
    CountryOption(name: 'Israel', code: 'IL'),
    CountryOption(name: 'Italy', code: 'IT'),
    CountryOption(name: 'Jamaica', code: 'JM'),
    CountryOption(name: 'Japan', code: 'JP'),
    CountryOption(name: 'Jordan', code: 'JO'),
    CountryOption(name: 'Kazakhstan', code: 'KZ'),
    CountryOption(name: 'Kenya', code: 'KE'),
    CountryOption(name: 'Kiribati', code: 'KI'),
    CountryOption(name: 'Kuwait', code: 'KW'),
    CountryOption(name: 'Kyrgyzstan', code: 'KG'),
    CountryOption(name: 'Laos', code: 'LA'),
    CountryOption(name: 'Latvia', code: 'LV'),
    CountryOption(name: 'Lebanon', code: 'LB'),
    CountryOption(name: 'Lesotho', code: 'LS'),
    CountryOption(name: 'Liberia', code: 'LR'),
    CountryOption(name: 'Libya', code: 'LY'),
    CountryOption(name: 'Liechtenstein', code: 'LI'),
    CountryOption(name: 'Lithuania', code: 'LT'),
    CountryOption(name: 'Luxembourg', code: 'LU'),
    CountryOption(name: 'Madagascar', code: 'MG'),
    CountryOption(name: 'Malawi', code: 'MW'),
    CountryOption(name: 'Malaysia', code: 'MY'),
    CountryOption(name: 'Maldives', code: 'MV'),
    CountryOption(name: 'Mali', code: 'ML'),
    CountryOption(name: 'Malta', code: 'MT'),
    CountryOption(name: 'Marshall Islands', code: 'MH'),
    CountryOption(name: 'Mauritania', code: 'MR'),
    CountryOption(name: 'Mauritius', code: 'MU'),
    CountryOption(name: 'Mexico', code: 'MX'),
    CountryOption(name: 'Micronesia', code: 'FM'),
    CountryOption(name: 'Moldova', code: 'MD'),
    CountryOption(name: 'Monaco', code: 'MC'),
    CountryOption(name: 'Mongolia', code: 'MN'),
    CountryOption(name: 'Montenegro', code: 'ME'),
    CountryOption(name: 'Morocco', code: 'MA'),
    CountryOption(name: 'Mozambique', code: 'MZ'),
    CountryOption(name: 'Myanmar', code: 'MM'),
    CountryOption(name: 'Namibia', code: 'NA'),
    CountryOption(name: 'Nauru', code: 'NR'),
    CountryOption(name: 'Nepal', code: 'NP'),
    CountryOption(name: 'Netherlands', code: 'NL'),
    CountryOption(name: 'New Zealand', code: 'NZ'),
    CountryOption(name: 'Nicaragua', code: 'NI'),
    CountryOption(name: 'Niger', code: 'NE'),
    CountryOption(name: 'Nigeria', code: 'NG'),
    CountryOption(name: 'North Korea', code: 'KP'),
    CountryOption(name: 'North Macedonia', code: 'MK'),
    CountryOption(name: 'Norway', code: 'NO'),
    CountryOption(name: 'Oman', code: 'OM'),
    CountryOption(name: 'Pakistan', code: 'PK'),
    CountryOption(name: 'Palau', code: 'PW'),
    CountryOption(name: 'Palestine', code: 'PS'),
    CountryOption(name: 'Panama', code: 'PA'),
    CountryOption(name: 'Papua New Guinea', code: 'PG'),
    CountryOption(name: 'Paraguay', code: 'PY'),
    CountryOption(name: 'Peru', code: 'PE'),
    CountryOption(name: 'Philippines', code: 'PH'),
    CountryOption(name: 'Poland', code: 'PL'),
    CountryOption(name: 'Portugal', code: 'PT'),
    CountryOption(name: 'Qatar', code: 'QA'),
    CountryOption(name: 'Romania', code: 'RO'),
    CountryOption(name: 'Russia', code: 'RU'),
    CountryOption(name: 'Rwanda', code: 'RW'),
    CountryOption(name: 'Saint Kitts and Nevis', code: 'KN'),
    CountryOption(name: 'Saint Lucia', code: 'LC'),
    CountryOption(name: 'Saint Vincent and the Grenadines', code: 'VC'),
    CountryOption(name: 'Samoa', code: 'WS'),
    CountryOption(name: 'San Marino', code: 'SM'),
    CountryOption(name: 'Sao Tome and Principe', code: 'ST'),
    CountryOption(name: 'Saudi Arabia', code: 'SA'),
    CountryOption(name: 'Senegal', code: 'SN'),
    CountryOption(name: 'Serbia', code: 'RS'),
    CountryOption(name: 'Seychelles', code: 'SC'),
    CountryOption(name: 'Sierra Leone', code: 'SL'),
    CountryOption(name: 'Singapore', code: 'SG'),
    CountryOption(name: 'Slovakia', code: 'SK'),
    CountryOption(name: 'Slovenia', code: 'SI'),
    CountryOption(name: 'Solomon Islands', code: 'SB'),
    CountryOption(name: 'Somalia', code: 'SO'),
    CountryOption(name: 'South Africa', code: 'ZA'),
    CountryOption(name: 'South Korea', code: 'KR'),
    CountryOption(name: 'South Sudan', code: 'SS'),
    CountryOption(name: 'Spain', code: 'ES'),
    CountryOption(name: 'Sri Lanka', code: 'LK'),
    CountryOption(name: 'Sudan', code: 'SD'),
    CountryOption(name: 'Suriname', code: 'SR'),
    CountryOption(name: 'Sweden', code: 'SE'),
    CountryOption(name: 'Switzerland', code: 'CH'),
    CountryOption(name: 'Syria', code: 'SY'),
    CountryOption(name: 'Taiwan', code: 'TW'),
    CountryOption(name: 'Tajikistan', code: 'TJ'),
    CountryOption(name: 'Tanzania', code: 'TZ'),
    CountryOption(name: 'Thailand', code: 'TH'),
    CountryOption(name: 'Timor-Leste', code: 'TL'),
    CountryOption(name: 'Togo', code: 'TG'),
    CountryOption(name: 'Tonga', code: 'TO'),
    CountryOption(name: 'Trinidad and Tobago', code: 'TT'),
    CountryOption(name: 'Tunisia', code: 'TN'),
    CountryOption(name: 'Turkey', code: 'TR'),
    CountryOption(name: 'Turkmenistan', code: 'TM'),
    CountryOption(name: 'Tuvalu', code: 'TV'),
    CountryOption(name: 'Uganda', code: 'UG'),
    CountryOption(name: 'Ukraine', code: 'UA'),
    CountryOption(name: 'United Arab Emirates', code: 'AE'),
    CountryOption(name: 'United Kingdom', code: 'GB'),
    CountryOption(name: 'United States', code: 'US'),
    CountryOption(name: 'Uruguay', code: 'UY'),
    CountryOption(name: 'Uzbekistan', code: 'UZ'),
    CountryOption(name: 'Vanuatu', code: 'VU'),
    CountryOption(name: 'Vatican City', code: 'VA'),
    CountryOption(name: 'Venezuela', code: 'VE'),
    CountryOption(name: 'Vietnam', code: 'VN'),
    CountryOption(name: 'Yemen', code: 'YE'),
    CountryOption(name: 'Zambia', code: 'ZM'),
    CountryOption(name: 'Zimbabwe', code: 'ZW'),
  ];

  // final stateList = ["Select State/Province", "Dhaka", "Khulna", "Rajshahi"];
  // final cityList = ["Select City", "Dhaka", "Jashore", "Khulna"];

  @override
  void onClose() {
    currentAddressController.dispose();
    currentApartmentController.dispose();
    currentZipController.dispose();
    permanentAddressController.dispose();
    permanentApartmentController.dispose();
    permanentZipController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    super.onClose();
  }

  void copyCurrentToPermanent(bool value) {
    sameAsCurrent.value = value;

    if (value) {
      permanentAddressController.text = currentAddressController.text;
      permanentApartmentController.text = currentApartmentController.text;
      permanentState.value = currentState.value;
      permanentCountry.value = currentCountry.value;
      permanentZipController.text = currentZipController.text;
    } else {
      permanentAddressController.clear();
      permanentApartmentController.clear();
      permanentState.value = "";
      permanentCountry.value = availableCountries.first.name;
      permanentZipController.clear();
    }
  }

  void setCurrentResolvedAddress(OneMapResolvedAddress resolved) {
    currentZipController.text = resolved.postalCode;
    currentAddressController.text = resolved.address;

    if (sameAsCurrent.value) {
      permanentZipController.text = resolved.postalCode;
      permanentAddressController.text = resolved.address;
    }
  }

  void setPermanentResolvedAddress(OneMapResolvedAddress resolved) {
    permanentZipController.text = resolved.postalCode;
    permanentAddressController.text = resolved.address;
  }

  Future<void> submitAddressAndBankDetails() async {
    final regCtrl = Get.put(RegistrationController(), tag: 'registration');

    // Current Address
    regCtrl.currentAddress.value = currentAddressController.text;
    regCtrl.currentApartment.value = currentApartmentController.text;
    regCtrl.currentStateProvince.value = currentState.value;
    regCtrl.currentCountry.value = currentCountry.value;
    regCtrl.currentZipPostCode.value = currentZipController.text;

    // Permanent Address
    regCtrl.permanentAddress.value = permanentAddressController.text;
    regCtrl.permanentApartment.value = permanentApartmentController.text;
    regCtrl.permanentStateProvince.value = permanentState.value;
    regCtrl.permanentCountry.value = permanentCountry.value;
    regCtrl.permanentZipPostCode.value = permanentZipController.text;

    // Bank Details
    regCtrl.bankName.value = bankNameController.text;
    regCtrl.accountNumber.value = accountNumberController.text;

    // Submit all registration data to backend
    //bool success = await regCtrl.submitRegistration();

    // if (success) {
    //   // Navigate to success screen or home
    //   Get.offAllNamed(AppRoutes.bottomNavbarScreen); // Adjust route name as needed
    // }
  }
}
