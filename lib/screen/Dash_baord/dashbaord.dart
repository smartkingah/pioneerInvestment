import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/providers/model_provider.dart';
import 'package:investmentpro/screen/Auth/auth_screen.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/dashboard_analytics_metrics.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/services.dart'; // for SystemNavigator.pop()
import 'package:firebase_auth/firebase_auth.dart';

class InvestmentDashboard extends StatefulWidget {
  const InvestmentDashboard({super.key});

  @override
  State<InvestmentDashboard> createState() => _InvestmentDashboardState();
}

class _InvestmentDashboardState extends State<InvestmentDashboard> {
  bool _showPackages = false;

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

  final List<Map<String, dynamic>> transactions = [
    {
      "date": "2023-10-27",
      "type": "Deposit",
      "amount": "\$5,000",
      "status": "Completed",
    },
    {
      "date": "2023-10-26",
      "type": "Withdrawal",
      "amount": "\$800",
      "status": "Pending",
    },
    {
      "date": "2023-10-25",
      "type": "Investment",
      "amount": "\$2,000",
      "status": "Completed",
    },
  ];

  /// Confirm exit dialog when user presses back
  Future<bool> _onWillPop() async {
    bool? exitApp = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Exit App?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to exit Pioneer Capital LTD?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No", style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop(); // close the app
            },
            child: const Text("Yes", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return exitApp ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return WillPopScope(
      onWillPop: _onWillPop, // Intercept back button
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: Colors.white,
          elevation: 4,
          onPressed: () {
            showLogoutDialog();
          },
          child: const Icon(Icons.logout_outlined, color: Colors.redAccent),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        appBar: AppBar(
          automaticallyImplyLeading: false, // remove normal back button
          backgroundColor: const Color(0xFF1a1a1a),
          title: Text(
            'Pioneer Capital Limited',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        getStorage.read('photoUrl') != null &&
                            getStorage.read('photoUrl').toString().isNotEmpty
                        ? NetworkImage(getStorage.read('photoUrl'))
                        : null,
                    backgroundColor: Colors.white,
                    child:
                        (getStorage.read('photoUrl') == null ||
                            getStorage.read('photoUrl').toString().isEmpty)
                        ? const Icon(Icons.person, color: Colors.black)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    getStorage.read('fullname') ?? "John Doe",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WALLET HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Wallet",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Fund Wallet",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Total Balance: \$10,250.75",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 30),

              // PACKAGES DROPDOWN
              GestureDetector(
                onTap: () => setState(() => _showPackages = !_showPackages),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2b2b2b),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Investment Packages",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        _showPackages
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: packages.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final p = packages[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2b2b2b),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: p["color"],
                            child: const Icon(
                              Icons.workspace_premium_outlined,
                              color: Colors.white,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                p["name"],
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                p["range"],
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                p["rate"],
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFD4A017),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4A017),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Activate",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                crossFadeState: _showPackages
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 400),
              ),

              const SizedBox(height: 30),

              // ANALYTICS SECTION
              Text(
                "Dashboard Analytics",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2b2b2b),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "BTC/USD Market Trend",
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <LineSeries<SalesData, String>>[
                          LineSeries<SalesData, String>(
                            dataSource: List.generate(
                              10,
                              (index) => SalesData(
                                "Day ${index + 1}",
                                1000 + Random().nextInt(500).toDouble(),
                              ),
                            ),
                            xValueMapper: (SalesData sales, _) => sales.day,
                            yValueMapper: (SalesData sales, _) => sales.value,
                            color: const Color(0xFFD4A017),
                            width: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMetric("Daily Growth", "+\$50.12", Colors.green),
                        _buildMetric(
                          "Total Earnings",
                          "\$1,200.00",
                          Colors.white,
                        ),
                        _buildMetric(
                          "Active Package",
                          "Gold",
                          const Color(0xFFD4A017),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              DashboardAnalyticsMetrics(
                dailyGrowth: "+\$50.12",
                totalEarnings: "\$1,200.00",
                activePackage: "Gold",
              ),

              // TRANSACTIONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Transactions",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Withdraw",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2b2b2b),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: transactions.map((t) {
                    Color statusColor = t["status"] == "Completed"
                        ? Colors.green
                        : Colors.orange;
                    return ListTile(
                      title: Text(
                        t["type"],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        t["date"],
                        style: GoogleFonts.poppins(color: Colors.white54),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            t["amount"],
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            t["status"],
                            style: TextStyle(color: statusColor, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> showLogoutDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 60,
                ),
                const SizedBox(height: 15),
                Text(
                  "Confirm Logout",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to log out of Pioneer Capital Limited?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A017),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context); // close dialog first
                          await _logout();
                        },
                        child: Text(
                          "Logout",
                          style: GoogleFonts.poppins(color: Colors.black),
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
    Get.offAll(() => const AuthState()); // navigate back to login
  }
}

class SalesData {
  final String day;
  final double value;
  SalesData(this.day, this.value);
}
