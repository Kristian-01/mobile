import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/validators/validation.dart';
import '../../controllers/address_controller.dart';
import '../../models/address_model.dart';

class EditAddressScreen extends StatelessWidget {
  const EditAddressScreen({super.key, required this.address});
  
  final AddressModel address;

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;
    
    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('Edit Address'),
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: controller.addressFormKey,
            child: Column(
              children: [
                /// Name
                TextFormField(
                  controller: controller.name,
                  validator: (value) => TValidator.validateEmptyText('Name', value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Phone Number
                TextFormField(
                  controller: controller.phoneNumber,
                  validator: TValidator.validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.mobile),
                    labelText: 'Phone Number',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Street
                TextFormField(
                  controller: controller.street,
                  validator: (value) => TValidator.validateEmptyText('Street', value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.building_31),
                    labelText: 'Street',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// City
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.city,
                        validator: (value) => TValidator.validateEmptyText('City', value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building),
                          labelText: 'City',
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.state,
                        validator: (value) => TValidator.validateEmptyText('State', value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.activity),
                          labelText: 'State',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Postal Code & Country
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.postalCode,
                        validator: (value) => TValidator.validateEmptyText('Postal Code', value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.code),
                          labelText: 'Postal Code',
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.country,
                        validator: (value) => TValidator.validateEmptyText('Country', value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.global),
                          labelText: 'Country',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.defaultSpace),

                /// Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateAddress(controller),
                    child: const Text('Update Address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _updateAddress(AddressController controller) async {
    try {
      // Validate form
      if (!controller.addressFormKey.currentState!.validate()) {
        return;
      }

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Create updated address model
      final updatedAddress = AddressModel(
        id: address.id, // Keep the same ID
        name: controller.name.text.trim(),
        phoneNumber: controller.phoneNumber.text.trim(),
        street: controller.street.text.trim(),
        city: controller.city.text.trim(),
        state: controller.state.text.trim(),
        postalCode: controller.postalCode.text.trim(),
        country: controller.country.text.trim(),
        selectedAddress: address.selectedAddress, // Keep selected status
      );

      // Update in Firebase using controller method
      await controller.updateAddress(updatedAddress);

      // Close loading
      Get.back();

      // Clear form
      controller.resetFormFields();

      // Navigate back to addresses screen
      Get.back();
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to update address: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
