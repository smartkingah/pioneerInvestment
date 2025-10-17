import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          color: Colors.amber.withOpacity(0.08),
          width: screenWidth,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 80,
            vertical: isMobile ? 40 : 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Header Section ---
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'How ',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isMobile ? 32 : 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: const [
                    TextSpan(
                      text: 'It Works',
                      style: TextStyle(color: Color(0xFFD4A017)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Get started with our simple three-step process and begin your journey to financial growth.',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 16 : 18,
                  color: const Color(0xFF4A4A4A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 50),

              // --- Steps Section (Responsive) ---
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;
                  return Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildStepCard(
                        icon: Icons.person_add_outlined,
                        title: 'Create an Account',
                        description:
                            'Register and verify your identity securely with our streamlined onboarding process.',
                        step: 'Step 1',
                        isMobile: isMobile,
                      ),
                      if (!isMobile) const SizedBox(width: 40),
                      _buildStepCard(
                        icon: Icons.gif_outlined,
                        title: 'Select a Package',
                        description:
                            'Choose an investment plan aligned with your financial goals and risk tolerance.',
                        step: 'Step 2',
                        isMobile: isMobile,
                      ),
                      if (!isMobile) const SizedBox(width: 40),
                      _buildStepCard(
                        icon: Icons.show_chart_outlined,
                        title: 'Track & Earn',
                        description:
                            'Monitor your growth in real-time and withdraw profits instantly to your wallet.',
                        step: 'Step 3',
                        isMobile: isMobile,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String description,
    required String step,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? double.infinity : 300,
      margin: EdgeInsets.only(bottom: isMobile ? 40 : 0, left: 10, right: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // <— key fix
        children: [
          // Icon
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

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A4A),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            step,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFD4A017),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
