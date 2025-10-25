import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/dimens.dart';
import 'package:investmentpro/main.dart';
import 'package:investmentpro/screen/Auth/auth_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SelectNetworkScreen extends StatefulWidget {
  final String tonAddress, ethNetwork;
  final bool withdrawalScreen;
  final dynamic withdrawalAmount;

  const SelectNetworkScreen({
    super.key,
    this.withdrawalScreen = false,
    required this.withdrawalAmount,
    required this.ethNetwork,
    required this.tonAddress,
  });

  @override
  State<SelectNetworkScreen> createState() => _SelectNetworkScreenState();
}

class _SelectNetworkScreenState extends State<SelectNetworkScreen> {
  String selectedNetwork = 'Loading...';
  List<String> networkOptions = [];
  bool _isLoading = true;
  bool _addressCopied = false;

  @override
  void initState() {
    super.initState();
    fetchNetworkFromBackend();
  }

  Future<void> fetchNetworkFromBackend() async {
    await Future.delayed(const Duration(seconds: 1));
    final fetchedNetwork = widget.ethNetwork;

    setState(() {
      selectedNetwork = fetchedNetwork;
      networkOptions = [fetchedNetwork];
      _isLoading = false;
    });
  }

  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: widget.tonAddress));
    setState(() {
      _addressCopied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(CupertinoIcons.check_mark_circled_solid, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Address copied to clipboard!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _addressCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFFFD400);
    const backgroundColor = Color(0xFF0A0A0A);
    const cardColor = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.withdrawalScreen ? "Withdraw Assets" : 'Deposit Gas Fee',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Network Selection Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                CupertinoIcons.link,
                                color: accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Network',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  CupertinoIcons.checkmark_alt,
                                  color: accentColor,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                selectedNetwork,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              size: 14,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Expected arrival: 2min 50sec',
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // QR Code & Address Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cardColor, cardColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // QR Code
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: widget.tonAddress,
                            version: QrVersions.auto,
                            size: 180.0,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Network Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.wifi,
                                size: 16,
                                color: accentColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.ethNetwork} Network',
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Instructions
                        Text(
                          'Scan the QR code or copy the address below to deposit cryptocurrency using the $selectedNetwork network.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Address Copy Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.location_solid,
                                    size: 14,
                                    color: Colors.white54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Wallet Address',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.tonAddress,
                                      style: GoogleFonts.caprasimo(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: _copyAddress,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _addressCopied
                                            ? const Color(0xFF10B981)
                                            : accentColor,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                (_addressCopied
                                                        ? const Color(
                                                            0xFF10B981,
                                                          )
                                                        : accentColor)
                                                    .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _addressCopied
                                            ? CupertinoIcons.check_mark
                                            : CupertinoIcons.doc_on_doc,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Important Notice
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            CupertinoIcons.lightbulb_fill,
                            color: accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Network Recommendation',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'We recommend using the ',
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'TRC20 network ',
                                      style: GoogleFonts.inter(
                                        color: accentColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        height: 1.5,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'for USDT deposits as it\'s the fastest to process payments.',
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Deposit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        withdrawalRequest(
                          withdrawalAmount: widget.withdrawalAmount,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.arrow_down_circle_fill,
                            size: 20,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.withdrawalScreen
                                ? " Confirm Withdrawal"
                                : 'Confirm Deposit',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Future withdrawalRequest({withdrawalAmount}) async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'withdrawalRequest': FieldValue.arrayUnion([
              {
                'amount': withdrawalAmount,
                'status': 'pending',
                'timestamp': DateTime.now(),
              },
            ]),
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .add({
            'type': 'withdrawal',
            'amount': withdrawalAmount,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });

      AuthService().showSuccessSnackBar(
        context: context,
        title: "SUCCESS",
        subTitle:
            "Please await while we confirm your depost! Your Withdrawal request has been sent succesffully. Need Help! Contact Customer Support!",
      );
      Get.offAll(() => AuthState());
    } catch (e) {
      AuthService().showErrorSnackBar(
        context: context,
        title: "ERROR",
        subTitle: 'An error occurred: $e',
      );
    }
  }
}
