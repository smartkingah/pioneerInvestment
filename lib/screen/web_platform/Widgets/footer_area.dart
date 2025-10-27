import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/screen/faqs_terms_contition/faqs.dart';
import 'package:url_launcher/url_launcher.dart';

class InvestProFooter extends StatelessWidget {
  const InvestProFooter({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF0A0A0A), const Color(0xFF000000)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 60,
        horizontal: isMobile ? 20 : 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Footer Content
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompanyInfo(isMobile),
                    const SizedBox(height: 40),
                    _buildQuickLinks(isMobile),
                    const SizedBox(height: 40),
                    _buildSocialMedia(isMobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildCompanyInfo(isMobile)),
                    const SizedBox(width: 80),
                    Expanded(flex: 2, child: _buildQuickLinks(isMobile)),
                    const SizedBox(width: 60),
                    Expanded(flex: 2, child: _buildSocialMedia(isMobile)),
                  ],
                ),

          const SizedBox(height: 50),

          // Important Note Card
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFD4A017).withOpacity(0.15),
                  const Color(0xFFD4A017).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4A017).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.shield_fill,
                    color: Color(0xFFD4A017),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Investment Protection',
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD4A017),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your success is our priority. Every investment plan is designed with stability, transparency, and consistent growth in mind. We combine smart strategies with expert management to ensure your funds work efficiently for you.',
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 13 : 14,
                          color: Colors.white70,
                          height: 1.7,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Bottom Bar
          isMobile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        '© 2025 Pioneer Capital Limited',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'All Rights Reserved',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          '© 2025 Pioneer Capital Limited',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4A017),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          'All Rights Reserved',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.lock_shield_fill,
                          size: 16,
                          color: const Color(0xFFD4A017),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Secured by Blockchain',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  /// Company Info Section
  Widget _buildCompanyInfo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD4A017).withOpacity(0.3),
                    const Color(0xFFD4A017).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.building_2_fill,
                color: Color(0xFFD4A017),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Pioneer Capital Limited',
              style: GoogleFonts.inter(
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD4A017),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Empowering investors worldwide with transparent, secure, and high-performance investment solutions. Building wealth through structured growth and consistent returns.',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 13 : 14,
            color: Colors.white70,
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 28),
        _buildContactItem(
          icon: CupertinoIcons.mail_solid,
          text: 'contact@pioneercapitalltd.com',
          onTap: () => _launchEmail('contact@pioneercapitalltd.com'),
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          icon: CupertinoIcons.phone_fill,
          text: '+44 7853 752 212',
          onTap: () => _launchPhone('+447853752212'),
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          icon: CupertinoIcons.location_solid,
          text: 'London, United Kingdom, W1G 7AJ',
          onTap: null,
        ),
      ],
    );
  }

  /// Quick Links Section
  Widget _buildQuickLinks(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 17 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),
        _buildLinkItem('Terms of Service', CupertinoIcons.doc_text),
        const SizedBox(height: 12),
        _buildLinkItem('Privacy Policy', CupertinoIcons.lock_shield),
        const SizedBox(height: 12),
        _buildLinkItem('Contact Us', CupertinoIcons.chat_bubble_2),
        const SizedBox(height: 12),
        _buildLinkItem('FAQs', CupertinoIcons.question_circle),
        const SizedBox(height: 12),
        _buildLinkItem('Investment Plans', CupertinoIcons.chart_bar),
      ],
    );
  }

  /// Social Media Section
  Widget _buildSocialMedia(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect With Us',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 17 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSocialButton(
              icon: Icons.language,
              label: 'Website',
              onTap: () => _launchUrl('https://www.pioneercapitallimited.com'),
            ),
            _buildSocialButton(
              icon: Icons.mail_outline,
              label: 'Email',
              onTap: () => _launchEmail('contact@investprocapital.com'),
            ),
            _buildSocialButton(
              icon: Icons.support_agent,
              label: 'Support',
              onTap: () => Get.to(() => LegalAndSupportScreen()),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.clock_fill,
                color: Color(0xFFD4A017),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '24/7 Customer Support',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Contact Item Widget
  Widget _buildContactItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: const Color(0xFFD4A017), size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: onTap != null ? Colors.white70 : Colors.white60,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  decoration: onTap != null ? TextDecoration.underline : null,
                  decorationColor: const Color(0xFFD4A017),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Link Item Widget
  Widget _buildLinkItem(String text, IconData icon) {
    return InkWell(
      onTap: () {
        Get.to(() => LegalAndSupportScreen());
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 16),
            const SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white24,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  /// Social Button Widget
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFD4A017), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
