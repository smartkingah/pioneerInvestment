import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutInvestProPage extends StatelessWidget {
  const AboutInvestProPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Container(
      color: Colors.transparent,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 100,
        vertical: isMobile ? 40 : 60,
      ),
      child: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  /// 🖥️ Desktop Layout
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Text Section
        Expanded(flex: 1, child: _buildTextSection(isMobile: false)),
        const SizedBox(width: 60),
        // Right Image Section
        Expanded(flex: 1, child: _buildImageSection()),
      ],
    );
  }

  /// 📱 Mobile Layout
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildImageSection(),
        const SizedBox(height: 40),
        _buildTextSection(isMobile: true),
      ],
    );
  }

  /// Text Section (used for both mobile & desktop)
  Widget _buildTextSection({required bool isMobile}) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Text(
              'About ',
              style: GoogleFonts.playfairDisplay(
                fontSize: isMobile ? 30 : 44,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Pioneer Capital Limited',
              style: GoogleFonts.playfairDisplay(
                fontSize: isMobile ? 30 : 38,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4A017),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _buildParagraph(
          'Our investment platform serves both new and professional investors seeking secure and structured profit growth. With automated payout systems, real-time dashboards, and integrated wallets, we make wealth creation predictable and accessible.',
          const Color(0xFF4A4A4A),
          FontWeight.w400,
          isMobile,
        ),
        const SizedBox(height: 16),
        _buildParagraph(
          'Our mission is to create a transparent ecosystem where investors experience confidence, clarity, and measurable success. We combine cutting-edge technology with proven investment strategies to deliver consistent returns.',
          const Color(0xFF4A4A4A),
          FontWeight.w400,
          isMobile,
        ),
        const SizedBox(height: 16),
        _buildParagraph(
          'Join thousands of investors who trust us with their financial future and experience the difference of professional-grade investment management.',
          Colors.black,
          FontWeight.w700,
          isMobile,
        ),
      ],
    );
  }

  /// Image Section with Badge
  Widget _buildImageSection() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl:
                  'https://res.cloudinary.com/dy523yrlh/image/upload/v1760524563/34e923ef198783632b7475ac16eb89bb_nmwtjg.jpg',
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '98%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Success Rate',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable paragraph builder
  Widget _buildParagraph(
    String text,
    Color color,
    FontWeight fw,
    bool isMobile,
  ) {
    return Text(
      text,
      textAlign: isMobile ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: isMobile ? 16 : 18,
        color: color,
        height: 1.7,
        fontWeight: fw,
      ),
    );
  }
}
