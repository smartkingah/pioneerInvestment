import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:js' as js;

class CustomerCareSection extends StatelessWidget {
  const CustomerCareSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Positioned(
      bottom: isMobile ? 20 : 40,
      right: isMobile ? 20 : 50,
      child: GestureDetector(
        onTap: kIsWeb ? _openTawkToChat : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: isMobile ? 10 : 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.support_agent,
                color: Colors.amber,
                size: isMobile ? 22 : 26,
              ),
              const SizedBox(width: 10),
              Text(
                'Chat with Us',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ Updated Tawk.to opener for Flutter Web

void _openTawkToChat() {
  final ready =
      js.context.hasProperty('tawkToReady') &&
      js.context['tawkToReady'] == true;

  if (ready && js.context.hasProperty('Tawk_API')) {
    js.context.callMethod('Tawk_API.toggle');
  } else {
    print("⚠️ Tawk.to widget not yet loaded. Retrying in 2 seconds...");
    Future.delayed(const Duration(seconds: 2), _openTawkToChat);
  }
}
