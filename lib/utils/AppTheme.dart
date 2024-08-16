import 'package:flutter/material.dart';
import '../utils/my_colors.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    //primarySwatch: Colors.blue,
    // brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
        color: MyColors.primary,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
        )),
    cardTheme: CardTheme(
      color: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: Colors.white54,
    ),
    textTheme: TextTheme(
      headline6: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
      headline4: TextStyle(
        color: Colors.black54,
      ),
      subtitle2: TextStyle(
        color: Colors.white70,
        fontSize: 18.0,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: MyColors.grey_95,
    brightness: Brightness.dark,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: MyColors.grey_95,
    ),
    appBarTheme: AppBarTheme(
        color: MyColors.primary,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
        )),
    dividerColor: Colors.grey.shade800,
    bottomAppBarTheme: BottomAppBarTheme(color: MyColors.grey_95),
    cardTheme: CardTheme(
      color: MyColors.grey_95,
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    textTheme: TextTheme(
      headline6: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
      subtitle2: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
      headline4: TextStyle(
        color: Colors.white,
      ),
      headline3: TextStyle(
        color: Colors.white,
      ),
      headline2: TextStyle(
        color: Colors.white,
      ),
      headline1: TextStyle(
        color: Colors.white,
      ),
      subtitle1: TextStyle(
        color: Colors.white,
      ),
      bodyText2: TextStyle(
        color: Colors.white,
      ),
      bodyText1: TextStyle(
        color: Colors.white,
      ),
      overline: TextStyle(
        color: Colors.white,
      ),
      caption: TextStyle(
        color: Colors.white,
      ),
    ),
  );
}
