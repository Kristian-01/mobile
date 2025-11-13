import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/prescription_controller.dart';
import '../models/prescription_model.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  const PrescriptionDetailScreen({super.key, required this.prescription});

  final PrescriptionModel prescription;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrescriptionController());
    final dark = THelperFunctions.isDarkMode(context);

    Color statusColor;
    switch (prescription.status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Scaffold(
      appBar: TAppBar(
        title: Text('Prescription Details', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Prescription Image
              GestureDetector(
                onTap: () {
                  // Show full screen image
                  Get.to(() => FullScreenImageViewer(imageUrl: prescription.imageUrl));
                },
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    border: Border.all(color: dark ? TColors.darkGrey : TColors.grey.withValues(alpha: 0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    child: CachedNetworkImage(
                      imageUrl: prescription.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      prescription.status.toLowerCase() == 'approved'
                          ? Iconsax.tick_circle
                          : prescription.status.toLowerCase() == 'rejected'
                              ? Iconsax.close_circle
                              : Iconsax.clock,
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: TSizes.xs),
                    Text(
                      controller.getStatusText(prescription.status),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Details
              _buildDetailRow(context, 'Patient Name', prescription.patientName, Iconsax.user),
              
              if (prescription.doctorName != null && prescription.doctorName!.isNotEmpty)
                _buildDetailRow(context, 'Doctor', 'Dr. ${prescription.doctorName}', Iconsax.health),
              
              _buildDetailRow(
                context,
                'Uploaded On',
                THelperFunctions.getFormattedDate(prescription.submittedAt),
                Iconsax.calendar,
              ),

              if (prescription.approvedAt != null)
                _buildDetailRow(
                  context,
                  'Approved On',
                  THelperFunctions.getFormattedDate(prescription.approvedAt!),
                  Iconsax.tick_circle,
                ),

              if (prescription.approvedBy != null && prescription.approvedBy!.isNotEmpty)
                _buildDetailRow(context, 'Approved By', prescription.approvedBy!, Iconsax.user_tick),

              if (prescription.linkedOrderId != null && prescription.linkedOrderId!.isNotEmpty)
                _buildDetailRow(context, 'Order ID', prescription.linkedOrderId!, Iconsax.box),

              if (prescription.notes != null && prescription.notes!.isNotEmpty) ...[
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'Additional Notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TSizes.xs),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    color: dark ? TColors.darkerGrey : TColors.light,
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                  ),
                  child: Text(
                    prescription.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],

              /// Rejection Reason
              if (prescription.status.toLowerCase() == 'rejected' &&
                  prescription.rejectionReason != null) ...[
                const SizedBox(height: TSizes.spaceBtwSections),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Iconsax.info_circle, color: Colors.red, size: 20),
                          const SizedBox(width: TSizes.xs),
                          Text(
                            'Rejection Reason',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.red,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        prescription.rejectionReason!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: TSizes.spaceBtwSections),

              /// Delete Button (only for pending or rejected)
              if (prescription.status.toLowerCase() != 'approved')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Delete Prescription',
                        middleText: 'Are you sure you want to delete this prescription?',
                        textConfirm: 'Delete',
                        textCancel: 'Cancel',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          controller.deletePrescription(prescription.id);
                          Get.back(); // Close dialog
                          Get.back(); // Close detail screen
                        },
                      );
                    },
                    icon: const Icon(Iconsax.trash, color: Colors.red),
                    label: const Text('Delete Prescription', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    final dark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: dark ? TColors.darkGrey : TColors.grey),
          const SizedBox(width: TSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? TColors.darkGrey : TColors.grey,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full screen image viewer
class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
