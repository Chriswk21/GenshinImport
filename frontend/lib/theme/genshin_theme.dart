import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenshinTheme {
  static const Color primaryGold = Color(0xFFD3BC8E);
  static const Color secondaryGold = Color(0xFFA78B50);
  static const Color bgDark = Color(0xFF0A0F1D);
  static const Color bgCard = Color(0xFF161F32);
  static const Color accentCyan = Color(0xFF3AAFA9);
  static const Color accentRed = Color(0xFFE06C75);

  static const Color textParchment = Color(0xFFECE5D8);
  static const Color textMuted = Color(0xFF9E9F9F);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryGold,
      fontFamily: GoogleFonts.inter().fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: accentCyan,
        surface: bgCard,
        error: accentRed,
        onPrimary: bgDark,
        onSecondary: bgDark,
        onSurface: textParchment,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryGold,
          letterSpacing: 1.5,
        ),
        displayMedium: GoogleFonts.cinzel(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryGold,
          letterSpacing: 1.2,
        ),
        titleLarge: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryGold,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textParchment,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textParchment,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textMuted,
        ),
      ),

      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 6,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF334155), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: bgDark,
          textStyle: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: secondaryGold, width: 1),
          ),
          elevation: 4,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          side: const BorderSide(color: primaryGold, width: 1.5),
          textStyle: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: primaryGold),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentRed, width: 2),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: bgCard,
        elevation: 10,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: primaryGold, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static BoxDecoration get goldBorderDecoration {
    return BoxDecoration(
      color: bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: primaryGold, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33D3BC8E),
          offset: Offset(0, 4),
          blurRadius: 10,
        )
      ],
    );
  }

  static BoxDecoration get mysticBackground {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [bgDark, Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  static Widget buildItemImage(String imagePath, {double? width, double? height, BoxFit fit = BoxFit.cover, double? iconSize}) {
    final fallbackIcon = Icon(
      Icons.auto_awesome,
      size: iconSize ?? 40,
      color: primaryGold,
    );

    if (imagePath.isEmpty) {
      return Container(
        color: const Color(0xFF1E293B),
        width: width,
        height: height,
        child: Center(child: fallbackIcon),
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF1E293B),
          width: width,
          height: height,
          child: Center(child: fallbackIcon),
        ),
      );
    } else {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF1E293B),
          width: width,
          height: height,
          child: Center(child: fallbackIcon),
        ),
      );
    }
  }
}
