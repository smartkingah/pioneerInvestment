import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget firstSide({required BuildContext context}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 600; // breakpoint for responsiveness

  // --- Mobile layout (Column + Scrollable) ---
  if (isMobile) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextSection(context, isMobile),
            const SizedBox(height: 40),
            _buildImageSection(isMobile),
          ],
        ),
      ),
    );
  }

  // --- Desktop/Web layout (Row) ---
  return Padding(
    padding: const EdgeInsets.only(left: 70, right: 40, top: 80, bottom: 60),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _buildTextSection(context, isMobile)),
        const SizedBox(width: 60),
        Expanded(flex: 7, child: _buildImageSection(isMobile)),
      ],
    ),
  );
}

// --- LEFT SIDE TEXT ---
Widget _buildTextSection(BuildContext context, bool isMobile) {
  final headingSize = isMobile ? 38.0 : 65.0;
  final bodySize = isMobile ? 16.0 : 20.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
        softWrap: true,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Smart Investments.\n",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: headingSize,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: "Steady Growth.\n",
              style: GoogleFonts.playfairDisplay(
                color: Colors.yellow,
                fontSize: headingSize,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: "Sustainable Profits.",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: headingSize,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Text(
        "Empowering investors to build wealth through transparent and high-performance investment plans.",
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: bodySize,
          height: 1.6,
          fontWeight: FontWeight.w300,
        ),
      ),
      const SizedBox(height: 40),
      Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 28,
                vertical: isMobile ? 14 : 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Start Investing",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1.5),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 28,
                vertical: isMobile ? 14 : 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Learn More",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// --- RIGHT SIDE IMAGE ---
Widget _buildImageSection(bool isMobile) {
  final imageWidth = isMobile ? double.infinity : 550.0;
  final imageHeight = isMobile ? 250.0 : 380.0;

  return Stack(
    alignment: Alignment.center,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl:
              "https://res.cloudinary.com/dy523yrlh/image/upload/v1760524563/2d34c2517f56936e33a9915c6eb58abf_z665ga.jpg",
          width: imageWidth,
          height: imageHeight,
        ),
      ),
      Positioned(
        bottom: 20,
        right: isMobile ? 16 : 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "\$15M+",
                style: GoogleFonts.playfairDisplay(
                  color: const Color(0xFFD4AF37),
                  fontSize: isMobile ? 22 : 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Assets Under Management",
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
