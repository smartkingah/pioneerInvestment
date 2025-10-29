import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/Services/email_service.dart';

// STEP 1: Show Amount Input Dialog
void showAmountInputDialog(
  BuildContext context,
  String usdtWalletAddress,
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
                        (data!['activePackage'] == "Bronze" &&
                                data['numberOfRounds'] >= 6)
                            ? "${selectedPackage['name']} Package"
                            : data!['activePackage'] == "Bronze"
                            ? "Bronze Package"
                            : "${selectedPackage['name']} Package",
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
                  (data!['activePackage'] == "Bronze" &&
                          data['numberOfRounds'] >= 6)
                      ? "Range: \$${selectedPackage['min']} - \$${selectedPackage['max']}"
                      : data!['activePackage'] == "Bronze"
                      ? "Range: \$50 - \$499"
                      : "Range: \$${selectedPackage['min']} - \$${selectedPackage['max']}",
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
                    if (data!['activePackage'] == "Bronze") {
                      return null;
                    } else if (amount < selectedPackage['min']) {
                      return 'Minimum amount is \$${selectedPackage['min']}';
                    }
                    // if (amount > selectedPackage['max']) {
                    //   return 'Maximum amount is \$${selectedPackage['max']}';
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

                        // Show fund wallet dialog with amount
                        showFundWalletDialog(
                          context,
                          usdtWalletAddress,
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

// STEP 2: Show Fund Wallet Dialog (with amount)
void showFundWalletDialog(
  BuildContext context,
  String usdtWalletAddress,
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
                      "\$${amount.toStringAsFixed(2)} USDT",
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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Send USDT (TRC20) to the wallet address below.",
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
                        usdtWalletAddress,
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
                        Clipboard.setData(
                          ClipboardData(text: usdtWalletAddress),
                        );

                        // Show success message
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
                  // Record transaction in Firestore
                  await _recordTransaction(
                    context,
                    amount,
                    selectedPackage['name'],
                  );

                  if (selectedPackage['name'] == "Bronze") {
                    sendEmail().sendMail(
                      message:
                          "Admin Notification:\n"
                          "A new payment has been made/sent successfully.\n"
                          "👤 User:  ${getStorage.read('fullname')}\n"
                          "📧 Email:  ${FirebaseAuth.instance.currentUser!.email}\n"
                          "💰 Amount:  \$$amount\n"
                          "🏦 Package:  ${selectedPackage['name']}\n"
                          "💰 Price Range:  \$${selectedPackage['min']} - \$${selectedPackage['max']}\n"
                          "🕒 Time:  ${DateTime.now()}\n"
                          "Please verify in your admin dashboard and ensure proper record updates.",
                    );
                  } else {
                    ////send mail to confirm payment
                    sendEmail().sendMail(
                      message:
                          "Admin Notification:\n"
                          "A new payment has been made/sent successfully.\n"
                          "👤 User:  ${getStorage.read('fullname')}\n"
                          "📧 Email:  ${FirebaseAuth.instance.currentUser!.email}\n"
                          "💰 Amount:  \$$amount\n"
                          "💵 kick Start Fee:  \$${selectedPackage['kickStartFee']}\n"
                          "🏦 Package:  ${selectedPackage['name']}\n"
                          "💰 Price Range:  \$${selectedPackage['min']} - \$${selectedPackage['max']}\n"
                          "🕒 Time:  ${DateTime.now()}\n"
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

// STEP 3: Record Transaction to Firestore
Future<void> _recordTransaction(
  BuildContext context,
  double amount,
  String packageName,
) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    String activePackageData = '';
    double numberOfRoundsData = 0.0;

    // Add transaction to user's transactions collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add({
          'type': 'Deposit',
          'amount': amount,
          'packageName': packageName,
          'status': 'Pending', // Pending until admin confirms
          'timestamp': FieldValue.serverTimestamp(),
          'paymentMethod': 'USDT (TRC20)',
        });

    ///lock activation
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'lockedActivation': true,
    });

    // Show success message
    AuthService().showSuccessSnackBar(
      context: context,
      title: 'Payment confirmation recorded!',
      subTitle: 'Awaiting admin approval.',
    );
  } catch (e) {
    // Show error message
    AuthService().showErrorSnackBar(
      context: context,
      title: "Error recording transaction:",
      subTitle: e.toString(),
    );
  }
}
