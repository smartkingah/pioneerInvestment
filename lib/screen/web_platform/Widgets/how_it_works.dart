import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        color: Colors.amber.withOpacity(0.08),
        width: screenWidth,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Header Section ---
            RichText(
              text: TextSpan(
                text: 'How ',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 48,
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
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                color: Color(0xFF4A4A4A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),

            // --- Steps Section (Responsive) ---
            LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 800;

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
            color: Colors.grey.withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SizedBox(
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
                height: 1.6,
              ),
            ),

            const Spacer(),

            // Step Label
            Text(
              step,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFD4A017),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
