import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvestmentHighlightsPage extends StatelessWidget {
  const InvestmentHighlightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 70),
        color: Color(0xFF030305),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // HEADER
            RichText(
              text: TextSpan(
                text: 'Performance ',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: 'Highlights',
                    style: GoogleFonts.playfairDisplay(
                      color: Color(0xFFFFC107),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Our track record speaks for itself. Join thousands of satisfied investors worldwide.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // STATS GRID
            Wrap(
              spacing: 40,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: const [
                StatCard(value: '8,416+', label: 'Active Investors'),
                StatCard(value: '\$16M+', label: 'Assets Under Management'),
                StatCard(value: '98%', label: 'Payout Success Rate'),
                StatCard(value: '100%', label: 'Verified Operations'),
              ],
            ),
            const SizedBox(height: 70),

            // TESTIMONIALS GRID
            Wrap(
              spacing: 40,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: const [
                TestimonialCard(
                  quote:
                      'Reliable, transparent, and fast — my best investment experience.',
                  name: 'Sarah Johnson',
                  role: 'Portfolio Manager',
                ),
                TestimonialCard(
                  quote: 'Professional team with consistent weekly payouts.',
                  name: 'Michael Chen',
                  role: 'Investment Advisor',
                ),
                TestimonialCard(
                  quote:
                      'The transparency and real-time tracking gives me complete confidence.',
                  name: 'David Rodriguez',
                  role: 'Private Investor',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// STAT CARD
class StatCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF262a33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

// TESTIMONIAL CARD
class TestimonialCard extends StatelessWidget {
  final String quote;
  final String name;
  final String role;

  const TestimonialCard({
    super.key,
    required this.quote,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF262a33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: Color(0xFFFFC107), size: 28),
          const SizedBox(height: 6),
          Text(
            '"$quote"',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.4,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            role,
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
