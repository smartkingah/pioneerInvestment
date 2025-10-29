import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/Services/email_service.dart';
import 'package:investmentpro/providers/model_provider.dart';
import 'package:investmentpro/screen/Auth/auth_screen.dart';
import 'package:provider/provider.dart';

GetStorage getStorage = GetStorage();
AuthService authService = AuthService();

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _fs = FirebaseFirestore.instance;
  // Generate a 7-character, space-free referral code
  static String generateReferralCode(String uid, String fullname) {
    // Remove spaces from fullname and take the first 3 letters (uppercase)
    String namePart = fullname.replaceAll(' ', '').toUpperCase();
    namePart = namePart.length >= 3 ? namePart.substring(0, 3) : namePart;

    // Take 4 random characters from the uid
    String uidPart = uid.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    uidPart = uidPart.length >= 4
        ? uidPart.substring(0, 4)
        : uidPart.padRight(4, 'X');

    // Combine both to form a 7-character code
    return (namePart + uidPart).substring(0, 7);
  }

  // Signup
  static Future<User?> signUp({
    required String fullname,
    required String email,
    required String password,
    required String phone,
    required String country,
    required String address,
    required String referredBy, // The code user entered when signing up
    required BuildContext context,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;

    if (user != null) {
      // Generate the user’s own referral code
      String myReferralCode = generateReferralCode(user.uid, fullname);

      // Create user document
      await _fs.collection('users').doc(user.uid).set({
        'fullname': fullname,
        'email': email,
        'phone': phone,
        'country': country,
        'address': address,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'wallet': 0.0,
        'password': password,
        'totalEarnings': 0,
        'package': "none",
        'activePackage': "none",
        'investmentAmount': 0,
        'lastInvestmentDate': null,
        'withdrawalRequest': [],
        'maxPackageLimit': 0,
        'dailyGrowth': 0,
        'lockedActivation': false,
        'nextPayoutDate': null,
        'kickStartFee': 0,
        'numberOfRounds': 0,

        // 👇 Added fields
        'referralCode': myReferralCode, // their own code
        'referredBy': referredBy.isNotEmpty
            ? referredBy
            : '', // who referred them
      });

      // 👇 Optionally: Update the referrer’s referral count
      if (referredBy.isNotEmpty) {
        final refQuery = await _fs
            .collection('users')
            .where('referralCode', isEqualTo: referredBy)
            .limit(1)
            .get();

        if (refQuery.docs.isNotEmpty) {
          final refDoc = refQuery.docs.first;
          await refDoc.reference.update({
            'referrals': FieldValue.arrayUnion([user.uid]),
          });
        }
      }

      getStorage.write('fullname', fullname);
      Provider.of<ModelProvider>(
        context,
        listen: false,
      ).setuserNameData(userName: getStorage.read('fullname'));
    }

    return user;
  }

  // Login
  static Future<User?> signIn({
    required String email,
    required String password,
    required context,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) return null;

      // Fetch user details from Firestore
      await _fs.collection('users').doc(user.uid).get().then((v) {
        var data = v.data();
        getStorage.write('photoUrl', data!['photoUrl']);
        getStorage.write('fullname', data['fullname']);
        Provider.of<ModelProvider>(
          context,
          listen: false,
        ).setuserPhotUrlData(photoUrl: getStorage.read('photoUrl'));
        Provider.of<ModelProvider>(
          context,
          listen: false,
        ).setuserNameData(userName: getStorage.read('fullname'));

        ///sendmail
        sendEmail().sendMail(
          message:
              "Admin Alert:\n"
              "User ${getStorage.read('fullname')} just logged in to their account.\n"
              "🕒 Time:  ${DateTime.now()}\n"
              "📧 Email:  ${FirebaseAuth.instance.currentUser!.email}\n"
              // "📱 IP / Device: [DeviceInfo]"
              "This is an automatic security and activity notification from Pioneer Capital LTD",
        );
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AuthState();
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login error',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<void> signOut() => _auth.signOut();

  static Future<Map<String, dynamic>?> getUserDoc(String uid) async {
    final doc = await _fs.collection('users').doc(uid).get();
    if (doc.exists) return doc.data();
    return null;
  }

  static Future<void> updatePhotoUrl(
    String uid,
    String photoUrl,
    context,
  ) async {
    await _fs.collection('users').doc(uid).update({'photoUrl': photoUrl});
    getStorage.write('photoUrl', photoUrl);
    Provider.of<ModelProvider>(
      context,
      listen: false,
    ).setuserPhotUrlData(photoUrl: getStorage.read('photoUrl'));
  }

  ///activateInvestment

  Future<void> activateInvestment(
    Map<String, dynamic> package,
    context,
    clearPackge,
  ) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      final userSnap = await userRef.get();
      if (!userSnap.exists) return;

      final data = userSnap.data()!;
      final double wallet =
          double.tryParse(data['wallet']?.toString() ?? '0') ?? 0.0;
      final numberOfRounds = data['numberOfRounds'] ?? 0.0;

      final double packageMin =
          double.tryParse(package['min']?.toString() ?? '0') ?? 0.0;
      final double packageRoi =
          double.tryParse(package['roi']?.toString() ?? '0') ?? 0.0;
      final int duration =
          int.tryParse(package['durationDays']?.toString() ?? '1') ?? 1;

      // Step 1: Check if wallet has enough funds
      if (wallet < packageMin) {
        showWarningSnackBar(
          context,
          'Payment Pending',
          "Insufficient balance for ${package['name']} package",
        );
        return;
      }

      // Step 2: Deduct investment amount (use packageMin for simplicity)
      final double investAmount = packageMin;
      final double roi = packageRoi / 100;

      // Step 3: Calculate daily growth
      final double dailyGrowth = (investAmount * roi) / duration;

      // Step 4: Compute next payout date
      final DateTime nextPayout = DateTime.now().add(Duration(days: duration));

      // Step 5: Update Firestore
      await userRef
          .update({
            // 'wallet': wallet - investAmount,
            'wallet': wallet - wallet,
            'activePackage': package['name'],
            'maxPackageLimit': package['max'],
            'investmentAmount': investAmount,
            'packageRoi': roi,
            'lastInvestmentDate': DateTime.now().toIso8601String(),
            'nextPayoutDate': nextPayout.toIso8601String(),
            'dailyGrowth': dailyGrowth,
            "numberOfRounds": numberOfRounds + 1,
            "duration": duration,
            'kickStartFee': package['kickStartFee'],
            'totalEarnings': data['totalEarnings'] ?? 0.0,
          })
          .then((v) async {
            await clearPackge;
          });

      // Step 6: Record transaction
      await recordTransaction(
        type: "Investment",
        amount: investAmount,
        status: "Completed",
      );

      // Step 7: Notify user
      showSuccessSnackBar(
        title: "Activation Successful!",
        subTitle: "${package['name']} package is now active",
        context: context,
      );
    } catch (e) {
      showErrorSnackBar(
        context: context,
        title: "Activation Failed",
        subTitle: e.toString(),
      );
    }
  }

  Future<void> recordTransaction({
    required String
    type, // e.g. "Investment", "Reactivation", "Payout", "Withdrawal"
    required double amount,
    required String status, // e.g. "Completed" or "Pending"
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await userRef.collection('transactions').add({
      'type': type,
      'amount': amount.toStringAsFixed(2),
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ✅ SUCCESS SNACKBAR - Package Activated
  void showSuccessSnackBar({
    required BuildContext context,
    required String title,
    required String subTitle,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ECB81).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF0ECB81),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subTitle,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ECB81).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Color(0xFF0ECB81),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF0ECB81), width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  // ❌ ERROR SNACKBAR - Insufficient Balance
  void showErrorSnackBar({
    required BuildContext context,
    required String title,
    required String subTitle,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_rounded,
                  color: Colors.redAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subTitle,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.redAccent,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 8,
        // action: SnackBarAction(
        //   label: 'Fund Now',
        //   textColor: const Color(0xFFD4A017),
        //   onPressed: () {
        //     // Trigger fund wallet dialog
        //   },
        // ),
      ),
    );
  }

  // ⚠️ WARNING SNACKBAR (Optional - for pending confirmations)
  void showWarningSnackBar(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB020).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Color(0xFFFFB020),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFFB020), width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  // 🎯 INFO SNACKBAR (Optional - general info)
  void showInfoSnackBar(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFD4A017),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFD4A017), width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }
}
