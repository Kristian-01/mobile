import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../personalization/controllers/address_controller.dart';
import '../../../../personalization/screens/address/add_new_address.dart';
import '../../../../personalization/screens/address/edit_address.dart';
import '../../../../personalization/models/address_model.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(AddressController());
    
    return Scaffold(
      backgroundColor: isDark ? TColors.black : TColors.light,
      appBar: AppBar(
        backgroundColor: isDark ? TColors.black : TColors.light,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : TColors.dark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Addresses',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddNewAddressScreen()),
        backgroundColor: TColors.primary,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.location, size: 80, color: TColors.darkGrey),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'No Addresses Yet',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(
                  'Add your first address using the + button',
                  style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                ),
              ],
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: controller.addresses.map((address) {
              return Padding(
                padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                child: _buildAddressCard(
                  context,
                  controller: controller,
                  address: address,
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required AddressController controller,
    required AddressModel address,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDefault = address.selectedAddress;
    
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : TColors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: isDefault ? TColors.primary : (isDark ? TColors.darkGrey : TColors.grey),
          width: isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  address.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Default',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Row(
            children: [
              Icon(Iconsax.location, color: isDark ? TColors.grey : TColors.darkGrey, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? TColors.grey : TColors.darkGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          Row(
            children: [
              Icon(Iconsax.call, color: isDark ? TColors.grey : TColors.darkGrey, size: 16),
              const SizedBox(width: 8),
              Text(
                address.formattedPhoneNo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? TColors.grey : TColors.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showEditAddressDialog(context, controller, address),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: TColors.primary),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDeleteConfirmation(context, controller, address),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditAddressDialog(BuildContext context, AddressController controller, AddressModel address) {
    // Pre-fill the form with existing data
    controller.name.text = address.name;
    controller.phoneNumber.text = address.phoneNumber;
    controller.street.text = address.street;
    controller.city.text = address.city;
    controller.state.text = address.state;
    controller.postalCode.text = address.postalCode;
    controller.country.text = address.country;
    
    Get.to(() => EditAddressScreen(address: address));
  }

  void _showDeleteConfirmation(BuildContext context, AddressController controller, AddressModel address) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.deleteAddress(address);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
