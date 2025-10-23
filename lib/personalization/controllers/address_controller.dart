import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/texts/section_heading.dart';
import '../../../utils/constants/sizes.dart';
import '../../features/dashboard/ecommerce/controllers/dummy_data.dart';
import '../models/address_model.dart';
import '../screens/address/add_new_address.dart';
import '../screens/address/single_address_widget.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  
  // Form Controllers
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final postalCode = TextEditingController();
  final country = TextEditingController();

  // Add init to initialize some address by default.
  @override
  void onInit() {
    selectedAddress.value = TDummyData.user.addresses![0];
    super.onInit();
  }

  Future<dynamic> selectNewAddress(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TSectionHeading(title: 'Select Address', showActionButton: false),
              Column(
                children: TDummyData.user.addresses!
                    .map((address) => TSingleAddress(
                          address: address,
                          onTap: () {
                            selectedAddress.value = address;
                            Get.back();
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: TSizes.defaultSpace * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close the address selection bottom sheet
                      Get.to(() => const AddNewAddressScreen());
                    }, 
                    child: const Text('Add new address')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Add New Address
  Future<void> addNewAddress() async {
    try {
      // Validate form
      if (!addressFormKey.currentState!.validate()) {
        return;
      }

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Create new address model
      final newAddress = AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: false,
      );

      // Simulate saving to database (Replace with actual API call)
      await Future.delayed(const Duration(seconds: 1));

      // Add to dummy data (In real app, this would be saved to database)
      if (TDummyData.user.addresses != null) {
        TDummyData.user.addresses!.add(newAddress);
      }

      // Set as selected address
      selectedAddress.value = newAddress;

      // Close loading
      Get.back();

      // Clear form
      resetFormFields();

      // Show success message
      Get.snackbar(
        'Success',
        'Address added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate back
      Get.back();
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to add address. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Reset Form Fields
  void resetFormFields() {
    name.clear();
    phoneNumber.clear();
    street.clear();
    city.clear();
    state.clear();
    postalCode.clear();
    country.clear();
    addressFormKey.currentState?.reset();
  }

  @override
  void onClose() {
    name.dispose();
    phoneNumber.dispose();
    street.dispose();
    city.dispose();
    state.dispose();
    postalCode.dispose();
    country.dispose();
    super.onClose();
  }
}
