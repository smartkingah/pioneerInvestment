import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_date_time/pretty_date_time.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String _selectedType = 'All';
  String _selectedTimeFilter = 'All Time';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFFD4A017),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Recent Transactions",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('transactions')
              .orderBy('timestamp', descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final transactions = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                "type": data["type"] ?? "",
                "amount": data["amount"] ?? 0.0,
                "status": data["status"] ?? "Pending",
                "packageName": data["packageName"] ?? "",
                "paymentMethod": data["paymentMethod"] ?? "",
                "timestamp": data["timestamp"],
              };
            }).toList();

            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2C2C2E),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      ...transactions.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Map<String, dynamic> t = entry.value;
                        return _buildTransactionItem(
                          t,
                          idx < transactions.length - 1,
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // See More Button
                InkWell(
                  onTap: () {
                    _showAllTransactionsDialog(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4A017).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          color: Color(0xFFD4A017),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "View All Transactions",
                          style: GoogleFonts.inter(
                            color: const Color(0xFFD4A017),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFFD4A017),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Transaction Item Widget
  Widget _buildTransactionItem(Map<String, dynamic> t, bool showDivider) {
    Color statusColor = t["status"] == "Completed"
        ? const Color(0xFF0ECB81)
        : t["status"] == "Pending"
        ? const Color(0xFFFFB020)
        : Colors.redAccent;

    IconData iconData = t["type"] == "Deposit"
        ? Icons.arrow_downward_rounded
        : t["type"] == "Withdrawal"
        ? Icons.arrow_upward_rounded
        : Icons.swap_horiz_rounded;

    String formattedDate = t["timestamp"] != null
        ? prettyDateTime((t["timestamp"] as Timestamp).toDate())
        : "--";

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      statusColor.withOpacity(0.2),
                      statusColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Icon(iconData, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t["type"],
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "\$${t["amount"]}",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            t["status"],
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (t["packageName"] != null && t["packageName"] != "") ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_outlined,
                            size: 12,
                            color: Color(0xFFD4A017),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t["packageName"],
                            style: GoogleFonts.inter(
                              color: Color(0xFFD4A017),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: const Color(0xFF2C2C2E),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4A017),
          strokeWidth: 2,
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.white38,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Show All Transactions Dialog with Filters
  void _showAllTransactionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF000000),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle Bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD4A017,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.history_rounded,
                                    color: Color(0xFFD4A017),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "All Transactions",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Color(0xFF2C2C2E), height: 1),

                      // Filter Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filters',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFilterChip(
                                    label: 'Type',
                                    value: _selectedType,
                                    icon: CupertinoIcons.arrow_up_arrow_down,
                                    onTap: () =>
                                        _showTypeFilter(context, setModalState),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFilterChip(
                                    label: 'Period',
                                    value: _selectedTimeFilter,
                                    icon: CupertinoIcons.calendar,
                                    onTap: () =>
                                        _showTimeFilter(context, setModalState),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Color(0xFF2C2C2E), height: 1),

                      // Transaction List
                      Expanded(
                        child: _buildFilteredTransactionList(scrollController),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2C2C2E), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFD4A017), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              color: Colors.white54,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeFilter(BuildContext context, StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Type',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...['All', 'Deposit', 'withdrawal', 'Investment'].map((type) {
                return _buildFilterOption(type, _selectedType == type, () {
                  setModalState(() {
                    _selectedType = type;
                  });
                  setState(() {
                    _selectedType = type;
                  });
                  Navigator.pop(context);
                });
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showTimeFilter(BuildContext context, StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time Period',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...[
                'All Time',
                'Today',
                'This Week',
                'This Month',
                'Last 30 Days',
                'Last 90 Days',
              ].map((period) {
                return _buildFilterOption(
                  period,
                  _selectedTimeFilter == period,
                  () {
                    setModalState(() {
                      _selectedTimeFilter = period;
                    });
                    setState(() {
                      _selectedTimeFilter = period;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4A017).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4A017) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: isSelected ? const Color(0xFFD4A017) : Colors.white70,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: Color(0xFFD4A017),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredTransactionList(ScrollController scrollController) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4A017)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        var allTransactions = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "type": data["type"] ?? "",
            "amount": data["amount"] ?? 0.0,
            "status": data["status"] ?? "Pending",
            "packageName": data["packageName"] ?? "",
            "paymentMethod": data["paymentMethod"] ?? "",
            "timestamp": data["timestamp"],
          };
        }).toList();

        // Apply Type Filter
        if (_selectedType != 'All') {
          allTransactions = allTransactions
              .where((t) => t['type'] == _selectedType)
              .toList();
        }

        // Apply Time Filter
        allTransactions = _filterByTime(allTransactions);

        if (allTransactions.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: allTransactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final t = allTransactions[index];
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2C2C2E)),
              ),
              child: _buildTransactionItem(t, false),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterByTime(
    List<Map<String, dynamic>> transactions,
  ) {
    final now = DateTime.now();

    switch (_selectedTimeFilter) {
      case 'Today':
        return transactions.where((t) {
          final timestamp = (t['timestamp'] as Timestamp?)?.toDate();
          if (timestamp == null) return false;
          return timestamp.year == now.year &&
              timestamp.month == now.month &&
              timestamp.day == now.day;
        }).toList();

      case 'This Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return transactions.where((t) {
          final timestamp = (t['timestamp'] as Timestamp?)?.toDate();
          if (timestamp == null) return false;
          return timestamp.isAfter(weekAgo);
        }).toList();

      case 'This Month':
        return transactions.where((t) {
          final timestamp = (t['timestamp'] as Timestamp?)?.toDate();
          if (timestamp == null) return false;
          return timestamp.year == now.year && timestamp.month == now.month;
        }).toList();

      case 'Last 30 Days':
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        return transactions.where((t) {
          final timestamp = (t['timestamp'] as Timestamp?)?.toDate();
          if (timestamp == null) return false;
          return timestamp.isAfter(thirtyDaysAgo);
        }).toList();

      case 'Last 90 Days':
        final ninetyDaysAgo = now.subtract(const Duration(days: 90));
        return transactions.where((t) {
          final timestamp = (t['timestamp'] as Timestamp?)?.toDate();
          if (timestamp == null) return false;
          return timestamp.isAfter(ninetyDaysAgo);
        }).toList();

      default:
        return transactions;
    }
  }
}
