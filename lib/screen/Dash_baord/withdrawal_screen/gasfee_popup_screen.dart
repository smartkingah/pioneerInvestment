import 'package:flutter/material.dart';

class GasFeeInfo extends StatelessWidget {
  final double depositAmount;
  final VoidCallback onDepositClicked;
  final VoidCallback onLearnMoreClicked;

  const GasFeeInfo({
    Key? key,
    required this.depositAmount,
    required this.onDepositClicked,
    required this.onLearnMoreClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF212429), // Darkish background
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with info icon + heading
          Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Insufficient ETH to cover network and Gas fee.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Explanation about deposit
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, height: 1.4),
              children: [
                const TextSpan(text: 'You need to deposit '),
                TextSpan(
                  text: '${depositAmount.toStringAsFixed(2)} ETH',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: ' into your Crypto ETH wallet to proceed ',
                ),
                // Clickable deposit
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: onDepositClicked,
                    child: Text(
                      'Click here to proceed ${'' /* or depositAmount */}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Second paragraph
          const Text(
            'These are blockchain transaction fees. Crypto does not charge any fee. 0% of these fees are paid to Crypto.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),

          const SizedBox(height: 16),

          // Learn more link
          GestureDetector(
            onTap: onLearnMoreClicked,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.white70, height: 1.4),
                children: [
                  TextSpan(text: 'Click to read more: '),
                  TextSpan(
                    text:
                        'what is ETH gas fee and why is it needed for this transaction',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontStyle: FontStyle.italic,
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
