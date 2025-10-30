import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget proTip() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
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
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4A017), Color(0xFFB8860B)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tips_and_updates_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Investment Tips",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0ECB81).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF0ECB81).withOpacity(0.3),
                ),
              ),
              child: Text(
                "PRO",
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0ECB81),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Tip 1
        _buildCompactTip(
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFFD4A017),
          text:
              "Fund your wallet after withdrawal to maintain continuous growth",
        ),

        const SizedBox(height: 10),

        // Tip 2
        _buildCompactTip(
          icon: Icons.swap_horiz_rounded,
          color: const Color(0xFF0ECB81),
          text: "Reactivate investments or withdraw earnings anytime",
        ),
      ],
    ),
  );
}

Widget _buildCompactTip({
  required IconData icon,
  required Color color,
  required String text,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.1,
          ),
        ),
      ),
    ],
  );
}
