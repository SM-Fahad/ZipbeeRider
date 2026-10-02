import 'package:ZipBee_Driver/features/auth/login/controller/profile_check_controller.dart';
import 'package:ZipBee_Driver/features/auth/registration/controller/registration_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
  SharedPreferences.setMockInitialValues({});

  group('RegistrationController Prefill Tests', () {
    test('prefillFromRegistration populates all fields and preserves URLs', () {
      final regCtrl = RegistrationController();

      final sampleRegistration = {
        'id': 5,
        'raider_name': 'John Doe',
        'contact_number': '+6591234567',
        'email_address': 'john@example.com',
        'dob': '1995-05-12T00:00:00.000Z',
        'gender': 'MALE',
        'emergency_contact_name': 'Jane Doe',
        'emergency_contact_number': '+6598765432',
        'identity_card_number': 'S1234567A',
        'identity_card_issue_date': '2015-01-01T00:00:00.000Z',
        'driving_license_number': 'D9876543',
        'driving_license_issue_date': '2016-01-01T00:00:00.000Z',
        'license_class': 'CLASS_3',
        'vehicle_plate_number': 'SBA1234A',
        'vehicle_type_id': 2,
        'vehicle_brand': 'Honda',
        'vehicle_model': 'Civic',
        'registration_date': '2020-01-01T00:00:00.000Z',
        'chassis_number': 'CH123456789',
        'insurance_policy_number': 'POL123456',
        'insurance_issue_date': '2024-01-01T00:00:00.000Z',
        'insurance_expiry_date': '2025-01-01T00:00:00.000Z',
        'current_postal_code': '123456',
        'current_address': 'Block 123 Orchard Rd',
        'current_unit': '#05-01',
        'current_country': 'Singapore',
        'permanent_postal_code': '123456',
        'permanent_address': 'Block 123 Orchard Rd',
        'permanent_unit': '#05-01',
        'permanent_country': 'Singapore',
        'bank_name': 'DBS',
        'account_number': '1234567890',
        'driver_photos': ['https://api.zipbee.sg/uploads/driver.jpg'],
        'nric_front_images': 'https://api.zipbee.sg/uploads/nric_f.jpg',
        'nric_back_images': 'https://api.zipbee.sg/uploads/nric_b.jpg',
        'driving_license_front_images': 'https://api.zipbee.sg/uploads/dl_f.jpg',
        'driving_license_back_images': 'https://api.zipbee.sg/uploads/dl_b.jpg',
        'vehicle_front_images': 'https://api.zipbee.sg/uploads/veh_f.jpg',
        'vehicle_back_images': 'https://api.zipbee.sg/uploads/veh_b.jpg',
        'vehicle_driver_side_images': 'https://api.zipbee.sg/uploads/veh_d.jpg',
        'vehicle_passenger_side_images': 'https://api.zipbee.sg/uploads/veh_p.jpg',
        'vehicle_log_images': 'https://api.zipbee.sg/uploads/log.pdf',
        'insurance_policy_images': 'https://api.zipbee.sg/uploads/policy.pdf',
      };

      regCtrl.prefillFromRegistration(sampleRegistration);

      expect(regCtrl.isResubmission.value, isTrue);
      expect(regCtrl.raiderName.value, 'John Doe');
      expect(regCtrl.contactNumber.value, '+6591234567');
      expect(regCtrl.email.value, 'john@example.com');
      expect(regCtrl.identityCardNumber.value, 'S1234567A');
      expect(regCtrl.drivingLicenseNumber.value, 'D9876543');
      expect(regCtrl.licenseClass.value, 'CLASS_3');
      expect(regCtrl.unmapLicenseClass(regCtrl.licenseClass.value), 'Class 3');
      expect(regCtrl.vehicleType.value, '2');
      expect(regCtrl.vehicleBrand.value, 'Honda');

      // Check preserved image URLs
      expect(regCtrl.existingDriverPhotos, ['https://api.zipbee.sg/uploads/driver.jpg']);
      expect(regCtrl.existingNidFront.value, 'https://api.zipbee.sg/uploads/nric_f.jpg');
      expect(regCtrl.existingNidBack.value, 'https://api.zipbee.sg/uploads/nric_b.jpg');
      expect(regCtrl.existingDlFront.value, 'https://api.zipbee.sg/uploads/dl_f.jpg');
      expect(regCtrl.existingDlBack.value, 'https://api.zipbee.sg/uploads/dl_b.jpg');
      expect(regCtrl.existingVehicleFront.value, 'https://api.zipbee.sg/uploads/veh_f.jpg');
      expect(regCtrl.existingVehicleLog.value, 'https://api.zipbee.sg/uploads/log.pdf');
      expect(regCtrl.existingVehiclePolicy.value, 'https://api.zipbee.sg/uploads/policy.pdf');
    });

    test('resetForm clears all fields and existing URLs', () {
      final regCtrl = RegistrationController();
      regCtrl.raiderName.value = 'John';
      regCtrl.existingNidFront.value = 'https://some-url.com';

      regCtrl.resetForm();

      expect(regCtrl.isResubmission.value, isFalse);
      expect(regCtrl.raiderName.value, '');
      expect(regCtrl.existingNidFront.value, '');
    });
  });

  group('ProfileCheckController Status Handling Tests', () {
    test('REJECTED status triggers Application Rejected state with reason', () async {
      final controller = ProfileCheckController(autoCheckOnInit: false);

      final payload = {
        'id': 12,
        'username': 'john_doe',
        'roles': [{'name': 'RAIDER'}],
        'raiderProfile': {
          'id': 12,
          'raider_verificationFromAdmin': 'REJECTED',
          'rejectionReason': 'Driving license photo is blurry. Please provide a clear front & back scan.',
          'rejectedAt': '2026-09-30T10:35:00.000Z',
          'registrations': [
            {
              'id': 5,
              'raider_name': 'John Doe',
              'contact_number': '+6591234567',
              'email_address': 'john@example.com',
              'identity_card_number': 'S1234567A',
              'driving_license_number': 'D9876543',
              'vehicle_type_id': 2,
            }
          ]
        }
      };

      await controller.processProfileData(payload, navigateOnSuccess: false);

      expect(controller.isRejected.value, isTrue);
      expect(controller.statusTitle.value, 'Application Rejected');
      expect(
        controller.rejectionReason.value,
        'Driving license photo is blurry. Please provide a clear front & back scan.',
      );
      expect(controller.rejectedAt.value, '2026-09-30T10:35:00.000Z');
      expect(controller.activeAction.value, ProfileCheckAction.resubmitRegistration);
      expect(controller.primaryButtonText.value, 'Edit & Resubmit Details');
      expect(controller.registrationData['raider_name'], 'John Doe');
    });

    test('PENDING status triggers Waiting For Admin Approval state', () async {
      final controller = ProfileCheckController(autoCheckOnInit: false);

      final payload = {
        'id': 12,
        'username': 'john_doe',
        'roles': [{'name': 'RAIDER'}],
        'raiderProfile': {
          'id': 12,
          'raider_verificationFromAdmin': 'PENDING',
          'registrations': [
            {
              'id': 5,
              'raider_name': 'John Doe',
            }
          ]
        }
      };

      await controller.processProfileData(payload, navigateOnSuccess: false);

      expect(controller.isRejected.value, isFalse);
      expect(controller.statusTitle.value, 'Waiting For Admin Approval');
      expect(controller.activeAction.value, ProfileCheckAction.none);
    });
  });
}
