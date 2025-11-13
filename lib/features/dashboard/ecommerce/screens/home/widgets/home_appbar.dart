import 'package:cwt_starter_template/common/widgets/appbar/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../personalization/controllers/user_controller.dart';
import '../../../../../../personalization/screens/profile/user_profile_details_screen.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../cart/screens/cart_menu_icon.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());
    
    return TEComAppBar(
      title: GestureDetector(
        onTap: () => Get.to(() => const UserProfileDetailsScreen()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nine27 Pharmacy',
              style: Theme.of(context).textTheme.labelMedium!.apply(color: Colors.white.withOpacity(0.9)),
            ),
            Obx(() {
              // Show user's first name or full name, fallback to "User"
              String userName = 'User';
              
              if (userController.user.value.fullName.isNotEmpty) {
                // Extract first name from full name
                final nameParts = userController.user.value.fullName.split(' ');
                userName = nameParts.isNotEmpty ? nameParts[0] : userController.user.value.fullName;
              }
              
              return Text(
                userName,
                style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white),
              );
            }),
          ],
        ),
      ),
      actions: [
        const TCartCounterIcon(iconColor: TColors.white, counterBgColor: TColors.black, counterTextColor: TColors.white),
      ],
    );
  }
}
