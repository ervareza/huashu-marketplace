import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ═══════════════════════════════════════════════════════════
/// HUASHU DESIGN SYSTEM — Full Implementation
/// ═══════════════════════════════════════════════════════════
/// Filosofi: "Tinta di atas kertas Xuan — keheningan berbicara"
/// Anti-slop: 0px radius, tanpa drop-shadow, tanpa gradien AI.
/// Prinsip: Negatif space, tipografi sebagai ornamen, garis kuas.
/// ═══════════════════════════════════════════════════════════
class HuashuTheme {
  HuashuTheme._();

  // ─── TOKEN WARNA MINERAL TRADISIONAL ─────────────────────
  static const Color xuanPaperBg = Color(0xFFF7F5F0);       // Kertas Xuan
  static const Color charcoalBlack = Color(0xFF1E1E1E);      // Arang tinta
  static const Color mineralJadeGreen = Color(0xFF2D5A43);   // Giok mineral
  static const Color stainedCinnabarRed = Color(0xFFB83A2C); // Sinabar usang
  static const Color lightInkLine = Color(0xFFE2DFD5);       // Garis tinta tipis
  static const Color warmStone = Color(0xFFD4CFC4);          // Batu hangat
  static const Color agedGold = Color(0xFF8B7D3C);           // Emas tua
  static const Color fadedIndigo = Color(0xFF4A5568);         // Nila pudar

  // ─── SPACING SCALE (kelipatan 8 — ritme vertikal) ────────
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;
  static const double space64 = 64;

  // ─── BORDER WIDTH SCALE ──────────────────────────────────
  static const double hairline = 0.5;
  static const double thin = 1.0;
  static const double medium = 1.5;
  static const double thick = 2.0;

  // ─── THEME DATA ──────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: xuanPaperBg,
      colorScheme: const ColorScheme.light(
        primary: mineralJadeGreen,
        onPrimary: xuanPaperBg,
        secondary: charcoalBlack,
        onSecondary: xuanPaperBg,
        error: stainedCinnabarRed,
        onError: xuanPaperBg,
        surface: xuanPaperBg,
        onSurface: charcoalBlack,
      ),

      // AppBar — transparan, tanpa bayangan
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: charcoalBlack,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSerifSc(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: charcoalBlack,
          letterSpacing: 0.5,
        ),
      ),

      // Card — tanpa radius, tanpa bayangan, border tipis
      cardTheme: const CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: lightInkLine, width: hairline),
          borderRadius: BorderRadius.zero,
        ),
      ),

      // Divider — garis tinta
      dividerTheme: const DividerThemeData(
        color: lightInkLine,
        thickness: hairline,
        space: 0,
      ),

      // ─── TIPOGRAFI RITME PUITIS ──────────────────────────
      textTheme: TextTheme(
        // Judul besar (login, register header)
        displayLarge: GoogleFonts.notoSerifSc(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: charcoalBlack,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        // Judul medium (nama produk detail)
        headlineMedium: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoalBlack,
          height: 1.3,
        ),
        // Judul kecil (section header)
        titleMedium: GoogleFonts.notoSerifSc(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: charcoalBlack,
        ),
        // Body besar (deskripsi)
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          height: 1.7,
          color: charcoalBlack,
          letterSpacing: 0.1,
        ),
        // Body medium (paragraf)
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          height: 1.6,
          color: charcoalBlack.withValues(alpha: 0.8),
        ),
        // Label kecil (kategori, timestamp)
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          letterSpacing: 2.0,
          fontWeight: FontWeight.w600,
          color: charcoalBlack.withValues(alpha: 0.5),
        ),
      ),

      // ─── INPUT FIELD BERGAYA KALIGRAFI ────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: charcoalBlack, width: hairline),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: lightInkLine, width: hairline),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: mineralJadeGreen, width: thin),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: stainedCinnabarRed, width: hairline),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: stainedCinnabarRed, width: thin),
        ),
        labelStyle: GoogleFonts.inter(
          color: charcoalBlack.withValues(alpha: 0.6),
          fontSize: 14,
          letterSpacing: 0.3,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: mineralJadeGreen,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          color: charcoalBlack.withValues(alpha: 0.3),
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.inter(
          color: stainedCinnabarRed,
          fontSize: 12,
        ),
      ),

      // ─── TOMBOL PERSEGI TAJAM (0px RADIUS) ────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoalBlack,
          foregroundColor: xuanPaperBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(0, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoalBlack,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: charcoalBlack, width: hairline),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: charcoalBlack,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),

      // ChoiceChip
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: charcoalBlack,
        disabledColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(fontSize: 12, letterSpacing: 0.5),
        side: const BorderSide(color: lightInkLine, width: hairline),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: charcoalBlack,
        contentTextStyle: GoogleFonts.inter(
          color: xuanPaperBg,
          fontSize: 13,
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: xuanPaperBg,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        titleTextStyle: GoogleFonts.notoSerifSc(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: charcoalBlack,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          height: 1.6,
          color: charcoalBlack.withValues(alpha: 0.8),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: xuanPaperBg,
        elevation: 0,
        selectedItemColor: charcoalBlack,
        unselectedItemColor: lightInkLine,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: mineralJadeGreen,
        linearTrackColor: lightInkLine,
        circularTrackColor: lightInkLine,
      ),

      // Badge
      badgeTheme: const BadgeThemeData(
        backgroundColor: stainedCinnabarRed,
        textColor: xuanPaperBg,
      ),

      // Scrollbar
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(warmStone),
        thickness: WidgetStateProperty.all(3),
        radius: Radius.zero,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: charcoalBlack,
        size: 22,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HUASHU DECORATIVE WIDGETS
// ═══════════════════════════════════════════════════════════

/// Stempel merah tradisional — ikon identitas Huashu
class HuashuSeal extends StatelessWidget {
  final String character;
  final double size;
  final Color color;

  const HuashuSeal({
    super.key,
    required this.character,
    this.size = 50,
    this.color = HuashuTheme.stainedCinnabarRed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: HuashuTheme.medium),
      ),
      alignment: Alignment.center,
      child: Text(
        character,
        style: GoogleFonts.notoSerifSc(
          fontSize: size * 0.48,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

/// Bingkai ganda tradisional (untuk gambar produk)
class HuashuDoubleFrame extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const HuashuDoubleFrame({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: HuashuTheme.lightInkLine, width: HuashuTheme.hairline),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: HuashuTheme.lightInkLine, width: HuashuTheme.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

/// Kotak pesan status (error/success/info) gaya stempel
class HuashuStatusBox extends StatelessWidget {
  final String message;
  final HuashuStatusType type;

  const HuashuStatusBox({
    super.key,
    required this.message,
    this.type = HuashuStatusType.error,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      HuashuStatusType.error => HuashuTheme.stainedCinnabarRed,
      HuashuStatusType.success => HuashuTheme.mineralJadeGreen,
      HuashuStatusType.info => HuashuTheme.charcoalBlack,
    };
    final icon = switch (type) {
      HuashuStatusType.error => Icons.error_outline,
      HuashuStatusType.success => Icons.check_circle_outline,
      HuashuStatusType.info => Icons.info_outline,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: HuashuTheme.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(color: color, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

enum HuashuStatusType { error, success, info }

/// Tombol status stempel (untuk order history)
class HuashuStampBadge extends StatelessWidget {
  final String label;
  final Color color;

  const HuashuStampBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 0.7),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Section header bergaya label kaligrafi
class HuashuSectionLabel extends StatelessWidget {
  final String text;

  const HuashuSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        letterSpacing: 2.0,
        fontWeight: FontWeight.w600,
        color: HuashuTheme.charcoalBlack.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Harga bergaya sinabar serif
class HuashuPrice extends StatelessWidget {
  final String price;
  final double fontSize;

  const HuashuPrice({
    super.key,
    required this.price,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      price,
      style: GoogleFonts.notoSerifSc(
        color: HuashuTheme.stainedCinnabarRed,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Empty state widget dengan ikon dan pesan
class HuashuEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const HuashuEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HuashuTheme.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: HuashuTheme.lightInkLine, size: 48),
            const SizedBox(height: HuashuTheme.space16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: HuashuTheme.charcoalBlack.withValues(alpha: 0.4),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: HuashuTheme.space24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryLabel ?? 'COBA LAGI'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
