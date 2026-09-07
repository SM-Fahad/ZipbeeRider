# Registration Data Flow Documentation

## Overview
All 5 registration steps aggregate their data into a single **`RegistrationController`** which handles the final submission to the backend.

## Data Flow Architecture

```
RiderDetailsController → RegistrationController
         ↓
IdentityCardController → RegistrationController
         ↓
VehicleDetailsController → RegistrationController
         ↓
VehicleCarLogController → RegistrationController
         ↓
CurrentAddressController → RegistrationController
         ↓
    submitRegistration() → Backend API
```

## Step-by-Step Data Collection

### Step 1: Rider Details (RiderDetailsController)
**Method:** `submitRiderDetails()`

Saves to RegistrationController:
- `raiderName` - Driver's full name
- `contactNumber` - Contact phone number
- `email` - Email address
- `dob` - Date of birth (ISO format: yyyy-MM-dd)
- `gender` - Gender
- `driverPhotos` - List of driver photos (File objects)
- `emergencyContactName` - Emergency contact name
- `emergencyContactNumber` - Emergency contact number

### Step 2: Identity Card & License (IdentityCardController)
**Method:** `continueNext()`

Saves to RegistrationController:
- `identityCardNumber` - NID/ID number
- `nidFront` - NID front image (File)
- `nidBack` - NID back image (File)
- `drivingLicenseNumber` - License number
- `drivingLicenseIssueDate` - License issue date (ISO format: yyyy-MM-dd)
- `drivingLicenseExpireDate` - License expiry date (ISO format: yyyy-MM-dd)
- `dlFront` - License front image (File)
- `dlBack` - License back image (File)

### Step 3: Vehicle Details (VehicleDetailsController)
**Method:** `continueNext()`

Saves to RegistrationController:
- `vehiclePlateNumber` - Vehicle registration plate number
- `vehicleType` - Vehicle type (Car, Bike, etc.)
- `vehicleBrand` - Vehicle brand/model
- `registrationDate` - Vehicle registration date (ISO format: yyyy-MM-dd)
- `vehicleFront` - Front image (File)
- `vehicleBack` - Back image (File)
- `vehicleDriverSide` - Driver side image (File)
- `vehiclePassengerSide` - Passenger side image (File)

### Step 4: Vehicle Log & Policy (VehicleCarLogController)
**Method:** `submitVehicleDetails()`

Saves to RegistrationController:
- `vehicleLogNumber` - Vehicle log number
- `vehicleLogIssueDate` - Log issue date (ISO format: yyyy-MM-dd)
- `vehicleLogExpireDate` - Log expiry date (ISO format: yyyy-MM-dd)
- `vehicleLogFile` - Log file (PlatformFile)
- `vehiclePolicyNumber` - Insurance policy number
- `vehiclePolicyIssueDate` - Policy issue date (ISO format: yyyy-MM-dd)
- `vehiclePolicyExpireDate` - Policy expiry date (ISO format: yyyy-MM-dd)
- `vehiclePolicyFile` - Policy file (PlatformFile)

### Step 5: Current Address & Bank (CurrentAddressController)
**Method:** `submitAddressAndBankDetails()`

Saves to RegistrationController:
- **Current Address:**
  - `currentAddress` - Street address
  - `currentApartment` - Apartment/flat number
  - `currentStateProvince` - State/Province
  - `currentCity` - City
  - `currentCountry` - Country
  - `currentZipPostCode` - Postal/ZIP code

- **Permanent Address:**
  - `permanentAddress` - Street address
  - `permanentApartment` - Apartment/flat number
  - `permanentStateProvince` - State/Province
  - `permanentCity` - City
  - `permanentCountry` - Country
  - `permanentZipPostCode` - Postal/ZIP code

- **Bank Details:**
  - `bankName` - Bank name
  - `accountNumber` - Bank account number

## Final Submission

Once all data is collected in `RegistrationController`, call:

```dart
final regCtrl = Get.find<RegistrationController>(tag: 'registration');
bool success = await regCtrl.submitRegistration();
```

### What `submitRegistration()` Does:

1. **Retrieves authentication token** from SharedPreferences
2. **Converts all File objects to base64** for JSON transmission
3. **Builds complete JSON payload** with all collected data
4. **Sends POST request** to backend API endpoint
5. **Returns success/failure** status

### Backend API Integration

- **Endpoint:** `ApiEndPoint.riderRegistration`
- **Method:** POST
- **Content-Type:** application/json
- **Authentication:** Bearer token in Authorization header

## Key Features

✅ **Modular Design** - Each step has its own controller  
✅ **Centralized Data** - All data aggregated in RegistrationController  
✅ **File Handling** - Converts File objects to base64 JSON  
✅ **Date Formatting** - All dates converted to ISO format (yyyy-MM-dd)  
✅ **Error Handling** - Built-in validation and error messaging  

## Usage Example

```dart
// In your final screen/button
void onSubmitButtonPressed() async {
  final regCtrl = Get.find<RegistrationController>(tag: 'registration');
  
  // All data is already in regCtrl from previous steps
  bool success = await regCtrl.submitRegistration();
  
  if (success) {
    // Navigate to success screen
    Get.offAllNamed('/home');
  }
}
```
