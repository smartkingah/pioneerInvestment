import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmbassadorPage extends StatelessWidget {
  const AmbassadorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: const Color(0xFFFdea407),
        // constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: isMobile
            ? Column(
                children: [
                  _buildLeftSection(),
                  const SizedBox(height: 40),
                  _buildRightForm(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildLeftSection()),
                  const SizedBox(width: 60),
                  Expanded(flex: 2, child: _buildRightForm()),
                ],
              ),
      ),
    );
  }

  // --- LEFT SIDE ---
  Widget _buildLeftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Ambassadorship\nProgram.\nEarn While You Refer.",
          style: GoogleFonts.playfairDisplay(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Join our exclusive Ambassadorship Program and earn substantial commissions by referring new investors to our platform. "
          "The more you refer, the higher your earning percentage becomes.\n\n"
          "Build your passive income stream while helping others discover profitable investment opportunities. "
          "It's a win-win for everyone involved.",
          style: TextStyle(fontSize: 16, color: Colors.white, height: 1.7),
        ),
        const SizedBox(height: 30),

        // --- Commission Cards ---
        _buildCommissionCard("1", "Refer 1 Person", "5% Commission"),
        const SizedBox(height: 16),
        _buildCommissionCard("10+", "Refer 10+ People", "10% Commission"),

        const SizedBox(height: 30),

        // --- Footer Icons ---
        Wrap(
          spacing: 20,
          children: const [
            _IconText(label: "Lifetime Earnings"),
            _IconText(label: "Real-time Tracking"),
            _IconText(label: "Instant Payouts"),
          ],
        ),
      ],
    );
  }

  Widget _buildCommissionCard(String number, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFFD4A017),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- RIGHT SIDE ---
  Widget _buildRightForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Join as Ambassador",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // --- Form Fields ---
          _buildTextField("Full Name", "Enter your full name"),
          _buildTextField("Email Address", "Enter your email"),
          _buildTextField("Phone Number", "Enter your phone number"),
          _buildTextField(
            "Referral Code (Optional)",
            "Enter referral code if you have one",
          ),

          const SizedBox(height: 12),
          const Text(
            "Interested In",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: "Select your interest",
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(value: "Investment", child: Text("Investment")),
              DropdownMenuItem(
                value: "Partnership",
                child: Text("Partnership"),
              ),
              DropdownMenuItem(value: "Marketing", child: Text("Marketing")),
            ],
            onChanged: (value) {},
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Become an Ambassador",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "By submitting this form, you agree to our Terms of Service and Privacy Policy.",
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ICON + TEXT Component ---
class _IconText extends StatelessWidget {
  final String label;
  const _IconText({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
