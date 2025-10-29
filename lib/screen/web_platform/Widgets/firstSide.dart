import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/screen/Dash_baord/dashbaord.dart';
import 'package:investmentpro/screen/authentication/login.dart';
import 'package:investmentpro/screen/web_platform/Widgets/learmore.dart';

Widget firstSide({required BuildContext context}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Better breakpoints for different screen sizes
  final isMobile = screenWidth < 600;
  final isTablet = screenWidth >= 600 && screenWidth < 1024;
  final isDesktop = screenWidth >= 1024;

  // --- Mobile layout (< 600px) ---
  if (isMobile) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextSection(context, screenWidth),
            const SizedBox(height: 65),
            _buildImageSection(screenWidth),
          ],
        ),
      ),
    );
  }

  // --- Tablet layout (600-1024px) ---
  if (isTablet) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextSection(context, screenWidth),
            const SizedBox(height: 50),
            _buildImageSection(screenWidth),
          ],
        ),
      ),
    );
  }

  // --- Desktop layout (>= 1024px) - Centered vertically and horizontally ---
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1400),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.25,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(flex: 4, child: _buildTextSection(context, screenWidth)),
            SizedBox(width: screenWidth * 0.05),
            Expanded(flex: 5, child: _buildImageSection(screenWidth)),
          ],
        ),
      ),
    ),
  );
}

// --- LEFT SIDE TEXT ---
Widget _buildTextSection(BuildContext context, double screenWidth) {
  // Responsive font sizes based on screen width (scaled down)
  double headingSize;
  double bodySize;
  double buttonFontSize;

  if (screenWidth < 400) {
    headingSize = 28.0;
    bodySize = 13.0;
    buttonFontSize = 12.0;
  } else if (screenWidth < 600) {
    headingSize = 34.0;
    bodySize = 15.0;
    buttonFontSize = 13.0;
  } else if (screenWidth < 900) {
    headingSize = 40.0;
    bodySize = 16.0;
    buttonFontSize = 14.0;
  } else if (screenWidth < 1200) {
    headingSize = 48.0;
    bodySize = 17.0;
    buttonFontSize = 15.0;
  } else {
    headingSize = 60.0;
    bodySize = 20.0;
    buttonFontSize = 15.0;
  }

  return Column(
    crossAxisAlignment: screenWidth < 600
        ? CrossAxisAlignment.start
        : (screenWidth < 1024
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start),
    children: [
      // Animated gradient bar above heading
      Container(
        width: 80,
        height: 4,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0ECB81), Color(0xFFD4A017)],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(height: 24),

      RichText(
        textAlign: screenWidth < 1024 && screenWidth >= 600
            ? TextAlign.center
            : TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Smart Investments.\n",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: headingSize,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: "Steady ",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: headingSize,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: "Growth",
              style: GoogleFonts.playfairDisplay(
                color: const Color(0xFF0ECB81),
                fontSize: headingSize,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: ".\n",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: headingSize,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: "Sustainable ",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: headingSize,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: "Profits",
              style: GoogleFonts.playfairDisplay(
                color: Colors.red,
                fontSize: headingSize,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: ".",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: headingSize,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Text(
        "Empowering investors to build wealth through transparent and high-performance investment plans.",
        textAlign: screenWidth < 1024 && screenWidth >= 600
            ? TextAlign.center
            : TextAlign.left,
        style: GoogleFonts.playfairDisplay(
          color: Colors.white.withOpacity(0.7),
          fontSize: bodySize,
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
      const SizedBox(height: 32),
      Wrap(
        alignment: screenWidth < 600
            ? WrapAlignment.start
            : (screenWidth < 1024 ? WrapAlignment.center : WrapAlignment.start),
        spacing: 16,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: () {
              Get.to(() => LoginPage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0ECB81),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 600 ? 28 : 36,
                vertical: screenWidth < 600 ? 16 : 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Start Investing",
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: buttonFontSize,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Get.to(() => PioneerLearnMorePage());
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red, width: 1.5),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 600 ? 28 : 36,
                vertical: screenWidth < 600 ? 16 : 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Learn More",
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: buttonFontSize,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// --- RIGHT SIDE IMAGE ---
Widget _buildImageSection(double screenWidth) {
  double imageHeight;
  double statsSize;
  double statsSubSize;

  if (screenWidth < 400) {
    imageHeight = 220.0;
    statsSize = 20.0;
    statsSubSize = 11.0;
  } else if (screenWidth < 600) {
    imageHeight = 280.0;
    statsSize = 24.0;
    statsSubSize = 12.0;
  } else if (screenWidth < 900) {
    imageHeight = 320.0;
    statsSize = 26.0;
    statsSubSize = 13.0;
  } else if (screenWidth < 1200) {
    imageHeight = 380.0;
    statsSize = 28.0;
    statsSubSize = 14.0;
  } else {
    imageHeight = 450.0;
    statsSize = 30.0;
    statsSubSize = 14.0;
  }

  return Stack(
    alignment: Alignment.center,
    children: [
      // Modern glass morphism container
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0ECB81).withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl:
                "https://res.cloudinary.com/dy523yrlh/image/upload/v1760524563/2d34c2517f56936e33a9915c6eb58abf_z665ga.jpg",
            width: double.infinity,
            height: imageHeight,
          ),
        ),
      ),
      // Modern stats badge with glass effect
      Positioned(
        bottom: screenWidth < 600 ? 20 : 24,
        right: screenWidth < 600 ? 20 : 24,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth < 600 ? 20 : 24,
            vertical: screenWidth < 600 ? 14 : 16,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF0ECB81).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0ECB81).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Color(0xFF0ECB81),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "\$15M+",
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF0ECB81),
                      fontSize: statsSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Assets Under Management",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: statsSubSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
