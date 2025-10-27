import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalAndSupportScreen extends StatelessWidget {
  const LegalAndSupportScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Legal & Support',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Cards Section
            _buildContactSection(),
            const SizedBox(height: 32),

            // Terms of Service
            _buildSectionCard(
              icon: CupertinoIcons.doc_text_fill,
              title: "Terms of Service",
              content:
                  "Effective Date: October 25, 2025\n\n"
                  "Welcome to Pioneer Capital Limited — where your financial growth begins.\n\n"
                  "By creating an account or using our platform, you agree to our simple terms of service designed to protect both you and your investments.\n\n"
                  "At Pioneer Capital, we’re committed to transparency, security, and consistent growth. When you invest through our platform, you’re joining a trusted community of investors who believe in smart and sustainable wealth-building.\n\n"
                  "All our investment plans are structured with clear timelines and returns. While market conditions may vary, we always work to ensure stable performance and responsible management of funds.\n\n"
                  "We maintain the right to protect our users and the platform by addressing any fraudulent or suspicious activities swiftly — ensuring your safety and peace of mind.\n\n"
                  "By continuing to use Pioneer Capital, you acknowledge that you’ve read and understood these terms, and you’re ready to start your journey toward smarter investing.\n\n"
                  "Together, let’s build your financial future — securely, confidently, and transparently.",
            ),

            const SizedBox(height: 20),

            // Privacy Policy
            _buildSectionCard(
              icon: CupertinoIcons.lock_shield_fill,
              title: "Privacy Policy",
              content:
                  "Effective Date: October 25, 2025\n\n"
                  "Pioneer Capital Limited values your privacy. This policy explains how we collect, use, and protect your personal information.\n\n"
                  "We collect data such as personal details, wallet addresses, and device logs to improve security and enhance your experience.\n\n"
                  "We do not sell or rent user data. Your information is protected using advanced encryption and security protocols.\n\n"
                  "You may request access, correction, or deletion of your data at any time by contacting our support team.",
            ),
            const SizedBox(height: 32),

            // FAQs Section
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),

            _buildFaqItem(
              "What is Pioneer Capital Limited?",
              "Pioneer Capital Limited is an investment platform that helps users grow their wealth through structured, transparent investment packages.",
            ),
            _buildFaqItem(
              "How do I start investing?",
              "Simply sign up, verify your account, fund your wallet, and select a package that fits your goals.",
            ),
            _buildFaqItem(
              "How long does it take to process withdrawals?",
              "Withdrawals are typically processed within 24–48 hours depending on your package and network confirmations.",
            ),
            _buildFaqItem(
              "Is my investment safe?",
              "We use blockchain-backed systems and strong security measures. However, all investments carry some level of risk.",
            ),
            _buildFaqItem(
              "Can I upgrade my package?",
              "Yes, you can upgrade anytime by selecting a higher package and paying the difference.",
            ),
            _buildFaqItem(
              "Who can I contact for urgent issues?",
              "You can reach our 24/7 support team via email or live chat.",
            ),

            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.shield_fill,
                    color: const Color(0xFFD4A017),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "© 2025 Pioneer Capital Limited",
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "All rights reserved",
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.chat_bubble_2_fill,
                color: Color(0xFFD4A017),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Get in Touch',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Email Card
        _buildContactCard(
          icon: CupertinoIcons.mail_solid,
          title: 'Email Support',
          subtitle: 'support@pioneercapitalltd.com',
          onTap: () => _launchEmail('support@pioneercapitalltd.com'),
        ),
        const SizedBox(height: 12),

        // Phone Card
        _buildContactCard(
          icon: CupertinoIcons.phone_fill,
          title: 'Phone Support',
          subtitle: '+44 (7853) 752-212',
          onTap: () => _launchPhone('+447853752212'),
        ),
        const SizedBox(height: 12),

        // Website Card
        _buildContactCard(
          icon: CupertinoIcons.globe,
          title: 'Website',
          subtitle: 'www.pioneercapitalltd.com',
          onTap: () => _launchUrl('https://www.pioneercapitalltd.com'),
        ),
        const SizedBox(height: 12),

        // Address Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.location_solid,
                  color: Color(0xFFD4A017),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Office Location',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'London, United Kingdom, W1G 7AJ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white60,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Support Hours
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFD4A017).withOpacity(0.15),
                const Color(0xFFD4A017).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.clock_fill,
                color: Color(0xFFD4A017),
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Support Hours: Monday – Friday, 9:00 AM – 6:00 PM (EST)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFD4A017), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFFD4A017),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.arrow_right,
              color: Colors.white38,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFD4A017).withOpacity(0.2),
                      const Color(0xFFD4A017).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFD4A017), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              height: 1.8,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          collapsedIconColor: const Color(0xFFD4A017),
          iconColor: const Color(0xFFD4A017),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.question_circle_fill,
              color: Color(0xFFD4A017),
              size: 18,
            ),
          ),
          title: Text(
            question,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: -0.2,
            ),
          ),
          children: [
            Text(
              answer,
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
