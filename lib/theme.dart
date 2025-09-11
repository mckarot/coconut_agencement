import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales basées sur la nouvelle couleur (111, 51, 34)
  static const Color primaryColor = Color(0xFF6F3322);
  static const Color primaryColorLight = Color(0xFFA16450);
  static const Color primaryColorDark = Color(0xFF441105);
  
  // Couleurs secondaires
  static const Color secondaryColor = Color.fromARGB(255, 247, 191, 86); // Or
  static const Color accentColor = Color.fromARGB(255, 255, 140, 0); // Orange
  
  // Couleurs neutres
  static const Color backgroundColor = Color.fromARGB(255, 245, 245, 245);
  static const Color surfaceColor = Color.fromARGB(255, 255, 255, 255);
  static const Color textColorPrimary = Color.fromARGB(255, 33, 33, 33);
  static const Color textColorSecondary = Color.fromARGB(255, 117, 117, 117);
  
  // Couleurs d'état
  static const Color successColor = Color.fromARGB(255, 76, 175, 80);
  static const Color warningColor = Color.fromARGB(255, 255, 152, 0);
  static const Color errorColor = Color.fromARGB(255, 244, 67, 54);
  
  // Palette de gris
  static const Color greyLight = Color.fromARGB(255, 240, 240, 240);
  static const Color grey = Color.fromARGB(255, 200, 200, 200);
  static const Color greyDark = Color.fromARGB(255, 120, 120, 120);
  
  // Espacement
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  
  // Bordures
  static const double borderWidth = 1.0;
  static const Radius borderRadiusSm = Radius.circular(4.0);
  static const Radius borderRadiusMd = Radius.circular(8.0);
  static const Radius borderRadiusLg = Radius.circular(16.0);
  
  // Typographie
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: textColorPrimary,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: textColorPrimary,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: textColorPrimary,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: textColorPrimary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: textColorPrimary,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: textColorPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: textColorPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: textColorPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: textColorSecondary,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: textColorPrimary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: textColorPrimary,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    color: textColorSecondary,
  );
  
  // Méthode pour obtenir le thème complet
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        onPrimary: surfaceColor,
        secondary: secondaryColor,
        onSecondary: textColorPrimary,
        surface: surfaceColor,
        surfaceTint: backgroundColor, // Replacing deprecated background with surfaceTint
        error: errorColor,
        onError: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: surfaceColor,
        titleTextStyle: headlineSmall,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: greyDark,
        elevation: 8.0,
      ),
      textTheme: const TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          textStyle: labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2.0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: labelLarge,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(borderRadiusMd),
          borderSide: const BorderSide(color: grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(borderRadiusMd),
          borderSide: const BorderSide(color: grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(borderRadiusMd),
          borderSide: const BorderSide(color: primaryColor),
        ),
        labelStyle: bodySmall,
        floatingLabelStyle: bodySmall,
      ),
      // cardTheme: CardTheme(
      //   color: surfaceColor,
      //   elevation: 2.0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(borderRadiusMd),
      //   ),
      // ),
    );
  }
}