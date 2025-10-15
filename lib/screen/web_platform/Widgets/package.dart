import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvestmentPackagesPage extends StatelessWidget {
  const InvestmentPackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1000;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
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
                'Investment ',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Packages',
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
            'Choose the investment plan that aligns with your financial goals and risk tolerance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: const Color(0xFF4A4A4A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 50),

          // 🧩 Grid of packages (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (isTablet) crossAxisCount = 2;
              if (isMobile) crossAxisCount = 1;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 30,
                crossAxisSpacing: 30,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isMobile ? 1.2 : 1,
                children: [
                  _buildPackageCard(
                    title: 'Bronze',
                    amount: '\$50 – \$499',
                    returnRate: '5% every 24 hrs',
                    description: 'Ideal for beginners seeking daily growth.',
                    icon: '🥉',
                    iconColor: const Color(0xFFC97F22),
                    borderColor: const Color(0xFFFF8C00),
                    isPopular: false,
                  ),
                  _buildPackageCard(
                    title: 'Silver',
                    amount: '\$1,000 – \$4,999',
                    returnRate: '20% every 48 hrs',
                    description: 'Great for short-term turnover and liquidity.',
                    icon: '🥈',
                    iconColor: const Color(0xFFA9A9A9),
                    borderColor: const Color(0xFF696969),
                    isPopular: false,
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
                  ),
                  _buildPackageCard(
                    title: 'Californian',
                    amount: '\$100,000 – \$500,000',
                    returnRate: '50% every 30 days',
                    description: 'Long-term, high-value returns.',
                    icon: '🌴',
                    iconColor: const Color(0xFF228B22),
                    borderColor: const Color(0xFF32CD32),
                    isPopular: false,
                  ),
                  _buildPackageCard(
                    title: 'Executive',
                    amount: '\$500,000 – \$1,000,000',
                    returnRate: '60% profit',
                    description: 'For elite or institutional investors.',
                    icon: "👑",
                    iconColor: const Color(0xFFFFD700),
                    borderColor: const Color(0xFF9932CC),
                    isPopular: false,
                    isElite: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔹 Package Card Widget
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
  }) {
    return GestureDetector(
      onTap: () => debugPrint('Selected: $title'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 35)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A017),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  returnRate,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => debugPrint('Selected: $title'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular
                        ? const Color(0xFFD4A017)
                        : Colors.white,
                    foregroundColor: isPopular ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    minimumSize: const Size(200, 40),
                  ),
                  child: const Text(
                    'Select Plan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),

            // Badges
            if (isPopular)
              Positioned(
                top: -10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
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
                top: -10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9932CC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Elite',
                    style: TextStyle(
                      fontSize: 13,
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
