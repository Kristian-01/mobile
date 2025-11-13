import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/prescription_controller.dart';
import 'prescription_detail_screen.dart';
import 'prescription_upload_screen.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrescriptionController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TAppBar(
        title: Text('My Prescriptions', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.userPrescriptions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.document_upload,
                    size: 100,
                    color: dark ? TColors.darkGrey : TColors.grey,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    'No prescriptions yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: TSizes.sm),
                  Text(
                    'Upload your prescription to order\nprescription medicines',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  // Instruction card
                  Container(
                    padding: const EdgeInsets.all(TSizes.md),
                    decoration: BoxDecoration(
                      color: TColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                      border: Border.all(color: TColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.info_circle, color: TColors.primary, size: 20),
                        const SizedBox(width: TSizes.sm),
                        Expanded(
                          child: Text(
                            'Tap the "Upload Prescription" button below to get started',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: TColors.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchUserPrescriptions,
          child: ListView.separated(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            itemCount: controller.userPrescriptions.length,
            separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
            itemBuilder: (context, index) {
              final prescription = controller.userPrescriptions[index];
              
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

              return GestureDetector(
                onTap: () => Get.to(() => PrescriptionDetailScreen(prescription: prescription)),
                child: Container(
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    color: dark ? TColors.darkerGrey : TColors.white,
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    border: Border.all(color: dark ? TColors.darkGrey : TColors.grey.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header with status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prescription.patientName,
                                  style: Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: TSizes.xs),
                                Text(
                                  THelperFunctions.getFormattedDate(prescription.submittedAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.sm,
                              vertical: TSizes.xs,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(TSizes.sm),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              controller.getStatusText(prescription.status),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (prescription.doctorName != null && prescription.doctorName!.isNotEmpty) ...[
                        const SizedBox(height: TSizes.sm),
                        Row(
                          children: [
                            Icon(Iconsax.health, size: 16, color: dark ? TColors.darkGrey : TColors.grey),
                            const SizedBox(width: TSizes.xs),
                            Text(
                              'Dr. ${prescription.doctorName}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],

                      if (prescription.notes != null && prescription.notes!.isNotEmpty) ...[
                        const SizedBox(height: TSizes.sm),
                        Text(
                          prescription.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      /// Rejection reason if rejected
                      if (prescription.status.toLowerCase() == 'rejected' &&
                          prescription.rejectionReason != null) ...[
                        const SizedBox(height: TSizes.sm),
                        Container(
                          padding: const EdgeInsets.all(TSizes.sm),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(TSizes.sm),
                          ),
                          child: Row(
                            children: [
                              Icon(Iconsax.info_circle, size: 16, color: Colors.red),
                              const SizedBox(width: TSizes.xs),
                              Expanded(
                                child: Text(
                                  prescription.rejectionReason!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.red,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const PrescriptionUploadScreen()),
        icon: const Icon(Iconsax.document_upload),
        label: const Text('Upload Prescription'),
        backgroundColor: TColors.primary,
        elevation: 8,
      ),
    );
  }
}
