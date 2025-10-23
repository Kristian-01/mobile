import 'package:cwt_starter_template/features/categories/screens/store_screen.dart';
import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/home.dart';
import 'package:cwt_starter_template/features/orders/screens/orders_screen.dart';
import 'package:cwt_starter_template/personalization/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/constants/colors.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? TColors.black : TColors.white,
          indicatorColor: Theme.of(context).brightness == Brightness.dark 
              ? TColors.white.withOpacity(0.1) 
              : TColors.black.withOpacity(0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.shop),
              label: 'Store',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.bag),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const StoreScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];
}
