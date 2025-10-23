import 'package:cwt_starter_template/common/widgets/drawer/drawer.dart';
import 'package:flutter/material.dart';

import '../../../../../personalization/controllers/user_controller.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import 'widgets/appbar.dart';
import 'widgets/top_courses.dart';

class CoursesDashboard extends StatelessWidget {
  const CoursesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    //Variables
    final txtTheme = Theme.of(context).textTheme;


    return SafeArea(
      child: Scaffold(
        appBar: DashboardAppBar(),

        /// Create a new Header
        drawer: TDrawer(),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(TSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Heading
                Text(UserController.instance.user.value.fullName.isEmpty ? TTexts.tDashboardTitle: "Hey, ${UserController.instance.user.value.fullName}", style: txtTheme.bodyMedium),
                const SizedBox(height: TSizes.lg),

                //Top Course
                Text(TTexts.tDashboardTopCourses, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
                DashboardTopCourses(txtTheme: txtTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
