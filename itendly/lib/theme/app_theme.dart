import 'package:flutter/material.dart';

// =============================================================================
// ITENDLY App Colors — never hard-code colors elsewhere, always use AppColors
// =============================================================================
class AppColors {
  AppColors._();

  // Primary Blue
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryContainer = Color(0xFFD1E4FF);
  static const Color onPrimaryContainer = Color(0xFF001D36);

  // Backgrounds
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2F7);

  // Text
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF44474F);
  static const Color textTertiary = Color(0xFF73777F);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF1B5E20);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color successAccent = Color(0xFF2E7D32);

  static const Color warning = Color(0xFFE65100);
  static const Color warningBg = Color(0xFFFBE9E7);

  static const Color error = Color(0xFFC62828);
  static const Color errorBg = Color(0xFFFFEBEE);

  static const Color absent = Color(0xFFB71C1C);
  static const Color absentBg = Color(0xFFFFEBEE);

  static const Color late = Color(0xFFE65100);
  static const Color lateBg = Color(0xFFFFF3E0);

  // Borders / Dividers
  static const Color divider = Color(0xFFE0E3E7);
  static const Color border = Color(0xFFCAC4D0);
}

// =============================================================================
// Border Radius System
// =============================================================================
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double full = 100.0;
}

// =============================================================================
// Spacing System
// =============================================================================
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  /// Standard horizontal page padding
  static const double horizontal = 20.0;
  static const double vertical = 16.0;
}

// =============================================================================
// Text Styles
// =============================================================================
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textTertiary,
  );
}

// =============================================================================
// ITENDLY Light Theme
// =============================================================================
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: AppTextStyles.titleLarge,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.border,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelMedium,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textTertiary,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.error,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        margin: EdgeInsets.zero,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        insetPadding: const EdgeInsets.all(12),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTextStyles.caption;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 22);
          }
          return const IconThemeData(color: AppColors.textTertiary, size: 22);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryContainer,
        labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        elevation: 8,
      ),
    );
  }
}
