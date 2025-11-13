import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/sizes.dart';
import '../../../data/repository/user_repository/user_repository.dart';
import '../controllers/prescription_controller.dart';

class PrescriptionUploadScreen extends StatefulWidget {
  const PrescriptionUploadScreen({super.key});

  @override
  State<PrescriptionUploadScreen> createState() => _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  final controller = Get.put(PrescriptionController());
  final userRepository = Get.put(UserRepository());
  final patientNameController = TextEditingController();
  final emailController = TextEditingController();
  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    try {
      final user = await userRepository.fetchUserDetails();
      setState(() {
        emailController.text = user.email;
      });
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  @override
  void dispose() {
    patientNameController.dispose();
    emailController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: TAppBar(
        title: Text('Upload Prescription', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                /// Information
                Text(
                  'Upload your prescription',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: TSizes.sm),
                Text(
                  'Take a clear photo of your prescription or select from gallery. Our pharmacist will review it before processing your order.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Patient Name
                TextFormField(
                  controller: patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    prefixIcon: Icon(Iconsax.user),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Email (Auto-filled from logged-in user)
                TextFormField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Iconsax.sms),
                    suffixIcon: Icon(Iconsax.lock, size: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Notes (Optional)
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    prefixIcon: Icon(Iconsax.note),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Upload Buttons
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (controller.isPicking.value || controller.isLoading.value)
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  controller.uploadFromCamera(
                                    patientNameController.text.trim(),
                                    emailController.text.trim(),
                                    notes: notesController.text.trim().isEmpty
                                        ? null
                                        : notesController.text.trim(),
                                  );
                                }
                              },
                        icon: const Icon(Iconsax.camera),
                        label: const Text('Camera'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (controller.isPicking.value || controller.isLoading.value)
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  controller.uploadFromGallery(
                                    patientNameController.text.trim(),
                                    emailController.text.trim(),
                                    notes: notesController.text.trim().isEmpty
                                        ? null
                                        : notesController.text.trim(),
                                  );
                                }
                              },
                        icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Iconsax.gallery),
                        label: Text(controller.isLoading.value ? 'Uploading...' : 'Gallery'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                        ),
                      ),
                    ),
                  ],
                )),

                const SizedBox(height: TSizes.spaceBtwItems),

                /// Info Card
                Container(
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Iconsax.info_circle, color: Colors.blue, size: 20),
                      const SizedBox(width: TSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tips for clear prescription photo:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.blue,
                                  ),
                            ),
                            const SizedBox(height: TSizes.xs),
                            Text(
                              '• Ensure good lighting\n'
                              '• Keep prescription flat and straight\n'
                              '• Make sure all text is readable\n'
                              '• Include doctor\'s signature',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
