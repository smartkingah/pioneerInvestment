import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WhyChooseInvestProPage extends StatelessWidget {
  const WhyChooseInvestProPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Container(
      color: Colors.amber.withOpacity(0.1),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🏷️ Header
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                'Why Choose ',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Pioneer Capital Limited',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4A017),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Experience the difference of professional investment management with our\nproven approach to wealth creation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: const Color(0xFF4A4A4A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 50),

          // 🧩 Feature Cards (Responsive)
          isMobile
              ? Column(children: _buildFeatureCards())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildFeatureCards(),
                ),
        ],
      ),
    );
  }

  /// 🔹 Builds all feature cards
  List<Widget> _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.remove_red_eye_outlined,
        'title': 'Transparency',
        'description':
            'Every transaction and ROI update tracked in real time with complete visibility into your investment performance.',
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Security',
        'description':
            'Encrypted systems and verified payout processes protect your assets with bank-level security protocols.',
      },
      {
        'icon': Icons.access_time_outlined,
        'title': 'Flexibility',
        'description':
            'Choose daily, weekly, or monthly payout options that fit your investment plan and financial goals.',
      },
      {
        'icon': Icons.show_chart,
        'title': 'Performance',
        'description':
            'Consistent historical ROI built on a disciplined, data-driven strategy with proven track record.',
      },
    ];

    return features
        .map(
          (f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: _buildFeatureCard(
              icon: f['icon'] as IconData,
              title: f['title'] as String,
              description: f['description'] as String,
            ),
          ),
        )
        .toList();
  }

  /// 🔹 Single Feature Card Widget
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => debugPrint('Tapped: $title'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🟡 Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 20),
            // 🏷️ Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // 📝 Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
