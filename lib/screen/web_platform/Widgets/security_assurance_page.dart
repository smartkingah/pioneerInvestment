import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityAssurancePage extends StatelessWidget {
  const SecurityAssurancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: screenWidth,
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 100,
            vertical: isMobile ? 40 : 80,
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextSection(isMobile),
                    const SizedBox(height: 40),
                    _buildImageSection(isMobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildTextSection(isMobile)),
                    const SizedBox(width: 80),
                    Expanded(flex: 2, child: _buildImageSection(isMobile)),
                  ],
                ),
        ),
      ),
    );
  }

  /// --- LEFT SIDE: TEXT CONTENT ---
  Widget _buildTextSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        RichText(
          text: TextSpan(
            text: 'Security ',
            style: GoogleFonts.playfairDisplay(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: '& Assurance',
                style: GoogleFonts.playfairDisplay(
                  color: const Color(0xFFD4A017),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Paragraphs
        Text(
          'Our infrastructure is protected by advanced encryption, multi-layer authentication, '
          'and compliant asset-management standards. Every transaction is verifiable, ensuring investors '
          'maintain full visibility and confidence in their portfolio.',
          style: TextStyle(
            fontSize: isMobile ? 15 : 17,
            height: 1.6,
            color: const Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'We prioritize protection, governance, and long-term trust. '
          'Our security protocols exceed industry standards, giving you peace of mind while your investments grow.',
          style: TextStyle(
            fontSize: isMobile ? 15 : 17,
            height: 1.6,
            color: const Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 40),

        // --- Feature Icons Grid ---
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildFeature(
              icon: Icons.lock_outline,
              title: 'Advanced Encryption',
              description:
                  'Bank-level SSL encryption protects all data transmission and storage.',
              isMobile: isMobile,
            ),
            _buildFeature(
              icon: Icons.verified_user_outlined,
              title: 'Multi-Layer Authentication',
              description:
                  'Multiple verification steps ensure only authorized access to accounts.',
              isMobile: isMobile,
            ),
            _buildFeature(
              icon: Icons.visibility_outlined,
              title: 'Full Transparency',
              description:
                  'Every transaction is verifiable and tracked in real-time dashboards.',
              isMobile: isMobile,
            ),
            _buildFeature(
              icon: Icons.policy_outlined,
              title: 'Compliance Standards',
              description:
                  'Fully compliant with international asset-management regulations.',
              isMobile: isMobile,
            ),
          ],
        ),
      ],
    );
  }

  /// --- RIGHT SIDE: IMAGE CONTENT ---
  Widget _buildImageSection(bool isMobile) {
    return Column(
      children: [
        Container(
          height: isMobile ? 250 : 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: CachedNetworkImageProvider(
                "https://res.cloudinary.com/dy523yrlh/image/upload/v1760524563/2d81bb646fcbaecbec1d7d0af5d42f3d_grwjn9.jpg",
              ),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFD4A017),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            '100% Secure Transactions',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }

  /// --- REUSABLE FEATURE BOX ---
  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required bool isMobile,
  }) {
    return SizedBox(
      width: isMobile ? double.infinity : 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5D5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFD4A017)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A4A4A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
