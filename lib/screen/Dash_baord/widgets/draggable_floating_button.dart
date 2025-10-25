import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpFloatingButton extends StatefulWidget {
  const HelpFloatingButton({super.key});

  @override
  State<HelpFloatingButton> createState() => _HelpFloatingButtonState();
}

class _HelpFloatingButtonState extends State<HelpFloatingButton> {
  double posX = 20;
  double posY = 520;

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // header icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Color(0xFFD4A017),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "How to Use the Platform",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    "1. Fund your wallet",
                    "Deposit USDT into your account to get started.",
                  ),
                  _buildStep(
                    "2. Select an investment package",
                    "Choose a plan that fits your budget and goals.",
                  ),
                  _buildStep(
                    "3. Activate your investment",
                    "Once activated, returns will start based on the plan duration. Always come back to reactivate when your plan expires.",
                  ),
                  _buildStep(
                    "4. Need help?",
                    "Our 24/7 customer care team is always ready to assist you.",
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Got it!",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFFD4A017),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // set initial position to center-left
    posX = posX == 20 ? 0 : posX; // keep x fixed near left
    posY = (posY == 520) ? (screenHeight / 2) - 28 : posY; // center vertically
    return Stack(
      children: [
        Positioned(
          left: posX,
          top: posY,
          child: Draggable(
            feedback: _buildButton(),
            childWhenDragging: const SizedBox(),
            onDragEnd: (details) {
              setState(() {
                posX = details.offset.dx.clamp(10, screenWidth - 70);
                posY = details.offset.dy.clamp(80, screenHeight - 120);
              });
            },
            child: _buildButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return GestureDetector(
      onTap: () => _showHelpDialog(context),
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFFD4A017),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A017).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.help_outline_rounded,
          color: Colors.black,
          size: 22,
        ),
      ),
    );
  }
}
