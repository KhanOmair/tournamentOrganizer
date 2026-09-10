import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Midnight Court colors, shared by every screen and interaction state.
abstract final class AppColors {
  static const background = Color(0xFF101820);
  static const surface = Color(0xFF1B2732);
  static const elevated = Color(0xFF233340);
  static const primary = Color(0xFFD4F45B);
  static const text = Color(0xFFF4F7EF);
  static const muted = Color(0xFFA7B4C2);
  static const border = Color(0xFF344453);
  static const success = Color(0xFF70DDB2);
  static const successSurface = Color(0xFF243C35);
  static const warning = Color(0xFFF5C46B);
  static const error = Color(0xFFFF8793);
}

TextStyle courtHeading(double size, {Color color = AppColors.text}) =>
    TextStyle(
      fontFamily: 'BarlowCondensed',
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: 1.1,
      color: color,
    );

final ThemeData midnightCourtTheme = _buildTheme();

ThemeData _buildTheme() {
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  final scheme =
      const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        primaryContainer: AppColors.elevated,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.success,
        onSecondary: AppColors.background,
        secondaryContainer: AppColors.successSurface,
        onSecondaryContainer: AppColors.success,
        error: AppColors.error,
        onError: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        onSurfaceVariant: AppColors.muted,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        surfaceTint: Colors.transparent,
      ).copyWith(
        surfaceContainerLowest: AppColors.background,
        surfaceContainerLow: AppColors.surface,
        surfaceContainer: AppColors.surface,
        surfaceContainerHigh: AppColors.elevated,
        surfaceContainerHighest: AppColors.elevated,
      );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
  );
  final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.background,
    disabledBackgroundColor: AppColors.elevated,
    disabledForegroundColor: AppColors.muted,
    elevation: 0,
    minimumSize: const Size(48, 48),
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
    textStyle: const TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
  return base.copyWith(
    primaryColor: AppColors.primary,
    cardColor: AppColors.surface,
    dividerColor: AppColors.border,
    textTheme: base.textTheme.copyWith(
      displayLarge: courtHeading(64),
      displayMedium: courtHeading(52),
      displaySmall: courtHeading(44),
      headlineLarge: courtHeading(40),
      headlineMedium: courtHeading(34),
      headlineSmall: courtHeading(28),
      titleLarge: courtHeading(24),
      titleMedium: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      bodyLarge: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.5,
        color: AppColors.text,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.5,
        color: AppColors.text,
      ),
      bodySmall: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 1.5,
        color: AppColors.muted,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: courtHeading(26),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: shape.copyWith(side: const BorderSide(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: shape,
      titleTextStyle: courtHeading(30),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: shape,
      showDragHandle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
    filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(48, 44),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.background,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      border: inputBorder(AppColors.border),
      enabledBorder: inputBorder(AppColors.border),
      focusedBorder: inputBorder(AppColors.primary, 2),
      errorBorder: inputBorder(AppColors.error),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.primary,
      dividerColor: AppColors.border,
      labelStyle: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.elevated,
      checkmarkColor: AppColors.primary,
      side: const BorderSide(color: AppColors.border),
      labelStyle: const TextStyle(
        color: AppColors.text,
        fontFamily: 'Inter',
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.text,
      iconColor: AppColors.muted,
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    ),
    expansionTileTheme: const ExpansionTileThemeData(
      textColor: AppColors.text,
      collapsedTextColor: AppColors.text,
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.muted,
      shape: Border(),
      collapsedShape: Border(),
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: base.textTheme.bodySmall!.copyWith(
        color: AppColors.muted,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: base.textTheme.bodyMedium,
      dividerThickness: .5,
      horizontalMargin: 16,
      columnSpacing: 24,
      dataRowMinHeight: 56,
      dataRowMaxHeight: 80,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.elevated,
      contentTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: AppColors.text,
      ),
      actionTextColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.elevated,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );
}
