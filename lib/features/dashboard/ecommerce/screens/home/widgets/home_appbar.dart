import 'package:cwt_starter_template/common/widgets/appbar/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../../../../personalization/controllers/notification_controller.dart';
import '../../../../../../personalization/controllers/user_controller.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../cart/screens/cart_menu_icon.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());
    final notificationController = Get.put(NotificationController());
    
    return TEComAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nine27 Pharmacy',
            style: Theme.of(context).textTheme.labelMedium!.apply(color: TColors.grey),
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
      actions: [
        Obx(() {
          final currentUserId = AuthenticationRepository.instance.getUserID;
          final unreadCount = notificationController.notifications
              .where((notification) => 
                  notification.seenBy.isEmpty || 
                  notification.seenBy[currentUserId] != true)
              .length;
          
          return Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.notification, color: TColors.white, size: 24),
                onPressed: () => Get.toNamed(TRoutes.notification),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),
        const TCartCounterIcon(iconColor: TColors.white, counterBgColor: TColors.black, counterTextColor: TColors.white),
      ],
    );
  }
}
