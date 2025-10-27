import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/screen/admin_/user_detail_admin_page.dart';

class TransactionHistorySection extends StatefulWidget {
  final String userId;
  const TransactionHistorySection({required this.userId, super.key});

  @override
  State<TransactionHistorySection> createState() =>
      _TransactionHistorySectionState();
}

class _TransactionHistorySectionState extends State<TransactionHistorySection> {
  bool _isUpdating = false;
  bool _showAll = false;

  Future<void> _updateTransactionStatus(
    String transactionId,
    String newStatus,
  ) async {
    showConfirmationDialog(
      context: context,
      title: 'Update Transaction Status',
      message: 'Change transaction status to $newStatus?',
      confirmColor: newStatus == 'Completed'
          ? const Color(0xFF0ECB81)
          : Colors.orange,
      onConfirm: () async {
        try {
          setState(() => _isUpdating = true);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('transactions')
              .doc(transactionId)
              .update({'status': newStatus});

          AuthService().showSuccessSnackBar(
            context: context,
            title: 'Success',
            subTitle: 'Transaction status updated successfully',
          );
        } catch (e) {
          AuthService().showErrorSnackBar(
            context: context,
            title: 'Error',
            subTitle: 'Failed to update status: $e',
          );
        } finally {
          setState(() => _isUpdating = false);
        }
      },
    );
  }

  String _formatAmount(dynamic amount) {
    try {
      double parsedAmount;
      if (amount is String) {
        // Remove any commas or currency symbols
        String cleanAmount = amount.replaceAll(RegExp(r'[^\d.]'), '');
        parsedAmount = double.tryParse(cleanAmount) ?? 0.0;
      } else if (amount is num) {
        parsedAmount = amount.toDouble();
      } else {
        parsedAmount = 0.0;
      }
      final formatter = NumberFormat("#,##0.00", "en_US");
      return formatter.format(parsedAmount);
    } catch (e) {
      return '0.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Column(
      children: [
        // Transactions Section Header
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.arrow_right_arrow_left_circle_fill,
                  color: const Color(0xFFD4A017),
                  size: isSmallScreen ? 20 : 22,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transactions',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 15 : 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage transactions',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('transactions')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4A017),
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.tray,
                        color: Colors.white38,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Transactions',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Transactions will appear here',
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final allTransactions = snapshot.data!.docs;
            final displayedTransactions = _showAll
                ? allTransactions
                : allTransactions.take(3).toList();

            return Column(
              children: [
                ...displayedTransactions.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final type = data['type'] ?? 'Unknown';
                  final amount = data['amount'];
                  final status = data['status'] ?? 'Pending';
                  final timestamp = data['timestamp'];

                  final statusColor = status == 'Completed'
                      ? const Color(0xFF0ECB81)
                      : Colors.orange;

                  final isDeposit = type.toLowerCase() == 'deposit';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                  isSmallScreen ? 10 : 12,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isDeposit
                                      ? CupertinoIcons.arrow_down_circle_fill
                                      : CupertinoIcons.arrow_up_circle_fill,
                                  color: statusColor,
                                  size: isSmallScreen ? 20 : 22,
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 10 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            type.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: isSmallScreen ? 13 : 14,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: statusColor.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              color: statusColor,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.clock,
                                          size: 11,
                                          color: Colors.white38,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            formatDateTime(timestamp),
                                            style: GoogleFonts.inter(
                                              color: Colors.white54,
                                              fontSize: isSmallScreen ? 10 : 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: statusColor.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '\$${_formatAmount(amount)}',
                                        style: GoogleFonts.inter(
                                          color: statusColor,
                                          fontSize: isSmallScreen ? 15 : 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.05),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateTransactionStatus(
                                    doc.id,
                                    'Pending',
                                  ),
                                  icon: Icon(
                                    CupertinoIcons.clock_fill,
                                    size: isSmallScreen ? 14 : 15,
                                  ),
                                  label: Text(
                                    'Pending',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: isSmallScreen ? 11 : 12,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.withOpacity(
                                      0.1,
                                    ),
                                    foregroundColor: Colors.orange,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmallScreen ? 10 : 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: Colors.orange.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateTransactionStatus(
                                    doc.id,
                                    'Completed',
                                  ),
                                  icon: Icon(
                                    CupertinoIcons.checkmark_circle_fill,
                                    size: isSmallScreen ? 14 : 15,
                                  ),
                                  label: Text(
                                    'Complete',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: isSmallScreen ? 11 : 12,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF0ECB81,
                                    ).withOpacity(0.1),
                                    foregroundColor: const Color(0xFF0ECB81),
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmallScreen ? 10 : 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: const Color(
                                          0xFF0ECB81,
                                        ).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                // Show More/Less Button
                if (allTransactions.length > 3) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showAll = !_showAll;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
                        vertical: isSmallScreen ? 12 : 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4A017).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showAll
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                            color: const Color(0xFFD4A017),
                            size: isSmallScreen ? 16 : 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showAll
                                ? 'Show Less'
                                : 'Show All (${allTransactions.length})',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFD4A017),
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

String formatDateTime(dynamic timestamp) {
  if (timestamp == null) return 'N/A';
  try {
    final date = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.parse(timestamp.toString());
    return DateFormat('MMM d, y • h:mm a').format(date);
  } catch (e) {
    return 'N/A';
  }
}

Future<void> showConfirmationDialog({
  required String title,
  required String message,
  required VoidCallback onConfirm,
  Color? confirmColor,
  required BuildContext context,
}) async {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (confirmColor ?? const Color(0xFFD4A017)).withOpacity(
                  0.15,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: confirmColor ?? const Color(0xFFD4A017),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: confirmColor ?? const Color(0xFFD4A017),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
