import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget congratulationsCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFD4A017).withOpacity(0.3),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFD4A017).withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF0ECB81).withOpacity(0.1),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        // Trophy/Star Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD4A017), Color(0xFFB8860B)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A017).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            color: Colors.black87,
            size: 40,
          ),
        ),

        const SizedBox(height: 20),

        // Congratulations Header
        Text(
          "🎉 Congratulations! 🎉",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD4A017),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // Premium Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD4A017).withOpacity(0.3),
                const Color(0xFF0ECB81).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4A017).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFD4A017),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "PREMIUM MEMBER",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD4A017),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Achievement Message
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              height: 1.6,
              letterSpacing: 0.3,
            ),
            children: [
              const TextSpan(text: "You've successfully reached the "),
              TextSpan(
                text: "Californium Max Package",
                style: GoogleFonts.inter(
                  color: const Color(0xFFD4A017),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const TextSpan(
                text: "! You're now part of our elite premium community.",
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Benefits Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildBenefit(
                Icons.account_balance_wallet_rounded,
                "Withdraw your funds",
                "anytime",
                const Color(0xFF0ECB81),
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.trending_up_rounded,
                "Maximum earning",
                "potential unlocked",
                const Color(0xFFD4A017),
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.verified_user_rounded,
                "Premium support &",
                "exclusive benefits",
                const Color(0xFF0ECB81),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action Message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0ECB81).withOpacity(0.2),
                const Color(0xFF0ECB81).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0ECB81).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF0ECB81),
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "You can now proceed to withdraw your funds",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0ECB81),
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildBenefit(IconData icon, String text1, String text2, Color color) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            children: [
              TextSpan(text: text1),
              const TextSpan(text: " "),
              TextSpan(
                text: text2,
                style: GoogleFonts.inter(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
