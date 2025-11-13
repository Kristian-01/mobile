import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/texts/section_heading.dart';
import '../../../data/repository/address_repository/address_repository.dart';
import '../../../utils/constants/sizes.dart';
import '../models/address_model.dart';
import '../screens/address/add_new_address.dart';
import '../screens/address/single_address_widget.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final _addressRepository = Get.put(AddressRepository());
  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = false.obs;
  
  // Form Controllers
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final postalCode = TextEditingController();
  final country = TextEditingController();

  @override
  void onInit() {
    loadAddresses();
    super.onInit();
  }

  /// Load all addresses from Firebase
  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      addresses.value = await _addressRepository.getAllItems();
      
      // Set the first selected address or the first one
      if (addresses.isNotEmpty) {
        final selected = addresses.firstWhere(
          (addr) => addr.selectedAddress,
          orElse: () => addresses.first,
        );
        selectedAddress.value = selected;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load addresses: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<dynamic> selectNewAddress(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => Obx(() => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TSectionHeading(title: 'Select Address', showActionButton: false),
              if (isLoading.value)
                const Center(child: CircularProgressIndicator())
              else if (addresses.isEmpty)
                const Center(child: Text('No addresses found. Add one below.'))
              else
                Column(
                  children: addresses
                      .map((address) => TSingleAddress(
                            address: address,
                            onTap: () async {
                              await selectAddress(address.id);
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
                      Get.back();
                      Get.to(() => const AddNewAddressScreen());
                    }, 
                    child: const Text('Add new address')),
              ),
            ],
          ),
        ),
      )),
    );
  }

  /// Select an address and update Firebase
  Future<void> selectAddress(String addressId) async {
    try {
      await _addressRepository.setSelectedAddress(addressId);
      await loadAddresses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to select address: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
        id: '', // Firebase will generate ID
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: addresses.isEmpty, // Set as selected if first address
      );

      // Save to Firebase
      final addressId = await _addressRepository.addNewItem(newAddress);

      // Reload addresses
      await loadAddresses();

      // If this is the first address or user wants it selected
      if (addresses.length == 1) {
        await selectAddress(addressId);
      }

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
        'Failed to add address: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Update an existing address
  Future<void> updateAddress(AddressModel address) async {
    try {
      await _addressRepository.updateItem(address);
      await loadAddresses();
      
      Get.snackbar(
        'Success',
        'Address updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update address: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Delete an address
  Future<void> deleteAddress(AddressModel address) async {
    try {
      await _addressRepository.deleteItemRecord(address);
      await loadAddresses();
      
      Get.snackbar(
        'Success',
        'Address deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete address: $e',
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
