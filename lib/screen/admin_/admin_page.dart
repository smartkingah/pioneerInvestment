import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:investmentpro/screen/admin_/custom_app_bar.dart';
import 'package:investmentpro/screen/admin_/referal_tab.dart';
import 'package:investmentpro/screen/admin_/user_detail_admin_page.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _getLastSeenText(dynamic lastSeen, String? status) {
    if (status == 'online') return 'Online now';
    if (lastSeen == null) return 'Never';

    final lastSeenDate = lastSeen is Timestamp
        ? lastSeen.toDate()
        : DateTime.parse(lastSeen.toString());
    final now = DateTime.now();
    final difference = now.difference(lastSeenDate);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d').format(lastSeenDate);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile
                ? 16
                : (screenWidth > 1200 ? screenWidth * 0.2 : 32),
            vertical: 20,
          ),
          child: Column(
            children: [
              CustomAppBar(),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        color: Colors.white38,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                CupertinoIcons.clear_circled_solid,
                                color: Colors.white38,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFD4A017),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'All Users'),
                    Tab(text: 'Pending Deposits'),
                    Tab(text: 'Pending Withdrawals'),
                    Tab(text: 'Referals'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllUsersTab(),
                    _buildPendingPackagesTab(),
                    _buildWithdrawalRequestsTab(),
                    ReferralTreeTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('fullname', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.person_2,
            message: 'No users found',
          );
        }

        var users = snapshot.data!.docs;

        if (_searchQuery.isNotEmpty) {
          users = users.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['fullname'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) || email.contains(_searchQuery);
          }).toList();
        }

        if (users.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.search,
            message: 'No users match your search',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            String userId = users[index].id;
            final userData = users[index].data() as Map<String, dynamic>;
            return _buildUserCard(userData, userId);
          },
        );
      },
    );
  }

  Widget _buildPendingPackagesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('pendingPackage', isNull: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.hourglass,
            message: 'No pending packages',
          );
        }

        var users = snapshot.data!.docs;

        if (_searchQuery.isNotEmpty) {
          users = users.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['fullname'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) || email.contains(_searchQuery);
          }).toList();
        }

        if (users.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.search,
            message: 'No users match your search',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            String userId = users[index].id;
            final userData = users[index].data() as Map<String, dynamic>;
            return _buildUserCard(userData, userId, highlightPending: true);
          },
        );
      },
    );
  }

  Widget _buildWithdrawalRequestsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.arrow_up_circle,
            message: 'No withdrawal requests',
          );
        }

        var users = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final withdrawalRequests = data['withdrawalRequest'] as List?;
          return withdrawalRequests != null && withdrawalRequests.isNotEmpty;
        }).toList();

        if (_searchQuery.isNotEmpty) {
          users = users.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['fullname'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) || email.contains(_searchQuery);
          }).toList();
        }

        if (users.isEmpty) {
          return _buildEmptyState(
            icon: _searchQuery.isNotEmpty
                ? CupertinoIcons.search
                : CupertinoIcons.arrow_up_circle,
            message: _searchQuery.isNotEmpty
                ? 'No users match your search'
                : 'No withdrawal requests',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            String userId = users[index].id;
            final userData = users[index].data() as Map<String, dynamic>;
            return _buildUserCard(userData, userId, highlightWithdrawal: true);
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFD4A017).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A017)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.white38),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    Map<String, dynamic> user,
    userId, {
    bool highlightPending = false,
    bool highlightWithdrawal = false,
  }) {
    final name = user['fullname'] ?? 'Unnamed User';
    final email = user['email'] ?? 'No Email';
    final wallet = user['wallet'] ?? 0.0;
    final photoUrl = user['photoUrl'];
    final isActive = user['lockedActivation'] == false;
    final isSuspended = user['suspended'] ?? false;
    final status = user['status'] ?? 'offline';
    final lastSeen = user['lastSeen'];
    final pendingPackage = user['pendingPackage'] as Map<String, dynamic>?;
    final withdrawalRequests = user['withdrawalRequest'] as List?;
    final nextPayoutDateRaw = user['nextPayoutDate'];
    DateTime? nextPayoutDate;
    if (nextPayoutDateRaw != null) {
      if (nextPayoutDateRaw is Timestamp) {
        nextPayoutDate = nextPayoutDateRaw.toDate();
      } else if (nextPayoutDateRaw is String) {
        try {
          nextPayoutDate = DateTime.parse(nextPayoutDateRaw);
        } catch (e) {
          nextPayoutDate = null;
        }
      }
    }

    final formatter = NumberFormat("#,##0.00", "en_US");

    return GestureDetector(
      onTap: () =>
          Get.to(() => UserDetailAdminPage(userData: user, userId: userId)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSuspended
                ? Colors.orange.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: isSuspended ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSuspended
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.black.withOpacity(0.2),
              blurRadius: isSuspended ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Suspended Banner (if suspended)
            if (isSuspended) ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.withOpacity(0.2),
                      Colors.orange.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.lock_fill,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Suspended',
                            style: GoogleFonts.inter(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'User cannot access their account',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SUSPENDED',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Header
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSuspended
                              ? Colors.orange
                              : (isActive
                                    ? const Color(0xFF0ECB81)
                                    : Colors.red),
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null
                            ? const Icon(
                                CupertinoIcons.person_fill,
                                color: Colors.white38,
                                size: 28,
                              )
                            : null,
                      ),
                    ),
                    if (status == 'online' && !isSuspended)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0ECB81),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1A1A1A),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isSuspended)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF0ECB81).withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xFF0ECB81)
                                      : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFF0ECB81)
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isActive ? 'Active' : 'Locked',
                                    style: GoogleFonts.inter(
                                      color: isActive
                                          ? const Color(0xFF0ECB81)
                                          : Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            status == 'online'
                                ? CupertinoIcons.circle_fill
                                : CupertinoIcons.clock,
                            size: 12,
                            color: status == 'online'
                                ? const Color(0xFF0ECB81)
                                : Colors.white38,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getLastSeenText(lastSeen, status),
                            style: GoogleFonts.inter(
                              color: status == 'online'
                                  ? const Color(0xFF0ECB81)
                                  : Colors.white38,
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

            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 20),

            // Pending Package Alert
            if (pendingPackage != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.withOpacity(0.15),
                      Colors.blue.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.hourglass,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending: ${pendingPackage['name'] ?? 'Package'}',
                            style: GoogleFonts.inter(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '\$${pendingPackage['min']}-\$${pendingPackage['max']} • ${pendingPackage['roi']}% ROI',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Withdrawal Request Alert
            if (withdrawalRequests != null &&
                withdrawalRequests.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.15),
                      Colors.purple.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.arrow_up_circle_fill,
                        color: Colors.purple,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${withdrawalRequests.length} Withdrawal Request${withdrawalRequests.length > 1 ? 's' : ''}',
                            style: GoogleFonts.inter(
                              color: Colors.purple,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Latest: \$${withdrawalRequests.last['amount']} • ${withdrawalRequests.last['status']}',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
