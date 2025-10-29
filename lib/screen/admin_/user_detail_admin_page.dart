import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/screen/admin_/fab_suspendaccount.dart';
import 'package:investmentpro/screen/admin_/transaction_history_section.dart';

class UserDetailAdminPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userId;
  const UserDetailAdminPage({
    required this.userId,
    super.key,
    required this.userData,
  });

  @override
  State<UserDetailAdminPage> createState() => _UserDetailAdminPageState();
}

class _UserDetailAdminPageState extends State<UserDetailAdminPage> {
  bool _isUpdating = false;
  bool _isUserInfoExpanded = true;
  final TextEditingController _fundController = TextEditingController();
  String? _selectedPackage;

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
      'durationDays': 10,
      "kickStartFee": 10000,
    },
    {
      'name': 'Executive',
      'min': 500000,
      'max': 1000000,
      'roi': 70,
      'durationDays': 60,
      "kickStartFee": 50000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPackage = widget.userData['activePackage'] != 'none'
        ? widget.userData['activePackage']
        : null;
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    Color? confirmColor,
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
                        backgroundColor:
                            confirmColor ?? const Color(0xFFD4A017),
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

  Future<void> _updateWallet() async {
    if (_fundController.text.isEmpty) {
      AuthService().showErrorSnackBar(
        context: context,
        title: 'Error',
        subTitle: 'Please enter an amount',
      );
      return;
    }

    final amount = double.tryParse(_fundController.text) ?? 0;
    if (amount <= 0) {
      AuthService().showErrorSnackBar(
        context: context,
        title: 'Error',
        subTitle: 'Please enter a valid amount',
      );
      return;
    }

    _showConfirmationDialog(
      title: 'Update Wallet Balance',
      message:
          'Are you sure you want to update \$${amount.toStringAsFixed(2)} to ${widget.userData['fullname']}\'s wallet?',
      onConfirm: () async {
        try {
          setState(() => _isUpdating = true);
          final userId = widget.userId;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'wallet': amount});

          setState(() {
            widget.userData['wallet'] =
                (widget.userData['wallet'] ?? 0) + amount;
          });
          AuthService().showSuccessSnackBar(
            context: context,
            title: 'Success',
            subTitle: 'Wallet updated successfully',
          );

          _fundController.clear();
          Navigator.pop(context);
        } catch (e) {
          AuthService().showErrorSnackBar(
            context: context,
            title: 'Error',
            subTitle: 'Failed to update wallet: $e',
          );
        } finally {
          setState(() => _isUpdating = false);
        }
      },
    );
  }

  Future<void> _toggleAccountLock(bool currentStatus) async {
    _showConfirmationDialog(
      title: currentStatus ? 'Lock Account' : 'Unlock Account',
      message:
          'Are you sure you want to ${currentStatus ? 'lock' : 'unlock'} ${widget.userData['fullname']}\'s account?',
      confirmColor: currentStatus ? Colors.red : const Color(0xFF0ECB81),
      onConfirm: () async {
        try {
          setState(() => _isUpdating = true);
          final userId = widget.userId;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'lockedActivation': currentStatus});

          setState(() {
            widget.userData['lockedActivation'] = currentStatus;
          });

          AuthService().showSuccessSnackBar(
            context: context,
            title: 'Success',
            subTitle:
                'Account ${currentStatus ? 'locked' : 'unlocked'} successfully',
          );
        } catch (e) {
          AuthService().showErrorSnackBar(
            context: context,
            title: 'Error',
            subTitle: 'Failed to update account status: $e',
          );
        } finally {
          setState(() => _isUpdating = false);
        }
      },
    );
  }

  Future<void> _updatePackage() async {
    if (_selectedPackage == null) {
      AuthService().showErrorSnackBar(
        context: context,
        title: 'Error',
        subTitle: 'Please select a package',
      );
      return;
    }

    final package = investmentPackages.firstWhere(
      (p) => p['name'] == _selectedPackage,
    );

    _showConfirmationDialog(
      title: 'Switch Package',
      message:
          'Switch ${widget.userData['fullname']} to ${package['name']} package?',
      onConfirm: () async {
        try {
          setState(() => _isUpdating = true);
          final userId = widget.userId;

          final double packageRoi =
              double.tryParse(package['roi']?.toString() ?? '0') ?? 0.0;
          final double roi = packageRoi / 100;

          final int duration =
              int.tryParse(package['durationDays']?.toString() ?? '1') ?? 1;
          final double packageMin =
              double.tryParse(package['min']?.toString() ?? '0') ?? 0.0;
          final double investAmount = packageMin;
          final double dailyGrowth = (investAmount * roi) / duration;
          final DateTime nextPayout = DateTime.now().add(
            Duration(days: duration),
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
                'duration': duration,
                'kickStartFee': package['kickStartFee'],
                'packageRoi': roi,
                'maxPackageLimit': package['max'],
                'activePackage': package['name'],
                'nextPayoutDate': nextPayout.toIso8601String(),
                'dailyGrowth': dailyGrowth,
                "investmentAmount": investAmount,
              });

          setState(() {
            widget.userData['activePackage'] = package['name'];
            widget.userData['duration'] = duration;
            widget.userData['kickStartFee'] = package['kickStartFee'];
            widget.userData['packageRoi'] = packageRoi;
            widget.userData['maxPackageLimit'] = package['max'];
          });

          AuthService().showSuccessSnackBar(
            context: context,
            title: 'Success',
            subTitle: 'Package updated successfully',
          );
        } catch (e) {
          AuthService().showErrorSnackBar(
            context: context,
            title: 'Error',
            subTitle: 'Failed to update package: $e',
          );
        } finally {
          setState(() => _isUpdating = false);
        }
      },
    );
  }

  Future<void> _deleteWithdrawalRequest(int index) async {
    final request =
        (widget.userData['withdrawalRequest'] as List)[index] as Map;

    _showConfirmationDialog(
      title: 'Delete Withdrawal Request',
      message: 'Delete withdrawal request for \$${request['amount']}?',
      confirmColor: Colors.red,
      onConfirm: () async {
        try {
          setState(() => _isUpdating = true);
          final userId = widget.userId;
          final List withdrawalRequests = List.from(
            widget.userData['withdrawalRequest'] ?? [],
          );

          withdrawalRequests.removeAt(index);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'withdrawalRequest': withdrawalRequests});

          setState(() {
            widget.userData['withdrawalRequest'] = withdrawalRequests;
          });
          AuthService().showSuccessSnackBar(
            context: context,
            title: 'Success',
            subTitle: 'Withdrawal request deleted',
          );
        } catch (e) {
          AuthService().showErrorSnackBar(
            context: context,
            title: 'Error',
            subTitle: 'Failed to delete request: $e',
          );
        } finally {
          setState(() => _isUpdating = false);
        }
      },
    );
  }

  Future<void> _deletePendingRequest() async {
    final request = widget.userData['pendingPackage'] as Map?;

    if (request == null || request.isEmpty) {
      AuthService().showErrorSnackBar(
        context: context,
        title: 'No Pending Package',
        subTitle: 'There is no pending package to delete.',
      );
      return;
    }

    _showConfirmationDialog(
      title: 'Delete Pending Package Request',
      message:
          'Are you sure you want to delete the pending package "${request['name']}"?',
      confirmColor: Colors.red,
      onConfirm: () async {
        try {
          setState(() => _isUpdating = true);

          final userId = widget.userId;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'pendingPackage': FieldValue.delete()});

          setState(() {
            widget.userData['pendingPackage'] = null;
          });

          AuthService().showSuccessSnackBar(
            context: context,
            title: 'Success',
            subTitle: 'Pending package request deleted successfully.',
          );
        } catch (e) {
          AuthService().showErrorSnackBar(
            context: context,
            title: 'Error',
            subTitle: 'Failed to delete pending package: $e',
          );
        } finally {
          setState(() => _isUpdating = false);
        }
      },
    );
  }

  Future<void> _showEditUserInfoDialog() async {
    final fullnameController = TextEditingController(
      text: widget.userData['fullname'],
    );
    final emailController = TextEditingController(
      text: widget.userData['email'],
    );
    final phoneController = TextEditingController(
      text: widget.userData['phone'],
    );
    final addressController = TextEditingController(
      text: widget.userData['address'],
    );
    final countryController = TextEditingController(
      text: widget.userData['country'],
    );
    final totalEarningsController = TextEditingController(
      text: (widget.userData['totalEarnings'] ?? 0).toString(),
    );
    final investmentAmountController = TextEditingController(
      text: (widget.userData['investmentAmount'] ?? 0).toString(),
    );
    final kickStartFeeController = TextEditingController(
      text: (widget.userData['kickStartFee'] ?? 0).toString(),
    );
    final numberOfRoundsController = TextEditingController(
      text: (widget.userData['numberOfRounds'] ?? 0).toString(),
    );

    DateTime? selectedJoinedDate = widget.userData['createdAt'] != null
        ? (widget.userData['createdAt'] is Timestamp
              ? widget.userData['createdAt'].toDate()
              : DateTime.tryParse(widget.userData['createdAt'].toString()))
        : null;

    DateTime? selectedNextPayoutDate = widget.userData['nextPayoutDate'] != null
        ? (widget.userData['nextPayoutDate'] is Timestamp
              ? widget.userData['nextPayoutDate'].toDate()
              : DateTime.tryParse(widget.userData['nextPayoutDate'].toString()))
        : null;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A017).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            CupertinoIcons.pencil,
                            color: Color(0xFFD4A017),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Edit User Information',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            CupertinoIcons.xmark,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildEditField(
                      'Full Name',
                      fullnameController,
                      CupertinoIcons.person,
                    ),
                    const SizedBox(height: 14),
                    _buildEditField(
                      'Email',
                      emailController,
                      CupertinoIcons.mail,
                    ),
                    const SizedBox(height: 14),
                    _buildEditField(
                      'Phone',
                      phoneController,
                      CupertinoIcons.phone,
                    ),
                    const SizedBox(height: 14),
                    _buildEditField(
                      'Address',
                      addressController,
                      CupertinoIcons.location,
                    ),
                    const SizedBox(height: 14),
                    _buildEditField(
                      'Country',
                      countryController,
                      CupertinoIcons.flag,
                    ),
                    const SizedBox(height: 14),
                    _buildEditField(
                      'Total Earnings',
                      totalEarningsController,
                      CupertinoIcons.money_dollar,
                      isNumber: true,
                    ),
                    const SizedBox(height: 14),
                    _buildEditField(
                      'Investment Amount',
                      investmentAmountController,
                      CupertinoIcons.chart_bar,
                      isNumber: true,
                    ),
                    const SizedBox(height: 14),
                    _buildEditField(
                      'Kickstart Fee',
                      kickStartFeeController,
                      CupertinoIcons.flame,
                      isNumber: true,
                    ),
                    const SizedBox(height: 14),
                    _buildEditField(
                      'Number of Rounds',
                      numberOfRoundsController,
                      CupertinoIcons.flame,
                      isNumber: true,
                    ),
                    const SizedBox(height: 14),
                    // Joined Date Picker
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedJoinedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFD4A017),
                                  surface: Color(0xFF1A1A1A),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedJoinedDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.calendar,
                              color: Color(0xFFD4A017),
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Joined Date',
                                    style: GoogleFonts.inter(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedJoinedDate != null
                                        ? DateFormat(
                                            'MMM d, y',
                                          ).format(selectedJoinedDate!)
                                        : 'Select date',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.chevron_right,
                              color: Colors.white38,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Next Payout Date Picker
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedNextPayoutDate ?? DateTime.now(),
                          firstDate: DateTime(1999),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFD4A017),
                                  surface: Color(0xFF1A1A1A),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedNextPayoutDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.calendar_today,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Next Payout Date',
                                    style: GoogleFonts.inter(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedNextPayoutDate != null
                                        ? DateFormat(
                                            'MMM d, y',
                                          ).format(selectedNextPayoutDate!)
                                        : 'Select date',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.chevron_right,
                              color: Colors.white38,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
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
                            onPressed: () async {
                              Navigator.pop(context);
                              await _updateUserInformation(
                                fullnameController.text,
                                emailController.text,
                                phoneController.text,
                                addressController.text,
                                countryController.text,
                                totalEarningsController.text,
                                investmentAmountController.text,
                                kickStartFeeController.text,
                                numberOfRoundsController.text,
                                selectedJoinedDate,
                                selectedNextPayoutDate,
                              );
                              // setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFFD4A017),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Update',
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFFD4A017), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Future<void> _updateUserInformation(
    String fullname,
    String email,
    String phone,
    String address,
    String country,
    String totalEarnings,
    String investmentAmount,
    String kickStartFee,
    String numberOfRounds,
    DateTime? joinedDate,
    DateTime? nextPayoutDate,
  ) async {
    _showConfirmationDialog(
      title: 'Update User Information',
      message: 'Are you sure you want to update this user\'s information?',
      onConfirm: () async {
        try {
          setState(() => _isUpdating = true);

          final updateData = <String, dynamic>{
            'fullname': fullname,
            'email': email,
            'phone': phone,
            'address': address,
            'country': country,
            'totalEarnings': double.tryParse(totalEarnings) ?? 0,
            'investmentAmount': double.tryParse(investmentAmount) ?? 0,
            'kickStartFee': double.tryParse(kickStartFee) ?? 0,
            'numberOfRounds': double.tryParse(numberOfRounds) ?? 0,
          };

          if (joinedDate != null) {
            updateData['createdAt'] = Timestamp.fromDate(joinedDate);
          }

          if (nextPayoutDate != null) {
            updateData['nextPayoutDate'] = nextPayoutDate.toIso8601String();
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .update(updateData);

          setState(() {
            widget.userData['fullname'] = fullname;
            widget.userData['email'] = email;
            widget.userData['phone'] = phone;
            widget.userData['address'] = address;
            widget.userData['country'] = country;
            widget.userData['totalEarnings'] =
                double.tryParse(totalEarnings) ?? 0;
            widget.userData['investmentAmount'] =
                double.tryParse(investmentAmount) ?? 0;
            widget.userData['kickStartFee'] =
                double.tryParse(kickStartFee) ?? 0;
            widget.userData['numberOfRounds'] =
                double.tryParse(numberOfRounds) ?? 0;
            if (joinedDate != null) {
              widget.userData['createdAt'] = Timestamp.fromDate(joinedDate);
            }
            if (nextPayoutDate != null) {
              widget.userData['nextPayoutDate'] = nextPayoutDate
                  .toIso8601String();
            }
          });

          AuthService().showSuccessSnackBar(
            context: context,
            title: 'Success',
            subTitle: 'User information updated successfully',
          );
          Navigator.pop(context);
        } catch (e) {
          AuthService().showErrorSnackBar(
            context: context,
            title: 'Error',
            subTitle: 'Failed to update user information: $e',
          );
        } finally {
          setState(() => _isUpdating = false);
        }
      },
    );
  }

  String _formatDateTime(dynamic timestamp) {
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

  Color _getPackageColor(String packageName) {
    switch (packageName.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'californium':
        return const Color(0xFF00CED1);
      case 'executive':
        return const Color(0xFF9400D3);
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;
    final bool isLocked = user['lockedActivation'] ?? false;
    final formatter = NumberFormat("#,##0.00", "en_US");

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
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
              CupertinoIcons.back,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Management',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header with Glassmorphism Effect
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFD4A017).withOpacity(0.15),
                        const Color(0xFF1A1A1A).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFD4A017).withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4A017).withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  isLocked
                                      ? Colors.red
                                      : const Color(0xFF0ECB81),
                                  isLocked
                                      ? Colors.red.shade900
                                      : const Color(
                                          0xFF0ECB81,
                                        ).withOpacity(0.6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isLocked
                                              ? Colors.red
                                              : const Color(0xFF0ECB81))
                                          .withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: const Color(0xFF0A0A0A),
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                  backgroundImage: user['photoUrl'] != null
                                      ? NetworkImage(user['photoUrl'])
                                      : null,
                                  child: user['photoUrl'] == null
                                      ? const Icon(
                                          CupertinoIcons.person_fill,
                                          color: Colors.white38,
                                          size: 40,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isLocked
                                    ? Colors.red
                                    : const Color(0xFF0ECB81),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0A0A0A),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isLocked
                                                ? Colors.red
                                                : const Color(0xFF0ECB81))
                                            .withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isLocked
                                    ? CupertinoIcons.lock_fill
                                    : CupertinoIcons.checkmark_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user['fullname'] ?? 'N/A',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user['email'] ?? 'N/A',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Lock Toggle - More Modern
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (isLocked ? Colors.red : const Color(0xFF0ECB81))
                                  .withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                (isLocked
                                        ? Colors.red
                                        : const Color(0xFF0ECB81))
                                    .withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (isLocked
                                            ? Colors.red
                                            : const Color(0xFF0ECB81))
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isLocked
                                                ? Colors.red
                                                : const Color(0xFF0ECB81))
                                            .withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isLocked
                                    ? CupertinoIcons.lock_shield_fill
                                    : CupertinoIcons.lock_shield,
                                color: isLocked
                                    ? Colors.red
                                    : const Color(0xFF0ECB81),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Status',
                                    style: GoogleFonts.inter(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isLocked ? 'Locked' : 'Active',
                                    style: GoogleFonts.inter(
                                      color: isLocked
                                          ? Colors.red
                                          : const Color(0xFF0ECB81),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Transform.scale(
                              scale: 0.9,
                              child: CupertinoSwitch(
                                value: !isLocked,
                                activeColor: const Color(0xFF0ECB81),
                                onChanged: (value) =>
                                    _toggleAccountLock(!value),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Wallet Section - Enhanced
                      _buildSectionHeader(
                        'Wallet Management',
                        CupertinoIcons.creditcard_fill,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFD4A017).withOpacity(0.2),
                              const Color(0xFFD4A017).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD4A017).withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4A017).withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 2,
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
                                    color: const Color(
                                      0xFFD4A017,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.money_dollar_circle_fill,
                                    color: Color(0xFFD4A017),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Current Balance',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '\$${formatter.format(user['wallet'] ?? 0)}',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFD4A017),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: TextField(
                                controller: _fundController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter new wallet balance',
                                  hintStyle: GoogleFonts.inter(
                                    color: Colors.white38,
                                  ),
                                  prefixIcon: const Icon(
                                    CupertinoIcons.money_dollar,
                                    color: Color(0xFFD4A017),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _updateWallet,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4A017),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.checkmark_circle_fill,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Update Wallet',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Package Management - Enhanced
                      _buildSectionHeader(
                        'Package Management',
                        CupertinoIcons.cube_box_fill,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.cube_box_fill,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Package',
                                      style: GoogleFonts.inter(
                                        color: Colors.white54,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      user['activePackage'] == 'none'
                                          ? 'No Package'
                                          : user['activePackage'] ?? 'N/A',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedPackage,
                                hint: Text(
                                  'Select new package',
                                  style: GoogleFonts.inter(
                                    color: Colors.white38,
                                    fontSize: 14,
                                  ),
                                ),
                                isExpanded: true,
                                dropdownColor: const Color(0xFF1A1A1A),
                                underline: const SizedBox(),
                                icon: const Icon(
                                  CupertinoIcons.chevron_down,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                                items: investmentPackages.map((package) {
                                  return DropdownMenuItem<String>(
                                    value: package['name'],
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: _getPackageColor(
                                              package['name'],
                                            ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            CupertinoIcons.sparkles,
                                            size: 12,
                                            color: _getPackageColor(
                                              package['name'],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                package['name'],
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                '\$${package['min']}-\$${package['max']} • ${package['roi']}% ROI',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white54,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedPackage = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _updatePackage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.arrow_2_squarepath,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Switch Package',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // User Information - Collapsible
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isUserInfoExpanded = !_isUserInfoExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.15),
                                Colors.purple.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  CupertinoIcons.person_crop_circle_fill,
                                  color: Colors.purple,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'User Information',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: _isUserInfoExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: const Icon(
                                  CupertinoIcons.chevron_down,
                                  color: Colors.purple,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () => _showEditUserInfoDialog(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFD4A017,
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFD4A017,
                                          ).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            CupertinoIcons.pencil,
                                            color: Color(0xFFD4A017),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Edit',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFFD4A017),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                icon: CupertinoIcons.person_fill,
                                label: 'Full Name',
                                value: user['fullname'] ?? 'N/A',
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                icon: CupertinoIcons.mail_solid,
                                label: 'Email',
                                value: user['email'] ?? 'N/A',
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                icon: CupertinoIcons.phone_fill,
                                label: 'Phone',
                                value: user['phone'] ?? 'N/A',
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                icon: CupertinoIcons.location_solid,
                                label: 'Address',
                                value: user['address'] ?? 'N/A',
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                icon: CupertinoIcons.location_solid,
                                label: 'Password',
                                value: user['password'] ?? 'N/A',
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                icon: CupertinoIcons.location_solid,
                                label: 'Package Duration of Days',
                                value: user['duration'].toString() ?? 'N/A',
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                icon: CupertinoIcons.flag_fill,
                                label: 'Country',
                                value: user['country'] ?? 'N/A',
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                icon: CupertinoIcons.calendar,
                                label: 'Joined',
                                value: _formatDateTime(user['createdAt']),
                              ),
                              if (user['career'] != null) ...[
                                _buildDivider(),
                                _buildInfoRow(
                                  icon: CupertinoIcons.money_dollar_circle_fill,
                                  label: 'Career',
                                  value: (user['career'] ?? '').toString(),
                                  valueColor: Colors.deepPurple,
                                ),
                              ],

                              if (user['numberOfRounds'] != null) ...[
                                _buildDivider(),
                                _buildInfoRow(
                                  icon: CupertinoIcons.money_dollar_circle_fill,
                                  label:
                                      'Nunmber of Rounds Gone Since investment',
                                  value: (user['numberOfRounds'] ?? 0)
                                      .toString(),
                                  valueColor: Colors.deepPurple,
                                ),
                              ],
                              _buildDivider(),
                              _buildInfoRow(
                                icon: CupertinoIcons.chart_bar_fill,
                                label: 'Total Earnings',
                                value:
                                    '\$${(user['totalEarnings'] ?? 0).toStringAsFixed(2)}',
                                valueColor: const Color(0xFF0ECB81),
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                icon: CupertinoIcons.money_dollar_circle_fill,
                                label: 'Investment Amount',
                                value:
                                    '\$${(user['investmentAmount'] ?? 0).toStringAsFixed(2)}',
                                valueColor: Colors.blue,
                              ),
                              if (user['usdtAddress'] != null) ...[
                                _buildDivider(),
                                _buildInfoRow(
                                  icon: CupertinoIcons.money_dollar_circle_fill,
                                  label: 'USDT Wallet Address',
                                  value: (user['usdtAddress'] ?? 0).toString(),
                                  valueColor: Colors.deepPurple,
                                ),
                              ],
                              if (user['nextPayoutDate'] != null) ...[
                                _buildDivider(),
                                _buildInfoRow(
                                  icon: CupertinoIcons.calendar_today,
                                  label: 'Next Payout',
                                  value: _formatDateTime(
                                    user['nextPayoutDate'],
                                  ),
                                  valueColor: Colors.orange,
                                ),
                              ],
                              if (user['kickStartFee'] != null &&
                                  user['kickStartFee'] > 0) ...[
                                _buildDivider(),
                                _buildInfoRow(
                                  icon: CupertinoIcons.flame_fill,
                                  label: 'Kickstart Fee',
                                  value:
                                      '\$${(user['kickStartFee'] ?? 0).toStringAsFixed(2)}',
                                  valueColor: Colors.red,
                                ),
                              ],
                            ],
                          ),
                        ),
                        crossFadeState: _isUserInfoExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),

                      const SizedBox(height: 24),

                      TransactionHistorySection(userId: widget.userId),

                      // Pending Package
                      if (user['pendingPackage'] != null) ...[
                        _buildSectionHeader(
                          'Pending Package',
                          CupertinoIcons.hourglass,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.orange.withOpacity(0.2),
                                Colors.orange.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  CupertinoIcons.hourglass,
                                  color: Colors.orange,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (user['pendingPackage'] as Map)['name'] ??
                                          'Package',
                                      style: GoogleFonts.inter(
                                        color: Colors.orange,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${(user['pendingPackage'] as Map)['min']}-\$${(user['pendingPackage'] as Map)['max']} • ${(user['pendingPackage'] as Map)['roi']}% ROI',
                                      style: GoogleFonts.inter(
                                        color: Colors.white60,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Duration: ${(user['pendingPackage'] as Map)['durationDays']} days',
                                      style: GoogleFonts.inter(
                                        color: Colors.white38,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _deletePendingRequest(),
                                icon: const Icon(
                                  CupertinoIcons.trash_fill,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.15),
                                  padding: const EdgeInsets.all(10),
                                  minimumSize: const Size(40, 40),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Withdrawal Requests
                      if (user['withdrawalRequest'] != null &&
                          (user['withdrawalRequest'] as List).isNotEmpty) ...[
                        _buildSectionHeader(
                          'Withdrawal Requests',
                          CupertinoIcons.arrow_up_right_circle_fill,
                        ),
                        const SizedBox(height: 12),
                        ...((user['withdrawalRequest'] as List)
                            .asMap()
                            .entries
                            .map((entry) {
                              final request = entry.value as Map;
                              final statusColor = request['status'] == 'pending'
                                  ? Colors.orange
                                  : request['status'] == 'approved'
                                  ? const Color(0xFF0ECB81)
                                  : Colors.red;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.arrow_up_circle_fill,
                                        color: statusColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '\$${request['amount']}',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDateTime(
                                              request['timestamp'],
                                            ),
                                            style: GoogleFonts.inter(
                                              color: Colors.white54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(
                                                0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: statusColor.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              request['status']
                                                  .toString()
                                                  .toUpperCase(),
                                              style: GoogleFonts.inter(
                                                color: statusColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _deleteWithdrawalRequest(entry.key),
                                      icon: const Icon(
                                        CupertinoIcons.trash_fill,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red.withOpacity(
                                          0.15,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        minimumSize: const Size(40, 40),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isUpdating)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1A1A1A),
                        const Color(0xFF1A1A1A).withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFD4A017).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4A017).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD4A017),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Processing...',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: ModernFAB(
        onPressed: () => _showActionSheet(context),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    final bool isCurrentlySuspended = widget.userData['suspended'] ?? false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1F1F1F), const Color(0xFF151515)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Account Actions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Suspend/Unsuspend Option
                _buildActionTile(
                  context: context,
                  icon: isCurrentlySuspended
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  iconColor: const Color(0xFFFFD400),
                  backgroundColor: const Color(0xFFFFD400).withOpacity(0.12),
                  title: isCurrentlySuspended
                      ? 'Unsuspend Account'
                      : 'Suspend Account',
                  subtitle: isCurrentlySuspended
                      ? 'Restore account access'
                      : 'Temporarily disable account',
                  onTap: () {
                    Navigator.pop(context);
                    _showSuspendConfirmationDialog(isCurrentlySuspended);
                  },
                ),

                const SizedBox(height: 12),

                // Delete Option
                _buildActionTile(
                  context: context,
                  icon: Icons.delete_forever_rounded,
                  iconColor: const Color(0xFFFF4444),
                  backgroundColor: const Color(0xFFFF4444).withOpacity(0.12),
                  title: 'Delete Account',
                  subtitle: 'Permanently remove account',
                  onTap: () {
                    Navigator.pop(context);
                    // _showDeleteConfirmationDialog();
                  },
                  isDestructive: true,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: iconColor.withOpacity(0.1),
          highlightColor: iconColor.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),

                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDestructive
                              ? const Color(0xFFFF4444)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuspendConfirmationDialog(bool isCurrentlySuspended) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF1F1F1F), const Color(0xFF151515)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),

                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color:
                        (isCurrentlySuspended
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFFD400))
                            .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCurrentlySuspended
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    color: isCurrentlySuspended
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFFD400),
                    size: 36,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    isCurrentlySuspended
                        ? 'Unsuspend Account?'
                        : 'Suspend Account?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    isCurrentlySuspended
                        ? 'The user will regain full access to their account and all its features.'
                        : 'The user will lose access to their account until it is unsuspended.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                // Divider
                Container(height: 1, color: Colors.white.withOpacity(0.08)),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: _buildDialogButton(
                          label: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                          isPrimary: false,
                          color: Colors.grey[700]!,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Confirm Button
                      Expanded(
                        child: _buildDialogButton(
                          label: isCurrentlySuspended ? 'Unsuspend' : 'Suspend',
                          onPressed: () {
                            Navigator.pop(context);
                            _updateSuspendStatus(!isCurrentlySuspended);
                          },
                          isPrimary: true,
                          color: isCurrentlySuspended
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFFD400),
                        ),
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

  Widget _buildDialogButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: isPrimary ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          ),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? (color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white)
                    : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateSuspendStatus(bool suspend) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'suspended': suspend});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              suspend
                  ? 'Account has been suspended'
                  : 'Account has been unsuspended',
            ),
            backgroundColor: suspend ? Colors.orange : Colors.green,
          ),
        );
        // Optionally navigate back to the admin page
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AuthService().showErrorSnackBar(
          context: context,
          title: 'Error',
          subTitle: 'Error updating account status: $e',
        );
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD4A017).withOpacity(0.2),
                const Color(0xFFD4A017).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFD4A017), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.white54),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: GoogleFonts.inter(
                    color: valueColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  // overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fundController.dispose();
    super.dispose();
  }
}
