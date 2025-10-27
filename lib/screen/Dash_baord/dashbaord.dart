import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/providers/model_provider.dart';
import 'package:investmentpro/screen/Auth/auth_screen.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/chart.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/dashboardAppBar.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/dashboard_analytics_metrics.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/draggable_floating_button.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/investmentcard.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/select_usdt_address.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/transaction.dart';
import 'package:investmentpro/screen/Dash_baord/withdrawal_screen/withdrawal.dart';
import 'package:investmentpro/screen/admin_/admin_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;

class InvestmentDashboard extends StatefulWidget {
  const InvestmentDashboard({super.key});

  @override
  State<InvestmentDashboard> createState() => _InvestmentDashboardState();
}

class _InvestmentDashboardState extends State<InvestmentDashboard>
    with WidgetsBindingObserver {
  bool _showPackages = false;
  String usdtWalletAddress = '';
  String ethwalletAddress = '';
  double ethGasFee = 0.0;
  String ethNetwork = '';
  String activePackageData = '';
  double numberOfRoundsData = 0.0;
  String userWalletBalance = "0.0";
  double maxPackageLimit = 0.0;
  Map<String, dynamic>? _selectedPackage;
  Map<String, dynamic>? _pendingPackage;

  final List<Map<String, dynamic>> packages = [
    {
      "name": "Bronze",
      "range": "\$50 – \$499",
      "rate": "10% every 24 hrs",
      "color": Colors.brown[300],
    },
    {
      "name": "Silver",
      "range": "\$1,000 – \$4,999",
      "rate": "20% every 48 hrs",
      "color": Colors.grey[400],
    },
    {
      "name": "Gold",
      "range": "\$5,000 – \$19,999",
      "rate": "25% every 4 days",
      "color": const Color(0xFFD4A017),
    },
    {
      "name": "Platinum",
      "range": "\$20,000 – \$99,999",
      "rate": "30% every 7 days",
      "color": Colors.blueGrey[200],
    },
    {
      "name": "Californium",
      "range": "\$100,000 – \$499,999",
      "rate": "50% every 30 days",
      "color": Colors.teal[300],
    },
    {
      "name": "Executive",
      "range": "\$500,000 – \$1,000,000",
      "rate": "70% every 90 days",
      "color": Colors.purple[300],
    },
  ];

  final List<Map<String, dynamic>> investmentPackages = [
    {
      'name': 'Bronze',
      'min': 50,
      'max': 499,
      'roi': 10,
      'durationDays': 1,
      "kickStartFee": 5,
    },
    {
      'name': 'Silver',
      'min': 1000,
      'max': 4999,
      'roi': 20,
      'durationDays': 2,
      "kickStartFee": 500,
    },
    {
      'name': 'Gold',
      'min': 5000,
      'max': 19999,
      'roi': 25,
      'durationDays': 4,
      "kickStartFee": 1000,
    },
    {
      'name': 'Platinum',
      'min': 20000,
      'max': 99999,
      'roi': 30,
      'durationDays': 7,
      "kickStartFee": 1500,
    },
    {
      'name': 'Californium',
      'min': 100000,
      'max': 499999,
      'roi': 50,
      'durationDays': 30,
      "kickStartFee": 10000,
    },
    {
      'name': 'Executive',
      'min': 500000,
      'max': 1000000,
      'roi': 70,
      'durationDays': 90,
      "kickStartFee": 50000,
    },
  ];

  ///SETTING STATUS (ONLINE/OFFLINE)
  void setStatus(String status) async {
    if (!mounted) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'status': status, 'lastSeen': DateTime.now()});
  }

  Future<bool> _onWillPop() async {
    bool? exitApp = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Exit App?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          "Are you sure you want to exit Pioneer Capital LTD?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No", style: TextStyle(color: Color(0xFFD4A017))),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text("Yes", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return exitApp ?? false;
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchusdtWalletAddressData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPendingPackage();
      fetchUserData();
      setStatus("online");
    });

    // _fetchPendingPackage();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      //online
      setStatus('online');
    } else {
      //offline
      setStatus("offline");
    }
  }

  ///fetch userData

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).get().then((
      value,
    ) {
      var data = value.data();
      setState(() {
        activePackageData = data!['activePackage'];
        numberOfRoundsData = data['numberOfRounds'];
        userWalletBalance = data['wallet'].toString();
        maxPackageLimit = data['maxPackageLimit'];
      });
      _lockActivation();
    });
  }

  Future<void> _fetchPendingPackage() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) return;

      final data = userDoc.data();
      if (data == null) return;

      // Check if the field exists and is a Map
      final pendingPackage = data['pendingPackage'] ?? {};
      if (pendingPackage != null && pendingPackage is Map<String, dynamic>) {
        setState(() {
          _pendingPackage = pendingPackage;
        });
      } else {
        debugPrint(
          "⚠️ pendingPackage is not a Map or is null: $pendingPackage",
        );
      }
    } catch (e, stack) {
      debugPrint("❌ Error fetching pending package: $e");
      debugPrint("$stack");
    }
  }

  ///lock activation when bronze ran for 5times and send mail to admin for that cause
  Future _lockActivation() async {
    print('am checking locked activation ----------------------------------');
    if (activePackageData == 'Bronze' && numberOfRoundsData >= 5) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "lockedActivation": true,
      });

      ///send mail to admin informing them of this action
    } else if (activePackageData != 'Bronze' &&
        double.parse(userWalletBalance) >= maxPackageLimit) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "lockedActivation": true,
      });

      ///send mail to admin informing them of this action
    }
  }

  // Store selected package to Firestore
  Future<void> _storePendingPackage(Map<String, dynamic> package) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'pendingPackage': package,
      'pendingPackageTimestamp': FieldValue.serverTimestamp(),
      "lockedActivation": true,
    });

    setState(() {
      _pendingPackage = package;
    });
  }

  // Clear pending package after activation
  Future<void> _clearPendingPackage() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'pendingPackage': FieldValue.delete(),
      'pendingPackageTimestamp': FieldValue.delete(),
    });

    setState(() {
      _pendingPackage = null;
    });
  }

  Future fetchusdtWalletAddressData() async {
    await FirebaseFirestore.instance
        .collection('admin')
        .doc("adminConst")
        .get()
        .then((v) {
          var data = v.data();
          setState(() {
            usdtWalletAddress = data!['usdtAddress'];
            ethwalletAddress = data!['ethwalletAddress'];
            ethGasFee = data['ethGasFee'];
            ethNetwork = data['ethNetwork'];
          });

          print("==========>>>>>>>>address: $usdtWalletAddress");

          // model.warningToast(context: context, title: adminList.join(", "));
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double screenWidth = MediaQuery.of(context).size.width;
    // fetchUserData();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminButton(),
            const SizedBox(height: 12),
            FloatingActionButton.small(
              backgroundColor: const Color(0xFF2C2C2E),
              elevation: 2,
              onPressed: () {
                showLogoutDialog();
              },
              child: const Icon(
                Icons.logout_outlined,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF000000),
        appBar: dashBoardAppBar(context: context),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            var data = snapshot.data;

            if (snapshot.connectionState == ConnectionState.waiting) {
              // 🔹 Shimmer loading placeholder
              return _buildShimmerPlaceholder(isMobile, screenWidth);
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  "No data found.",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return Stack(
              children: [
                mainContent(
                  isMobile: isMobile,
                  screenWidth: screenWidth,
                  data: data,
                  context: context,
                ),
                const HelpFloatingButton(), // floating draggable help button
              ],
            );
          },
        ),
      ),
    );
  }

  /// 🔹 Shimmer Placeholder while loading data
  Widget _buildShimmerPlaceholder(bool isMobile, double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 16
            : (screenWidth > 1200 ? screenWidth * 0.1 : 32),
        vertical: 20,
      ),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget mainContent({isMobile, screenWidth, data, context}) {
    final formatter = NumberFormat("#,##0", "en_US");
    List withdrawalRequests = List.from(data['withdrawalRequest'] ?? []);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 16
            : (screenWidth > 1200 ? screenWidth * 0.1 : 32),
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WALLET SECTION - Compact
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2C2C2E)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Balance",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white60,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatCurrencyFromString(
                        "\$${formatter.format(data['wallet'])}",
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                // ElevatedButton.icon(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFFD4A017),
                //     foregroundColor: Colors.black,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 14,
                //     ),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     elevation: 0,
                //   ),
                //   onPressed: () =>
                //       showFundWalletDialog(context, usdtWalletAddress),
                //   icon: const Icon(Icons.add, size: 18),
                //   label: Text(
                //     "Fund Wallet",
                //     style: GoogleFonts.inter(
                //       fontWeight: FontWeight.w600,
                //       fontSize: 14,
                //     ),
                //   ),
                // ),

                // import 'package:badges/badges.dart' as badges;  // Add this package in pubspec.yaml: badges: ^3.1.2
                badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -8, end: -10),
                  showBadge: ((withdrawalRequests).any(
                    (req) => req['status'] == 'pending',
                  )),
                  badgeContent: const Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.red,
                    padding: EdgeInsets.all(5),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          data["activePackage"] == "Bronze" ||
                              data["activePackage"] == "none" ||
                              data["activePackage"] == "Californium"
                          ? const Color(0xFFD4A017)
                          : Colors.grey[400],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      bool isPending = ((withdrawalRequests).any(
                        (req) => req['status'] == 'pending',
                      ));

                      isPending
                          ? AuthService().showWarningSnackBar(
                              context,
                              'Pending Withdrawal Request',
                              'You have a pending withdrawal request. Please wait for it to be processed before making a new one.',
                            )
                          : data["activePackage"] == "none"
                          ? _showPackageSelectionDialog(context)
                          : data["activePackage"] == "Bronze" ||
                                data["activePackage"] == "Californium"
                          ? Get.to(
                              () => WithdrawalScreen(
                                // ethWalletAdress: ethwalletAddress,
                                ethWalletAdress: usdtWalletAddress,
                                ethNetwork: ethNetwork,
                                ethGasFee: ethGasFee,
                                balance: data['wallet'],
                                currentPackage: data['activePackage'],
                              ),
                            )
                          : AuthService().showWarningSnackBar(
                              context,
                              'Withdrawal Unavailable',
                              'Withdrawals are disabled for your current package. Please contact customer support for assistance.',
                            );
                    },
                    icon: Icon(
                      data["activePackage"] == "none"
                          ? Icons.add
                          : Icons.account_balance,
                      size: 18,
                      color:
                          data["activePackage"] == "Bronze" ||
                              data["activePackage"] == "none" ||
                              data["activePackage"] == "Californium"
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                    label: Text(
                      data["activePackage"] == "none"
                          ? "Fund Wallet"
                          : "Withdraw",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color:
                            data["activePackage"] == "none" ||
                                data["activePackage"] == "Bronze" ||
                                data["activePackage"] == "Californium"
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          LiveBTCChart(),
          const SizedBox(height: 24),
          Text(
            "Active Investment",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          // QUICK STATS - Horizontal Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Daily Growth",
                  "+\$${formatter.format(data['dailyGrowth'])}",
                  const Color(0xFF0ECB81),
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Total Earnings",
                  "\$${formatter.format(data['totalEarnings'])}",
                  Colors.white,
                  Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Active Package",
                  data['activePackage'],
                  const Color(0xFFD4A017),
                  Icons.workspace_premium_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          ///active package
          if (_pendingPackage != null) ...[
            // Activate Package Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD4A017).withOpacity(0.15),
                    const Color(0xFFD4A017).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4A017).withOpacity(0.3),
                  width: 1.5,
                ),
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
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: Color(0xFFD4A017),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ready to Activate",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${_pendingPackage!['name']} Package",
                              style: GoogleFonts.inter(
                                color: const Color(0xFFD4A017),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Package Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          "Investment Range",
                          "\$${_pendingPackage!['min']} - \$${_pendingPackage!['max']}",
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          "ROI Rate",
                          "${_pendingPackage!['roi']}%",
                          valueColor: const Color(0xFF0ECB81),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          "Duration",
                          "${_pendingPackage!['durationDays']} days",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Activate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: data['lockedActivation'] == false
                            ? const Color(0xFFD4A017)
                            : Colors.grey,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: data['lockedActivation'] == false
                          ? () async {
                              await AuthService()
                                  .activateInvestment(
                                    _pendingPackage!,
                                    context,
                                    _clearPendingPackage(),
                                  )
                                  .then((value) {
                                    setState(() {});
                                  });
                              // Clear pending package after activation
                              // await _clearPendingPackage();
                            }
                          : () {
                              AuthService().showWarningSnackBar(
                                context,
                                'Please wait for Investment to be unlocked',
                                ' You will be notified once invesment is unlocked and ready for activation! please Contact customer support if it takes Longer... ',
                              );
                            },
                      icon: data['lockedActivation'] == false
                          ? const Icon(Icons.check_circle_rounded, size: 20)
                          : Icon(Icons.warning, size: 20),
                      label: Text(
                        data['lockedActivation'] == false
                            ? "Activate ${_pendingPackage!['name']} Package"
                            : "Activation Locked",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          data['lockedActivation'] == false
              ? ActiveInvestmentCard()
              : data['activePackage'] != "none"
              ? ReactivationLockedWidget(
                  usdtWalletAddress: usdtWalletAddress,
                  packageName: activePackageData,
                  subTitle:
                      activePackageData == 'Bronze' && numberOfRoundsData >= 5
                      ? 'You have exceeded your limit on the Bronze Plan, Proceed by funding your account to upgrade your portfolio! Contact Support for more details'
                      : "You have hit the Maximum investment amount for this plan! Please pay a Kick Start Fee of \$${data['kickStartFee'] ?? ''} to continue with your investment!",
                )
              : SizedBox(),

          // // PACKAGES SECTION - Compact
          // StatefulBuilder(
          //   builder: (context, setStates) {
          //     return Column(
          //       children: [
          //         GestureDetector(
          //           onTap: () =>
          //               setStates(() => _showPackages = !_showPackages),
          //           child: Container(
          //             decoration: BoxDecoration(
          //               color: const Color(0xFF1C1C1E),
          //               borderRadius: BorderRadius.circular(12),
          //               border: Border.all(color: const Color(0xFF2C2C2E)),
          //             ),
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 20,
          //               vertical: 16,
          //             ),
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 Text(
          //                   "Investment Packages",
          //                   style: GoogleFonts.inter(
          //                     color: Colors.white,
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.w600,
          //                   ),
          //                 ),
          //                 Icon(
          //                   _showPackages
          //                       ? Icons.expand_less
          //                       : Icons.expand_more,
          //                   color: Colors.white70,
          //                   size: 24,
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),

          //         AnimatedCrossFade(
          //           firstChild: const SizedBox.shrink(),
          //           secondChild: Padding(
          //             padding: const EdgeInsets.only(top: 12),
          //             child: GridView.builder(
          //               shrinkWrap: true,
          //               physics: const NeverScrollableScrollPhysics(),
          //               itemCount: packages.length,
          //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //                 crossAxisCount: isMobile
          //                     ? 2
          //                     : (screenWidth > 1200 ? 4 : 3),
          //                 childAspectRatio: 1.15,
          //                 crossAxisSpacing: 12,
          //                 mainAxisSpacing: 12,
          //               ),
          //               itemBuilder: (context, index) {
          //                 final p = packages[index];
          //                 return Container(
          //                   padding: const EdgeInsets.all(16),
          //                   decoration: BoxDecoration(
          //                     color: const Color(0xFF1C1C1E),
          //                     borderRadius: BorderRadius.circular(12),
          //                     border: Border.all(
          //                       color: const Color(0xFF2C2C2E),
          //                     ),
          //                   ),
          //                   child: Column(
          //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                     children: [
          //                       Container(
          //                         padding: const EdgeInsets.all(10),
          //                         decoration: BoxDecoration(
          //                           color: (p["color"] as Color).withOpacity(
          //                             0.15,
          //                           ),
          //                           shape: BoxShape.circle,
          //                         ),
          //                         child: Icon(
          //                           Icons.workspace_premium_outlined,
          //                           color: p["color"],
          //                           size: 24,
          //                         ),
          //                       ),
          //                       Column(
          //                         children: [
          //                           Text(
          //                             p["name"],
          //                             style: GoogleFonts.inter(
          //                               color: Colors.white,
          //                               fontSize: 15,
          //                               fontWeight: FontWeight.w600,
          //                             ),
          //                           ),
          //                           const SizedBox(height: 3),
          //                           Text(
          //                             p["range"],
          //                             style: GoogleFonts.inter(
          //                               color: Colors.white60,
          //                               fontSize: 11,
          //                             ),
          //                           ),
          //                           const SizedBox(height: 4),
          //                           Text(
          //                             p["rate"],
          //                             style: GoogleFonts.inter(
          //                               color: const Color(0xFFD4A017),
          //                               fontSize: 12,
          //                               fontWeight: FontWeight.w600,
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                       ElevatedButton(
          //                         style: ElevatedButton.styleFrom(
          //                           backgroundColor: const Color(0xFFD4A017),
          //                           foregroundColor: Colors.black,
          //                           padding: const EdgeInsets.symmetric(
          //                             vertical: 10,
          //                           ),
          //                           shape: RoundedRectangleBorder(
          //                             borderRadius: BorderRadius.circular(8),
          //                           ),
          //                           elevation: 0,
          //                           minimumSize: const Size(
          //                             double.infinity,
          //                             36,
          //                           ),
          //                         ),
          //                         onPressed: () async {
          //                           await AuthService().activateInvestment(
          //                             investmentPackages[index],
          //                             context,
          //                           );
          //                         },
          //                         child: Text(
          //                           "Activate",
          //                           style: GoogleFonts.inter(
          //                             fontWeight: FontWeight.w600,
          //                             fontSize: 13,
          //                           ),
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 );
          //               },
          //             ),
          //           ),
          //           crossFadeState: _showPackages
          //               ? CrossFadeState.showSecond
          //               : CrossFadeState.showFirst,
          //           duration: const Duration(milliseconds: 300),
          //         ),
          //       ],
          //     );
          //   },
          // ),
          const SizedBox(height: 24),

          TransactionPage(),
        ],
      ),
    );
  }

  // 5. Helper method for detail rows (add to your State class):
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: valueColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeButton(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFD4A017).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? const Color(0xFFD4A017) : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.6), size: 20),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showLogoutDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Confirm Logout",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to log out of Pioneer Capital Limited?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF2C2C2E)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _logout();
                        },
                        child: Text(
                          "Logout",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const AuthState());
  }

  // 2. Replace your Fund Wallet button onPressed with this:
  void _showPackageSelectionDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
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
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFD4A017),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Select Investment Package",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose your preferred investment tier",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Package List
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final p = packages[index];
                    final packageData = investmentPackages[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () async {
                          // Navigator.pop(context);
                          // setState(() {
                          //   _selectedPackage = packageData;
                          // });
                          // // Show fund wallet dialog after selection
                          // showFundWalletDialog(context, usdtWalletAddress);
                          //  {'name': 'Bronze', 'min': 50, 'max': 499, 'roi': 10, 'durationDays': 1},
                          Navigator.pop(context);
                          // Show fund wallet dialog
                          showAmountInputDialog(
                            context,
                            usdtWalletAddress,
                            packageData,
                          );

                          // showFundWalletDialog(
                          //   context,
                          //   usdtWalletAddress,
                          //   packageData['min'],
                          //   packageData,
                          // );
                          // Store the selected package to Firestore
                          await _storePendingPackage(packageData);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF3C3C3E),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (p["color"] as Color).withOpacity(
                                    0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.workspace_premium_outlined,
                                  color: p["color"],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p["name"],
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p["range"],
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFD4A017,
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        p["rate"],
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFFD4A017),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white30,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white60,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SalesData {
  final String day;
  final double value;
  SalesData(this.day, this.value);
}
