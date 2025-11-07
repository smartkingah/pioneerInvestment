import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/select_usdt_address.dart'
    show showAmountInputDialog;

class ActiveInvestmentCard extends StatefulWidget {
  const ActiveInvestmentCard({super.key});

  @override
  State<ActiveInvestmentCard> createState() => _ActiveInvestmentCardState();
}

class _ActiveInvestmentCardState extends State<ActiveInvestmentCard> {
  Map<String, dynamic>? _activeData;
  Duration? _remainingTime;
  Timer? _timer;
  var profitData = 0.0;
  String activePackageData = '';
  double numberOfRoundsData = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchActivePackage();
  }

  Future<void> _fetchActivePackage() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    if (data.containsKey('activePackage')) {
      final activePackage = data['activePackage'];
      final numberOfRounds = data['numberOfRounds'];
      setState(() {
        activePackageData = activePackage;
        numberOfRoundsData = numberOfRounds;
      });
      final rawDate = data['nextPayoutDate'];
      DateTime nextPayout;

      if (rawDate is Timestamp) {
        nextPayout = rawDate.toDate();
      } else {
        nextPayout = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
      }

      final remaining = nextPayout.difference(DateTime.now());

      setState(() {
        _activeData = data;
        _remainingTime = remaining.isNegative ? Duration.zero : remaining;
      });
      // ✅ Check if already expired when app opens
      if (remaining.isNegative || remaining == Duration.zero) {
        await _triggerPayout(); // Handle expired investments
      }

      _startCountdown();
      // if (remaining.isNegative || remaining == Duration.zero) {
      //   await _triggerPayout();
      // }
    }
  }

  /// 🕐 Starts the countdown and triggers automatic payout when done
  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingTime == null) return;

      if (_remainingTime!.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime!.inSeconds - 1);
        });
      } else {
        _timer?.cancel();

        setState(() {
          _remainingTime = Duration.zero;
        });
      }
    });
  }

  /// 💰 This function handles automatic payout when timer reaches zero
  Future<void> _triggerPayout() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final snap = await userRef.get();
      if (!snap.exists) return;

      ///user exists lets proceed to trigger payout
      final data = snap.data()!;
      final double investAmount = data['investmentAmount'];
      final double packageRoi = data['packageRoi'];
      final wallet = double.tryParse(data['wallet'].toString()) ?? 0.0;

      final duration = data['duration'] ?? {};

      // final dailyGrowth = double.tryParse(package['dailyGrowth']) ?? 0.0;
      final profit = investAmount * packageRoi;

      // Add payout to wallet
      final newWallet = investAmount + profit;
      final totalEarnings = data['totalEarnings'] + profit;

      await userRef.update({
        'wallet': newWallet,
        'totalEarnings': wallet,

        // 'lastInvestmentDate': DateTime.now().toIso8601String(),
        // 'nextPayoutDate': nextPayout.toIso8601String(),
      });
      wallet == 0
          ? AuthService().showSuccessSnackBar(
              context: context,
              title: "✅ Automatic payout of \$$profit added.",
              subTitle: " Next payout scheduled.",
            )
          : null;
      setState(() {
        profitData = profit;
      });
      debugPrint(
        "✅ Automatic payout of \$profit added. Next payout scheduled.",
      );
    } catch (e) {
      debugPrint("❌ Error triggering payout: $e");
    }
  }

  /// ♻️ Reactivation logic — restarts investment with new payout date
  Future<void> _reactivatePackage() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final snap = await userRef.get();

      if (!snap.exists) return;

      final data = snap.data()!;
      final numberOfRounds = data['numberOfRounds'] ?? {};
      final duration = data['duration'] ?? {};
      final wallet = double.tryParse(data['wallet'].toString()) ?? 0.0;
      // New payout date (e.g., next day)
      final nextPayout = DateTime.now().add(Duration(days: duration));

      await userRef.update({
        "investmentAmount": wallet,
        'wallet': 0,
        'lastInvestmentDate': DateTime.now().toIso8601String(),
        'nextPayoutDate': nextPayout.toIso8601String(),
        'numberOfRounds': numberOfRounds + 1,
      });

      await userRef.collection('transactions').add({
        'type': 'Investment Reactivation',
        'amount': wallet,
        'status': 'Completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _remainingTime = const Duration(days: 1);
      });

      _startCountdown();

      debugPrint("♻️ Package reactivated successfully!");
    } catch (e) {
      debugPrint("❌ Error reactivating package: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = duration.inDays;
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (days > 0) {
      return "$days days $hours:$minutes:$seconds";
    } else {
      return "$hours:$minutes:$seconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeData == null) return const SizedBox();

    final bool isExpired = _remainingTime == Duration.zero;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4A017).withOpacity(0.15),
            const Color(0xFFD4A017).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isExpired
                      ? Icons.restart_alt_rounded
                      : Icons.rocket_launch_rounded,
                  color: const Color(0xFFD4A017),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  isExpired ? "Your package has matured" : "Active Investment",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!isExpired)
            Column(
              children: [
                Text(
                  "Next Payout In",
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDuration(_remainingTime!),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFD4A017),
                    fontWeight: !isExpired ? FontWeight.w800 : FontWeight.bold,
                    fontSize: !isExpired ? 30 : 15,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          !isExpired
              ? SizedBox()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (isExpired) {
                        ///1. check if its locked and its Bronze has run 5 times then push to next plan quickly
                        ///2. if its locked and its not BRONZE pay kickstart Capital
                        ///3.

                        _reactivatePackage().then((value) async {
                          // Refresh UI
                          // _fetchActivePackage();
                          // await _triggerPayout(); // ✅ Automatically trigger payout
                          AuthService().showSuccessSnackBar(
                            context: context,
                            title: "✅ Package reactivated successfully.",
                            subTitle: " Your investment is live again!",
                          );
                        }); // ♻️ Reactivation flow
                        // _reactivatePackage(); // ♻️ Reactivation flow
                      } else {
                        ///remove this late
                        // _triggerPayout();
                        debugPrint("Package active, waiting for payout...");
                      }
                    },
                    child: Text(
                      isExpired ? "Reactivate Package" : "Active Package",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

///reactivation widget

class ReactivationLockedWidget extends StatelessWidget {
  final String packageName;
  final String subTitle;
  final String usdtWalletAddress;
  final String btctWalletAddress;
  final dynamic? data;
  const ReactivationLockedWidget({
    required this.packageName,
    required this.subTitle,
    required this.usdtWalletAddress,
    required this.btctWalletAddress,
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4A017).withOpacity(0.15),
            const Color(0xFFD4A017).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔒 Icon and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFFD4A017),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Investment Locked",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🕒 Message
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // 📞 Support Button
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
              ),
              onPressed: () {
                // 🧩 Replace with your actual support action
                debugPrint("Contacting support...");
                // AuthService().showInfoSnackBar(
                //   context,
                //   'Contact support!',
                //   "Use the button at the Bottom Right corner to contact suport!",
                // );
                showAmountInputDialog(
                  context,
                  usdtWalletAddress,
                  btctWalletAddress,
                  packageName == "Bronze"
                      ? {
                          'name': 'Silver',
                          'min': 1000,
                          'max': 4999,
                          'roi': 20,
                          'durationDays': 2,
                          "kickStartFee": 500,
                        }
                      : packageName == "Silver"
                      ? {
                          'name': 'Gold',
                          'min': 5000,
                          'max': 19999,
                          'roi': 25,
                          'durationDays': 4,
                          "kickStartFee": 1000,
                        }
                      : packageName == "Gold"
                      ? {
                          'name': 'Platinum',
                          'min': 20000,
                          'max': 99999,
                          'roi': 30,
                          'durationDays': 7,
                          "kickStartFee": 1500,
                        }
                      : packageName == "Platinum"
                      ? {
                          'name': 'Californium',
                          'min': 100000,
                          'max': 499999,
                          'roi': 50,
                          'durationDays': 30,
                          "kickStartFee": 10000,
                        }
                      : {
                          'name': 'Executive',
                          'min': 500000,
                          'max': 1000000,
                          'roi': 70,
                          'durationDays': 90,
                          "kickStartFee": 50000,
                        },
                  data,
                );
              },
              icon: const Icon(Icons.wallet_rounded),
              label: Text(
                packageName == "Bronze"
                    ? 'Upgrade to next plan!'
                    : "Pay Kick-Start Fee",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          SizedBox(height: 12),

          // 🕒 contact support
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.support_agent_rounded,
                size: 14,
                color: Colors.amber,
              ),
              Text(
                " Need help? Contact support.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.amber,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
