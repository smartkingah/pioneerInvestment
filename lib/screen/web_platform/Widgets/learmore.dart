import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/screen/Auth/auth_screen.dart';
import 'package:investmentpro/screen/authentication/signup.dart';

/// Pioneer Capital Ltd - Modern "Learn More" page
/// Light theme with gold accents, green/red touches, and professional imagery
class PioneerLearnMorePage extends StatelessWidget {
  const PioneerLearnMorePage({Key? key}) : super(key: key);

  // Modern light color palette
  static const Color _lightBg = Color(0xFFFAFAFA);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _gold = Color(0xFFD4A017);
  static const Color _green = Color(0xFF0ECB81);
  static const Color _red = Color(0xFFE74C3C);
  static const Color _textPrimary = Color(0xFF0A0A0A);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: CustomScrollView(
        slivers: [
          // Modern app bar
          SliverAppBar(
            backgroundColor: _cardBg,
            elevation: 1,
            pinned: true,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: _cardBg),
              title: _buildLogoTitle(),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isWide = screenWidth >= 900;
                final isMobile = screenWidth < 600;

                double headingSize = screenWidth < 600 ? 32.0 : 48.0;
                double bodySize = screenWidth < 600 ? 15.0 : 17.0;

                return Column(
                  children: [
                    // Hero section with image
                    _buildHeroSection(
                      screenWidth,
                      headingSize,
                      bodySize,
                      isWide,
                    ),

                    // Trust metrics
                    _buildTrustMetrics(screenWidth, bodySize),

                    // Full image gallery section (7+ images)
                    _buildImageGallery(screenWidth, isMobile),

                    // Main content
                    _buildMainContent(screenWidth, bodySize, isWide),

                    // Investment packages preview
                    _buildPackagesPreview(screenWidth, bodySize, isMobile),

                    // // Team/Office section with 2 more images
                    // _buildTeamSection(screenWidth, bodySize, isMobile),

                    // Final image showcase
                    _buildFinalShowcase(screenWidth, isMobile),

                    // CTA
                    _buildCTA(screenWidth, bodySize),

                    // Footer
                    _buildFooter(bodySize),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl:
                    'https://res.cloudinary.com/dy523yrlh/image/upload/v1761692169/PCL_LOGO_tjuaw6.png',
                // width: double.infinity,
                // height: double.infinity,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Pioneer Capital',
          style: GoogleFonts.spaceGrotesk(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(
    double screenWidth,
    double headingSize,
    double bodySize,
    bool isWide,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 20 : 60,
        vertical: 40,
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: _heroText(headingSize, bodySize)),
                const SizedBox(width: 60),
                Expanded(
                  child: _heroImage(
                    "https://res.cloudinary.com/dy523yrlh/image/upload/v1761687846/WhatsApp_Image_2025-10-28_at_10.08.39_PM_1_zkqhe0.jpg",
                  ),
                ), // IMAGE 1
              ],
            )
          : Column(
              children: [
                _heroText(headingSize, bodySize),
                const SizedBox(height: 40),
                _heroImage(
                  'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687846/WhatsApp_Image_2025-10-28_at_10.08.39_PM_1_zkqhe0.jpg',
                ), // IMAGE 1
              ],
            ),
    );
  }

  Widget _heroText(double headingSize, double bodySize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gradient accent bar
        Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_green, _gold]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),

        RichText(
          text: TextSpan(
            style: GoogleFonts.spaceGrotesk(
              fontSize: headingSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1,
            ),
            children: [
              TextSpan(
                text: 'Grow Your ',
                style: TextStyle(color: _textPrimary),
              ),
              TextSpan(
                text: 'Wealth\n',
                style: TextStyle(color: _gold),
              ),
              TextSpan(
                text: 'With ',
                style: TextStyle(color: _textPrimary),
              ),
              TextSpan(
                text: 'Confidence',
                style: TextStyle(color: _green),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Pioneer Capital Ltd offers carefully structured investment packages designed to deliver steady, transparent, and secure growth for individuals and businesses.',
          style: GoogleFonts.inter(
            fontSize: bodySize,
            color: _textSecondary,
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 32),

        OutlinedButton(
          onPressed: () {
            Get.to(() => const SignupPage());
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _textSecondary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Create Account',
            style: GoogleFonts.inter(
              color: _textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroImage(String image) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // PLACEHOLDER: Replace with your image
            Container(
              color: Colors.grey[200],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: image,
                  // width: double.infinity,
                  // height: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustMetrics(double screenWidth, double bodySize) {
    final isNarrow = screenWidth < 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 20 : 60,
        vertical: 40,
      ),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isNarrow
          ? Column(
              children: [
                // 8416+ active investors

                // $16m assets under management

                // 98% payout success rate

                // 100% verified operations
                _metricCard('98%', 'Success Rate', _green, bodySize),
                const SizedBox(height: 24),
                _metricCard('\$16M+', 'Assets Managed', _gold, bodySize),
                const SizedBox(height: 24),
                _metricCard(
                  '8416+',
                  'Active Investors',
                  _textPrimary,
                  bodySize,
                ),
                _metricCard(
                  '100%',
                  'Verified Operations',
                  _textPrimary,
                  bodySize,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricCard('98%', 'Success Rate', _green, bodySize),
                _divider(),
                _metricCard('\$16M+', 'Assets Managed', _gold, bodySize),
                _divider(),
                _metricCard(
                  '8416+',
                  'Active Investors',
                  _textPrimary,
                  bodySize,
                ),
                _divider(),
                _metricCard(
                  '100%',
                  'Verified Operations',
                  _textPrimary,
                  bodySize,
                ),
              ],
            ),
    );
  }

  Widget _metricCard(String value, String label, Color color, double bodySize) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: bodySize,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 60,
      color: _textSecondary.withOpacity(0.2),
    );
  }

  Widget _buildImageGallery(double screenWidth, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 20 : 60,
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Workspace & Team',
            style: GoogleFonts.spaceGrotesk(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Take a look inside Pioneer Capital and meet the people behind your investments',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 15 : 17,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Images 2 & 3 - Large featured images
          isMobile
              ? Column(
                  children: [
                    _imageCard(
                      height: 250,
                      imageNumber: 2,
                      image:
                          'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687847/WhatsApp_Image_2025-10-28_at_10.08.39_PM_ekat5d.jpg',
                    ),
                    const SizedBox(height: 16),
                    _imageCard(
                      height: 250,
                      imageNumber: 3,
                      image:
                          'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687847/WhatsApp_Image_2025-10-28_at_10.08.38_PM_2_njlsgm.jpg',
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _imageCard(
                        height: 350,
                        imageNumber: 2,
                        image:
                            'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687847/WhatsApp_Image_2025-10-28_at_10.08.39_PM_ekat5d.jpg',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _imageCard(
                        height: 350,
                        imageNumber: 3,
                        image:
                            'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687847/WhatsApp_Image_2025-10-28_at_10.08.38_PM_2_njlsgm.jpg',
                      ),
                    ),
                  ],
                ),

          const SizedBox(height: 16),

          // // Images 4, 5, 6 - Three column grid
          // isMobile
          //     ? Column(
          //         children: [
          //           _imageCard(
          //             height: 200,
          //             imageNumber: 4,
          //             label: 'Meeting Room',
          //           ),
          //           const SizedBox(height: 16),
          //           _imageCard(
          //             height: 200,
          //             imageNumber: 5,
          //             label: 'Work Environment',
          //           ),
          //           const SizedBox(height: 16),
          //           _imageCard(
          //             height: 200,
          //             imageNumber: 6,
          //             label: 'Client Services',
          //           ),
          //         ],
          //       )
          //     : Row(
          //         children: [
          //           Expanded(
          //             child: _imageCard(
          //               height: 280,
          //               imageNumber: 4,
          //               label: 'Meeting Room',
          //             ),
          //           ),
          //           const SizedBox(width: 16),
          //           Expanded(
          //             child: _imageCard(
          //               height: 280,
          //               imageNumber: 5,
          //               label: 'Work Environment',
          //             ),
          //           ),
          //           const SizedBox(width: 16),
          //           Expanded(
          //             child: _imageCard(
          //               height: 280,
          //               imageNumber: 6,
          //               label: 'Client Services',
          //             ),
          //           ),
          //         ],
          //       ),
        ],
      ),
    );
  }

  Widget _imageCard({
    required double height,
    required int imageNumber,
    required String image,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.grey[100],
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: image,
                    // width: double.infinity,
                    // height: double.infinity,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(double screenWidth, double bodySize, bool isWide) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 20 : 60,
        vertical: 40,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _contentColumn(bodySize)),
                const SizedBox(width: 40),
                Expanded(flex: 1, child: _sidebar(bodySize)),
              ],
            )
          : Column(
              children: [
                _contentColumn(bodySize),
                const SizedBox(height: 32),
                _sidebar(bodySize),
              ],
            ),
    );
  }

  Widget _contentColumn(double bodySize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Investment Approach',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'We prioritise long-term, sustainable growth over speculative, short-term gains. Each package is built on a foundation of market analysis, risk management, and diversification to protect capital while pursuing steady returns.',
          style: GoogleFonts.inter(
            fontSize: bodySize,
            color: _textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),

        _featureCard(
          icon: Icons.shield_outlined,
          title: 'Low-Risk Plans',
          description: 'Stable returns with capital preservation strategies.',
          color: _green,
          bodySize: bodySize,
        ),
        const SizedBox(height: 16),
        _featureCard(
          icon: Icons.trending_up,
          title: 'Mid-Risk Packages',
          description:
              'Balanced portfolios that aim for higher yields with controlled risk.',
          color: _gold,
          bodySize: bodySize,
        ),
        const SizedBox(height: 16),
        _featureCard(
          icon: Icons.rocket_launch_outlined,
          title: 'High-Yield Options',
          description:
              'Curated opportunities for investors seeking stronger growth.',
          color: _red,
          bodySize: bodySize,
        ),
      ],
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required double bodySize,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: bodySize + 2,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: bodySize,
                    color: _textSecondary,
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

  Widget _sidebar(double bodySize) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Choose Us',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _checkItem('Clear fee structure', bodySize),
          const SizedBox(height: 12),
          _checkItem('Regular performance updates', bodySize),
          const SizedBox(height: 12),
          _checkItem('Dedicated account managers', bodySize),
          const SizedBox(height: 12),
          _checkItem('24/7 customer support', bodySize),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _green.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone, color: _green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Contact Us',
                      style: GoogleFonts.inter(
                        fontSize: bodySize,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'support@pioneercapitalltd.com',
                  style: GoogleFonts.inter(
                    fontSize: bodySize - 1,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '+44 7853 752 212',
                  style: GoogleFonts.inter(
                    fontSize: bodySize - 1,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkItem(String text, double bodySize) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: _gold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: bodySize, color: _textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildPackagesPreview(
    double screenWidth,
    double bodySize,
    bool isMobile,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 20 : 60,
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investment Packages',
            style: GoogleFonts.spaceGrotesk(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          isMobile
              ? Column(
                  children: [
                    _packageCard(
                      'Bronze',
                      '\$50 – \$499',
                      '10% every 24 hrs',
                      Colors.brown,
                      bodySize,
                    ),
                    _packageCard(
                      'Silver',
                      '\$1,000 – \$4,999',
                      '20% every 48 hrs',
                      Colors.grey,
                      bodySize,
                    ),
                    _packageCard(
                      'Gold',
                      '\$5,000 – \$19,999',
                      '25% every 4 days',
                      const Color(0xFFD4A017), // Gold color
                      bodySize,
                    ),
                    _packageCard(
                      'Platinum',
                      '\$20,000 – \$99,999',
                      '30% every 7 days',
                      Colors.blueGrey,
                      bodySize,
                    ),
                    _packageCard(
                      'Californium',
                      '\$100,000 – \$499,999',
                      '50% every 10 days',
                      Colors.teal,
                      bodySize,
                    ),
                    _packageCard(
                      'Executive',
                      '\$500,000 – \$1,000,000',
                      '70% every 60 days',
                      Colors.purple,
                      bodySize,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _packageCard(
                          'Bronze',
                          '\$50  – \$499   ',
                          '10% every 24 hrs',
                          Colors.brown,
                          bodySize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _packageCard(
                          'Silver',
                          '\$1,000 – \$4,999',
                          '20% every 48 hrs',
                          Colors.grey,
                          bodySize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _packageCard(
                          'Gold',
                          '\$5,000 – \$19,999',
                          '25% every 4 days',
                          const Color(0xFFD4A017), // Gold color
                          bodySize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _packageCard(
                          'Platinum',
                          '\$20,000 – \$99,999',
                          '30% every 7 days',
                          Colors.blueGrey,
                          bodySize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _packageCard(
                          'Californium',
                          '\$100,000 – \$499,999',
                          '50% every 10 days',
                          Colors.teal,
                          bodySize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _packageCard(
                          'Executive',
                          '\$500,000 – \$1,000,000',
                          '70% every 60 days',
                          Colors.purple,
                          bodySize,
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _packageCard(
    String title,
    String minInvest,
    String returns,
    Color accentColor,
    double bodySize,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: bodySize - 1,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            minInvest,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum Investment',
            style: GoogleFonts.inter(
              fontSize: bodySize - 1,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.trending_up, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '$returns',
                style: GoogleFonts.inter(
                  fontSize: bodySize,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(double screenWidth, double bodySize, bool isMobile) {
    return !isMobile
        ? SizedBox()
        : Container(
            margin: EdgeInsets.symmetric(
              horizontal: screenWidth < 600 ? 20 : 60,
              vertical: 40,
            ),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _gold.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Meet Our Team',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dedicated professionals committed to your financial success',
                  style: GoogleFonts.inter(
                    fontSize: bodySize,
                    color: _textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Image 7 - Large team photo
                _heroImage(
                  'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687817/WhatsApp_Image_2025-10-28_at_10.08.40_PM_fhul3a.jpg',
                ),
              ],
            ),
          );
  }

  Widget _buildFinalShowcase(double screenWidth, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 20 : 60,
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Commitment to Excellence',
            style: GoogleFonts.spaceGrotesk(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 32),

          // Images 8 & 9 - Final showcase
          isMobile
              ? Column(
                  children: [
                    _imageCard(
                      height: 250,
                      imageNumber: 8,
                      image:
                          'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687817/WhatsApp_Image_2025-10-28_at_10.08.40_PM_fhul3a.jpg',
                    ),
                    const SizedBox(height: 16),
                    _imageCard(
                      height: 250,
                      imageNumber: 9,
                      image:
                          'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687848/WhatsApp_Image_2025-10-28_at_10.08.37_PM_1_qzcytl.jpg',
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _imageCard(
                        height: 350,
                        imageNumber: 8,
                        image:
                            'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687817/WhatsApp_Image_2025-10-28_at_10.08.40_PM_fhul3a.jpg',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _imageCard(
                        height: 350,
                        imageNumber: 9,
                        image:
                            'https://res.cloudinary.com/dy523yrlh/image/upload/v1761687848/WhatsApp_Image_2025-10-28_at_10.08.37_PM_1_qzcytl.jpg',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildCTA(double screenWidth, double bodySize) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 20 : 60,
        vertical: 40,
      ),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_gold.withOpacity(0.1), _green.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Start Your Investment Journey?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: screenWidth < 600 ? 24 : 32,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Open an account in minutes and begin growing your wealth with Pioneer Capital Ltd.',
            style: GoogleFonts.inter(fontSize: bodySize, color: _textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Get.to(() => const SignupPage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 600 ? 32 : 48,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Account Now',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: bodySize,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double bodySize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _textSecondary.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Terms',
                style: GoogleFonts.inter(
                  color: _textSecondary,
                  fontSize: bodySize - 2,
                ),
              ),
              const SizedBox(width: 20),
              Text('•', style: TextStyle(color: _textSecondary)),
              const SizedBox(width: 20),
              Text(
                'Privacy',
                style: GoogleFonts.inter(
                  color: _textSecondary,
                  fontSize: bodySize - 2,
                ),
              ),
              const SizedBox(width: 20),
              Text('•', style: TextStyle(color: _textSecondary)),
              const SizedBox(width: 20),
              Text(
                'Contact',
                style: GoogleFonts.inter(
                  color: _textSecondary,
                  fontSize: bodySize - 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} Pioneer Capital Ltd. All rights reserved.',
            style: GoogleFonts.inter(
              color: _textSecondary.withOpacity(0.8),
              fontSize: bodySize - 2,
            ),
          ),
        ],
      ),
    );
  }
}
