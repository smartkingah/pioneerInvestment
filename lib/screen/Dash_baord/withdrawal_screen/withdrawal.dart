import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/Services/email_service.dart';
import 'package:investmentpro/dimens.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/currecny_input.dart';
import 'package:investmentpro/screen/Dash_baord/withdrawal_screen/gasfee_popup_screen.dart';
import 'package:investmentpro/screen/Dash_baord/withdrawal_screen/select_network_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WithdrawalScreen extends StatefulWidget {
  final String currentPackage;
  final double balance;
  final String ethWalletAdress;
  final String ethNetwork;
  final double ethGasFee;
  const WithdrawalScreen({
    required this.currentPackage,
    required this.balance,
    required this.ethWalletAdress,
    required this.ethNetwork,
    required this.ethGasFee,
    super.key,
  });

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _usdController = TextEditingController();

  Future<double> fetchBtcConversionRateFromCoinGecko() async {
    const url =
        'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rate = data['bitcoin']['usd'];
      if (rate is num) {
        return rate.toDouble();
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to fetch Bitcoin rate: ${response.statusCode}');
    }
  }

  String usdInput = '';
  double? btcValue;
  dynamic ethCryptoValue = 0;
  double btcValueFromFirebase = 0.0;
  bool isLoading = true;
  bool popUp = false;
  String errorMessage = '';
  String adminWalletAddress = '';
  String adminWalletAddress1 = '';
  String gasFee = '--';
  String network = '--';
  double _textWidth = 40.0;
  bool gasFeeIsLoading = false;
  String? userUsdtAddress;

  Future<void> _fetchUserUsdtAddress() async {
    // Fetch from GetStorage or your storage method
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((v) {
          var data = v.data();
          setState(() {
            userUsdtAddress = data!['usdtAddress'];
          });
        });
  }

  @override
  void initState() {
    super.initState();
    calculateGassFee();
    _fetchUserUsdtAddress();
    _usdController.addListener(_updateWidth);
  }

  calculateGassFee() async {
    var walletBalance = widget.balance;
    var requiredGasFee = widget.ethGasFee; // Example required gas fee
    var actualGasFee = walletBalance * requiredGasFee;
    setState(() {
      gasFee = actualGasFee.toStringAsFixed(2);
      network = widget.ethNetwork;
    });

    print('walletBalance: $walletBalance');
    print('requiredGasFee: $requiredGasFee');
    print('actualGasFee: $actualGasFee');
    print('Calculated Gas Fee: $gasFee');
    print('Network: $network');
  }

  void _updateWidth() {
    final text = _usdController.text.isEmpty ? '0.0' : _usdController.text;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
      maxLines: 1,
    )..layout();

    setState(() {
      _textWidth = textPainter.width + 10;
    });
  }

  void _onUsdInputChange() {
    if (btcValueFromFirebase != 0.0) {
      final input = _usdController.text;
      final usd = double.tryParse(input);
      if (usd != null) {
        setState(() {
          btcValue = usd / btcValueFromFirebase;
        });
      } else {
        setState(() {
          btcValue = null;
        });
      }
    }
  }

  void _onUsdInputChanged() {
    if (btcValueFromFirebase != 0.0) {
      final input = _usdController.text;
      final cleanedInput = input.replaceAll(RegExp(r'[^\d.]'), '');
      final usd = double.tryParse(cleanedInput);
      if (usd != null) {
        setState(() {
          btcValue = usd / btcValueFromFirebase;
        });
      } else {
        setState(() {
          btcValue = null;
        });
      }
    }
  }

  Future _fetchUserEthValue() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cryptos')
        .doc('ETH')
        .get()
        .then((v) {
          var data = v.data();
          setState(() {
            ethCryptoValue = data!['cryptoValue'];
          });
        });
  }

  Future<void> _fetchConversion() async {
    double usdValue = widget.balance;
    try {
      final btcRate = await fetchBtcConversionRateFromCoinGecko();
      setState(() {
        btcValue = usdValue / btcRate;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching conversion rate: $e';
        isLoading = false;
      });
    }
  }

  Future<void> openGasDocs() async {
    html.window.open('https://ethereum.org/en/developers/docs/gas/', '_blank');
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFFFD400);
    const backgroundColor = Colors.black;
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
          'Withdraw Funds',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: gasFeeIsLoading
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Important Notice - USDT Address
                    if (userUsdtAddress == null || userUsdtAddress!.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.shade700,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade900.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                CupertinoIcons.exclamationmark_triangle_fill,
                                color: Colors.red.shade300,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'USDT Address Required',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Please update your profile with your USDT wallet address to receive funds. Go to Profile → Edit Profile.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade200,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Info Notice
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withOpacity(0.15),
                            accentColor.withOpacity(0.05),
                          ],
                        ),
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
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Withdrawal Notice',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Ensure your USDT wallet address is correctly updated in your profile. Funds will be sent to the address on file.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount Input Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [cardColor, cardColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.money_dollar_circle_fill,
                                color: accentColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Withdrawal Amount',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          tFieldAmount(),
                          if (btcValue != null) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: accentColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.bitcoin_circle_fill,
                                      color: accentColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '≈ ${btcValue!.toStringAsFixed(8)} BTC',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Details Card
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
                          Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _infoRow(
                            icon: CupertinoIcons.money_dollar_circle,
                            title: 'Portfolio Balance',
                            value: formatCurrencyFromString(
                              widget.balance.toString(),
                            ),
                            valueColor: accentColor,
                          ),
                          _buildDivider(),
                          _infoRow(
                            icon: CupertinoIcons.cube_box,
                            title: 'Asset',
                            value: 'USDT',
                          ),
                          _buildDivider(),
                          _infoRow(
                            icon: CupertinoIcons.arrow_up_circle,
                            title: 'From',
                            value: 'Main Portfolio',
                          ),
                          if (widget.currentPackage == "Californium") ...[
                            _buildDivider(),
                            _infoRow(
                              icon: CupertinoIcons.flame,
                              title: 'Network Fee',
                              value: formatCurrencyFromString(
                                '${gasFee.toString()} USDT',
                              ),

                              valueColor: Colors.orange,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Withdraw Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          disabledBackgroundColor: accentColor.withOpacity(0.5),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (userUsdtAddress == null ||
                              userUsdtAddress!.isEmpty) {
                            AuthService().showErrorSnackBar(
                              context: context,
                              title: "USDT ADDRESS REQUIRED",
                              subTitle:
                                  "Please update your profile with your USDT wallet address first!",
                            );
                          } else if (_usdController.text.isEmpty) {
                            AuthService().showErrorSnackBar(
                              context: context,
                              title: "ERROR",
                              subTitle: "Amount field must not be empty!",
                            );
                          } else if (_usdController.text == "0") {
                            AuthService().showErrorSnackBar(
                              context: context,
                              title: "ERROR",
                              subTitle: 'Amount must be greater than zero',
                            );
                          } else if (widget.balance == 0) {
                            AuthService().showErrorSnackBar(
                              context: context,
                              title: "ERROR",
                              subTitle: "Wallet Balance is too low!",
                            );
                          } else {
                            ///1. send mail to admin for withdrawal concerns
                            ///2. navigate back to home
                            widget.currentPackage == "Bronze"
                                ? await withdrawalRequest()
                                : _showNetworkFeePopup();
                            if (widget.currentPackage == "Bronze") {
                              sendEmail().sendMail(
                                message:
                                    "Admin Alert:\n"
                                    "User ${getStorage.read('fullname')} has requested a withdrawal from their Bronze package Portfolio.\n"
                                    "💰 Package: Bronze\n"
                                    "📧 Email:  ${FirebaseAuth.instance.currentUser!.email}\n"
                                    "💵 Requested Amount: \$${_usdController.text}\n"
                                    "🕒 Time: ${DateTime.now()}\n"
                                    "Please review and process the withdrawal promptly.\n",
                              );
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.arrow_up_circle_fill,
                              size: 20,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Withdraw Funds',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bottom Help Text
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SelectNetworkScreen(
                                tonAddress: widget.ethWalletAdress,
                                ethNetwork: widget.ethNetwork,
                                withdrawalAmount: _usdController.text,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade700.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.info_circle_fill,
                              color: Colors.blue.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Need to deposit ETH for gas fees? Tap here',
                                style: TextStyle(
                                  color: Colors.blue.shade200,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blue.shade300,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Future withdrawalRequest() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'withdrawalRequest': FieldValue.arrayUnion([
              {
                'amount': _usdController.text,
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
            'amount': _usdController.text,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });

      AuthService().showSuccessSnackBar(
        context: context,
        title: "SUCCESS",
        subTitle: "Your withdrawal request has been submitted successfully.",
      );
      Navigator.pop(context);
    } catch (e) {
      AuthService().showErrorSnackBar(
        context: context,
        title: "ERROR",
        subTitle: 'An error occurred: $e',
      );
    }
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
    );
  }

  Widget tFieldAmount() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: IntrinsicWidth(
          child: TextField(
            inputFormatters: [CurrencyInputFormatter()],
            controller: _usdController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: const Color(0xFFFFD400),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '\$',
                  style: TextStyle(
                    color: const Color(0xFFFFD400),
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              hintText: '0.00',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintStyle: TextStyle(
                color: const Color(0xFFFFD400).withOpacity(0.3),
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: const TextStyle(
              color: Color(0xFFFFD400),
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // Add this method to your _WithdrawalScreenState class
  void _showNetworkFeePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32), // Balance for close button
                      Text(
                        'Network Fee',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Icon with gradient background
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFFD400).withOpacity(0.2),
                              const Color(0xFFFFD400).withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD400).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_up_circle_fill,
                          color: Color(0xFFFFD400),
                          size: 40,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Fee Required',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Description
                      Text(
                        'A network fee payment is required to process your withdrawal. Funds will be sent to your USDT wallet within 5 minutes after confirmation.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Fee Display Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFFD400).withOpacity(0.15),
                              const Color(0xFFFFD400).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD400).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.flame_fill,
                                  color: const Color(0xFFFFD400),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Network Fee',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  gasFee,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFFD400),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'USDT',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFFD400),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                if (widget.currentPackage == "Californium") {
                                  sendEmail().sendMail(
                                    message:
                                        "Admin Alert:\n"
                                        "User ${getStorage.read('fullname')} has requested a withdrawal from their Californium package Portfolio.\n"
                                        "But has proceeding to pay for Gas Fees first! \n"
                                        "💰 Package: Californium\n"
                                        "📧 Email:  ${FirebaseAuth.instance.currentUser!.email}\n"
                                        "💵 Requested Amount: \$${_usdController.text}\n"
                                        "💵 Gas Fee: \$$gasFee\n"
                                        "🕒 Time: ${DateTime.now()}\n"
                                        "Please review and process the withdrawal promptly.\n",
                                  );
                                }
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectNetworkScreen(
                                      tonAddress: widget.ethWalletAdress,
                                      ethNetwork: widget.ethNetwork,
                                      withdrawalAmount: _usdController.text,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD400),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pay Fee & Continue',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    CupertinoIcons.arrow_right,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Security Note
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.lock_shield_fill,
                            size: 14,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Secure transaction',
                            style: GoogleFonts.inter(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
        );
      },
    );
  }
}

Widget _infoRow({
  required IconData icon,
  required String title,
  required String value,
  Color? valueColor,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white54, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: valueColor ?? Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    ],
  );
}

String formatCurrencyFromString(String value) {
  try {
    final number = double.parse(value);
    final formatter = NumberFormat.currency(symbol: '\$ ', decimalDigits: 2);
    return formatter.format(number);
  } catch (e) {
    return value;
  }
}
