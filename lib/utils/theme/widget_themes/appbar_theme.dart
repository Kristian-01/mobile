import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class TAppBarTheme{
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    iconTheme: IconThemeData(color: TColors.iconPrimaryLight, size: 18.0), // Dark Blue #284C76
    actionsIconTheme: IconThemeData(color: TColors.iconPrimaryLight, size: 18.0),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    iconTheme: IconThemeData(color: TColors.iconPrimaryDark, size: 18.0), // White
    actionsIconTheme: IconThemeData(color: TColors.iconPrimaryDark, size: 18.0),
  );
}