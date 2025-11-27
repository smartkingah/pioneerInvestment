import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/screen/authentication/signup.dart';

class InvestmentPackagesPage extends StatelessWidget {
  const InvestmentPackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 900;
    final bool isSmallPhone = screenWidth < 380;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 40,
          vertical: isMobile ? 28 : 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'Investment ',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isMobile ? 30 : 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Packages',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isMobile ? 30 : 48,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4A017),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Choose the investment plan that aligns with your financial goals and risk tolerance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 18,
                color: const Color(0xFF4A4A4A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),

            // Responsive Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                int crossAxisCount = 3;
                if (isTablet) crossAxisCount = 2;
                if (isMobile) crossAxisCount = 1;

                final spacing = 30.0;
                final cardWidth =
                    (availableWidth - spacing * (crossAxisCount - 1)) /
                    crossAxisCount;

                // Decide desired card height depending on device type:
                final desiredCardHeight = isMobile ? 320.0 : 360.0;

                // childAspectRatio = width / height
                final childAspectRatio = cardWidth / desiredCardHeight;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: childAspectRatio.clamp(0.6, 2.0),
                  children: [
                    _buildPackageCard(
                      title: 'Bronze',
                      amount: '\$50 – \$499',
                      returnRate: '10% every 24 hrs',
                      description: 'Ideal for beginners seeking daily growth.',
                      icon: '🥉',
                      iconColor: const Color(0xFFC97F22),
                      borderColor: const Color(0xFFFF8C00),
                      isPopular: false,
                      isSmallPhone: isSmallPhone,
                    ),
                    _buildPackageCard(
                      title: 'Silver',
                      amount: '\$1,000 – \$4,999',
                      returnRate: '20% every 48 hrs',
                      description:
                          'Great for short-term turnover and liquidity.',
                      icon: '🥈',
                      iconColor: const Color(0xFFA9A9A9),
                      borderColor: const Color(0xFF696969),
                      isPopular: false,
                      isSmallPhone: isSmallPhone,
                    ),
                    _buildPackageCard(
                      title: 'Gold',
                      amount: '\$5,000 – \$19,999',
                      returnRate: '25% every 4 days',
                      description: 'Mid-level investors scaling profits.',
                      icon: "🥇",
                      iconColor: const Color(0xFFFFD700),
                      borderColor: const Color(0xFFD4A017),
                      isPopular: true,
                      isSmallPhone: isSmallPhone,
                    ),
                    _buildPackageCard(
                      title: 'Platinum',
                      amount: '\$20,000 – \$99,999',
                      returnRate: '30% every 7 days',
                      description: 'Professionals seeking weekly gains.',
                      icon: "💎",
                      iconColor: const Color(0xFF00BFFF),
                      borderColor: const Color(0xFF1E90FF),
                      isPopular: false,
                      isSmallPhone: isSmallPhone,
                    ),
                    _buildPackageCard(
                      title: 'Californium',
                      amount: '\$100,000 – \$500,000',
                      returnRate: '50% every 10 days',
                      description: 'Long-term, high-value returns.',
                      icon: '🌴',
                      iconColor: const Color(0xFF228B22),
                      borderColor: const Color(0xFF32CD32),
                      isPopular: false,
                      isSmallPhone: isSmallPhone,
                    ),
                    _buildPackageCard(
                      title: 'Executive',
                      amount: '\$500,000 – \$1,000,000',
                      returnRate: '70% every 14 days',
                      description: 'For elite or institutional investors.',
                      icon: "👑",
                      iconColor: const Color(0xFFFFD700),
                      borderColor: const Color(0xFF9932CC),
                      isPopular: false,
                      isElite: true,
                      isSmallPhone: isSmallPhone,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Package Card
  Widget _buildPackageCard({
    required String title,
    required String amount,
    required String returnRate,
    required String description,
    required String icon,
    required Color iconColor,
    required Color borderColor,
    required bool isPopular,
    bool isElite = false,
    bool isSmallPhone = false,
  }) {
    return GestureDetector(
      onTap: () => debugPrint('Selected: $title'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min, // important
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 34)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A017),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  returnRate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                // Adaptive button (no aggressive minimumSize)
                SizedBox(
                  width: isSmallPhone ? 140 : 180,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => SignupPage());
                      debugPrint('Selected: $title');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular
                          ? const Color(0xFFD4A017)
                          : isElite
                          ? const Color(0xFF9932CC)
                          : Colors.grey[300],
                      foregroundColor: isPopular ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallPhone ? 12 : 18,
                        vertical: isSmallPhone ? 10 : 12,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Select Plan',
                      style: TextStyle(
                        fontSize: isSmallPhone ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color:
                            //  isPopular ||
                            isElite ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Badges
            if (isPopular)
              Positioned(
                top: -12,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            if (isElite)
              Positioned(
                top: -12,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9932CC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Elite',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
