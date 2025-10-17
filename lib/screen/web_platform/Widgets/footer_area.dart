import 'package:flutter/material.dart';

class InvestProFooter extends StatelessWidget {
  const InvestProFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 30 : 40,
        horizontal: isMobile ? 20 : 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Footer Row or Column
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompanyInfo(isMobile),
                    const SizedBox(height: 30),
                    _buildQuickLinks(isMobile),
                    const SizedBox(height: 40),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildCompanyInfo(isMobile)),
                    const SizedBox(width: 60),
                    Expanded(flex: 1, child: _buildQuickLinks(isMobile)),
                  ],
                ),

          const SizedBox(height: 30),
          const Divider(color: Colors.grey, thickness: 1, height: 1),
          const SizedBox(height: 32),

          // Important Note
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4A017),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your success is our priority. Every investment plan is designed with stability, transparency, and consistent growth in mind. We combine smart strategies with expert management to ensure your funds work efficiently for you. Join us and experience secure, steady financial progress.',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: const Color(0xFFAAAAAA),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Bottom Bar
          const Divider(color: Colors.grey, thickness: 1, height: 1),
          const SizedBox(height: 20),

          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '© 2025 Pioneer Capital Limited. All Rights Reserved.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2025 Pioneer Capital Limited. All Rights Reserved.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  /// --- COMPANY INFO ---
  Widget _buildCompanyInfo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pioneer Capital Limited',
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4A017),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Empowering investors worldwide with transparent, secure, and high-performance investment solutions. Building wealth through structured growth and consistent returns.',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: const Color(0xFFAAAAAA),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildContactRow(Icons.email, 'contact@investprocapital.com'),
        const SizedBox(height: 8),
        _buildContactRow(Icons.phone, '+44 7853 752 212'),
        const SizedBox(height: 8),
        _buildContactRow(Icons.location_on, 'London, United Kingdom, W1G 7AJ'),
      ],
    );
  }

  /// --- QUICK LINKS ---
  Widget _buildQuickLinks(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildQuickLink('Terms of Service'),
        const SizedBox(height: 12),
        _buildQuickLink('Privacy Policy'),
        const SizedBox(height: 12),
        _buildQuickLink('Contact Us'),
        const SizedBox(height: 12),
        _buildQuickLink('FAQs'),
      ],
    );
  }

  /// --- CONTACT ROW ---
  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.amber, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
          ),
        ),
      ],
    );
  }

  /// --- QUICK LINK BUTTON ---
  Widget _buildQuickLink(String text) {
    return TextButton(
      onPressed: () {
        debugPrint('Navigating to: $text');
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        minimumSize: Size.zero,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFFAAAAAA),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
