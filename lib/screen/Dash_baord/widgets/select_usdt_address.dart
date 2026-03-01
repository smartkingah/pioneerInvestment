import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/Services/email_service.dart';
import 'package:investmentpro/providers/model_provider.dart';
import 'package:provider/provider.dart';

// STEP 1: Show Amount Input Dialog
void showAmountInputDialog(
  BuildContext context,
  String usdtWalletAddress,
  String btcWalletAddress, // Add BTC wallet
  Map<String, dynamic> selectedPackage,
  dynamic? data,
) {
  final TextEditingController amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4A017).withOpacity(0.2),
                        const Color(0xFFD4A017).withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Color(0xFFD4A017),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  "Enter Investment Amount",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Package Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        color: const Color(0xFFD4A017),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${selectedPackage['name']} Package",
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD4A017),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Range Display
                Text(
                  "Range: \$${selectedPackage['min']} - \$${selectedPackage['max']}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Amount Input Field
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Color(0xFFD4A017),
                    ),
                    hintText: "Enter amount",
                    hintStyle: GoogleFonts.inter(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF3A3A3C),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD4A017),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Please enter a valid number';
                    }
                    if (amount < selectedPackage['min']) {
                      return 'Minimum amount is \$${selectedPackage['min']}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Proceed Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final amount = double.parse(amountController.text);
                        Navigator.pop(context);

                        // Show payment method selection
                        showPaymentMethodDialog(
                          context,
                          usdtWalletAddress,
                          btcWalletAddress,
                          amount,
                          selectedPackage,
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: Text(
                      "Proceed to Payment",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

// STEP 1.5: Show Simplified Amount Input Dialog
void showSimpleAmountInputDialog(
  BuildContext context,
  String usdtWalletAddress,
  String btcWalletAddress,
  Map<String, dynamic> selectedPackage,
  dynamic? data,
) {
  final TextEditingController amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4A017).withOpacity(0.2),
                        const Color(0xFFD4A017).withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Color(0xFFD4A017),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  "Fund Wallet",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Amount Input Field
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Color(0xFFD4A017),
                    ),
                    hintText: "Enter amount",
                    hintStyle: GoogleFonts.inter(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF3A3A3C),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD4A017),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Please enter a valid number';
                    }
                    // if (amount < selectedPackage['min']) {
                    //   return 'Minimum amount is \$${selectedPackage['min']}';
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Proceed Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final amount = double.parse(amountController.text);
                        Navigator.pop(context);

                        // Show payment method selection
                        showPaymentMethodDialog(
                          context,
                          usdtWalletAddress,
                          btcWalletAddress,
                          amount,
                          selectedPackage,
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: Text(
                      "Proceed to Payment",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

// STEP 2: Show Payment Method Selection Dialog
void showPaymentMethodDialog(
  BuildContext context,
  String usdtWalletAddress,
  String btcWalletAddress,
  double amount,
  Map<String, dynamic> selectedPackage,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFD4A017),
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Select Payment Method",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                "Choose your preferred cryptocurrency",
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // USDT Option
              _PaymentMethodButton(
                icon: Icons.currency_bitcoin,
                title: "USDT (TRC20)",
                subtitle: "No additional charges",
                color: const Color(0xFF26A17B),
                onTap: () {
                  Navigator.pop(context);
                  showFundWalletDialog(
                    context,
                    usdtWalletAddress,
                    amount,
                    selectedPackage,
                    'USDT',
                    false,
                  );
                },
              ),
              const SizedBox(height: 12),

              // BTC Option
              _PaymentMethodButton(
                icon: Icons.currency_bitcoin_rounded,
                title: "Bitcoin (BTC)",
                subtitle: "Network fees apply",
                color: const Color(0xFFF7931A),
                showWarning: true,
                onTap: () {
                  Navigator.pop(context);
                  showBTCChargeWarningDialog(
                    context,
                    btcWalletAddress,
                    amount,
                    selectedPackage,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Payment Method Button Widget
class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool showWarning;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.showWarning = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3A3C), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
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
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (showWarning)
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade400,
                            size: 14,
                          ),
                        if (showWarning) const SizedBox(width: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            color: showWarning
                                ? Colors.orange.shade400
                                : Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// STEP 3: Show BTC Charge Warning Dialog
void showBTCChargeWarningDialog(
  BuildContext context,
  String btcWalletAddress,
  double amount,
  Map<String, dynamic> selectedPackage,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Bitcoin Network Fees",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Important Notice",
                            style: GoogleFonts.inter(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "When paying with Bitcoin, you are responsible for all network transaction fees (miner fees). These fees are separate from your investment amount and vary based on network congestion.",
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Important Points
              _InfoRow(
                icon: Icons.check_circle_outline,
                text: "You must cover the BTC network fees",
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.check_circle_outline,
                text: "Ensure sufficient balance for fees",
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.check_circle_outline,
                text: "Network fees are non-refundable",
              ),

              const SizedBox(height: 24),

              // Proceed Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A017),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  showFundWalletDialog(
                    context,
                    btcWalletAddress,
                    amount,
                    selectedPackage,
                    'BTC',
                    true,
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(
                  "I Understand, Continue",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Back Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Go Back",
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Info Row Widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4A017), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// STEP 4: Show Fund Wallet Dialog (updated with payment method)
void showFundWalletDialog(
  BuildContext context,
  String walletAddress,
  double amount,
  Map<String, dynamic> selectedPackage,
  String paymentMethod,
  bool hasNetworkFees,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFD4A017),
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Fund Your Wallet",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // Amount Display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4A017).withOpacity(0.2),
                      const Color(0xFFD4A017).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4A017).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Amount to Send",
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${amount.toStringAsFixed(2)} $paymentMethod",
                      style: GoogleFonts.inter(
                        color: const Color(0xFFD4A017),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${selectedPackage['name']} Package",
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    if (hasNetworkFees) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              color: Colors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Plus network fees",
                              style: GoogleFonts.inter(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                paymentMethod == 'USDT'
                    ? "Send USDT (TRC20) to the wallet address below."
                    : "Send Bitcoin (BTC) to the wallet address below.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // Wallet Address Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3C)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        walletAddress,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: Color(0xFFD4A017),
                        size: 20,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: walletAddress));

                        AuthService().showSuccessSnackBar(
                          context: context,
                          title: "Wallet address copied!",
                          subTitle: "successfully",
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Confirm Payment Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A017),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await _recordTransaction(
                    context,
                    amount,
                    selectedPackage['name'],
                    paymentMethod,
                  );

                  if (selectedPackage['name'] == "Bronze") {
                    sendEmail().sendMail(
                      message:
                          "Admin Notification:\n"
                          "A new payment has been made/sent successfully.\n"
                          "👤 User: ${getStorage.read('fullname')}\n"
                          "📧 Email: ${FirebaseAuth.instance.currentUser!.email}\n"
                          "💰 Amount: \$$amount\n"
                          "💳 Payment Method: $paymentMethod\n"
                          "🏦 Package: ${selectedPackage['name']}\n"
                          "💰 Price Range: \$${selectedPackage['min']} - \$${selectedPackage['max']}\n"
                          "🕒 Time: ${DateTime.now()}\n"
                          "${hasNetworkFees ? '⚠️ Note: BTC network fees apply\n' : ''}"
                          "Please verify in your admin dashboard and ensure proper record updates.",
                    );
                  } else {
                    sendEmail().sendMail(
                      message:
                          "Admin Notification:\n"
                          "A new payment has been made/sent successfully.\n"
                          "👤 User: ${getStorage.read('fullname')}\n"
                          "📧 Email: ${FirebaseAuth.instance.currentUser!.email}\n"
                          "💰 Amount: \$$amount\n"
                          "💳 Payment Method: $paymentMethod\n"
                          "💵 Kick Start Fee: \$${selectedPackage['kickStartFee']}\n"
                          "🏦 Package: ${selectedPackage['name']}\n"
                          "💰 Price Range: \$${selectedPackage['min']} - \$${selectedPackage['max']}\n"
                          "🕒 Time: ${DateTime.now()}\n"
                          "${hasNetworkFees ? '⚠️ Note: BTC network fees apply\n' : ''}"
                          "Please verify in your admin dashboard and ensure proper record updates.",
                    );
                  }

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  "I've Sent the Payment",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Contact Support for Help!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.amber,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// STEP 5: Record Transaction to Firestore (updated)
Future<void> _recordTransaction(
  BuildContext context,
  double amount,
  String packageName,
  String paymentMethod,
) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add({
          'type': 'Deposit',
          'amount': amount,
          'packageName': packageName,
          'status': 'Pending',
          'timestamp': FieldValue.serverTimestamp(),
          'paymentMethod': paymentMethod == 'USDT'
              ? 'USDT (TRC20)'
              : 'Bitcoin (BTC)',
        });

    ///once am funding my wallet only i dont ant to lock my activation
    var justFundedWallet = Provider.of<ModelProvider>(
      context,
      listen: false,
    ).isJustFundWallet;
    justFundedWallet == true
        ? null
        : await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'lockedActivation': true,
          });

    AuthService().showSuccessSnackBar(
      context: context,
      title: 'Payment confirmation recorded!',
      subTitle: 'Awaiting admin approval.',
    );
  } catch (e) {
    AuthService().showErrorSnackBar(
      context: context,
      title: "Error recording transaction:",
      subTitle: e.toString(),
    );
  }
}
