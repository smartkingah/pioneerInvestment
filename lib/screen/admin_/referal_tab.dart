import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReferralTreeTab extends StatefulWidget {
  const ReferralTreeTab({super.key, this.searchQuery = ''});

  final String searchQuery;

  @override
  State<ReferralTreeTab> createState() => _ReferralTreeTabState();
}

class _ReferralTreeTabState extends State<ReferralTreeTab> {
  String _sortBy = 'most'; // 'most' or 'recent'

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sort Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Sort by:',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSortButton('Most Referrals', 'most'),
                      ),
                      Expanded(
                        child: _buildSortButton('Recent Activity', 'recent'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('referrals', isNull: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIndicator();
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              var users = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final referrals = data['referrals'] as List?;
                return referrals != null && referrals.isNotEmpty;
              }).toList();

              // Apply search filter
              if (widget.searchQuery.isNotEmpty) {
                users = users.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['fullname'] ?? '')
                      .toString()
                      .toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final code = (data['referralCode'] ?? '')
                      .toString()
                      .toLowerCase();
                  return name.contains(widget.searchQuery.toLowerCase()) ||
                      email.contains(widget.searchQuery.toLowerCase()) ||
                      code.contains(widget.searchQuery.toLowerCase());
                }).toList();
              }

              // Sort users
              users.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                if (_sortBy == 'most') {
                  final aCount = (aData['referrals'] as List?)?.length ?? 0;
                  final bCount = (bData['referrals'] as List?)?.length ?? 0;
                  return bCount.compareTo(aCount);
                } else {
                  final aLastSeen = aData['lastSeen'];
                  final bLastSeen = bData['lastSeen'];

                  if (aLastSeen == null) return 1;
                  if (bLastSeen == null) return -1;

                  final aDate = aLastSeen is Timestamp
                      ? aLastSeen.toDate()
                      : DateTime.parse(aLastSeen.toString());
                  final bDate = bLastSeen is Timestamp
                      ? bLastSeen.toDate()
                      : DateTime.parse(bLastSeen.toString());

                  return bDate.compareTo(aDate);
                }
              });

              if (users.isEmpty) {
                return _buildEmptyState(isSearch: true);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = users[index].data() as Map<String, dynamic>;
                  final userId = users[index].id;
                  return _buildReferrerCard(userData, userId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortButton(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4A017) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.black : Colors.white60,
            ),
          ),
        ),
      ),
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

  Widget _buildEmptyState({bool isSearch = false}) {
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
            child: Icon(
              isSearch ? CupertinoIcons.search : CupertinoIcons.person_2,
              size: 48,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'No users match your search' : 'No referrals yet',
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

  Widget _buildReferrerCard(Map<String, dynamic> userData, String userId) {
    final name = userData['fullname'] ?? 'Unnamed User';
    final email = userData['email'] ?? 'No Email';
    final photoUrl = userData['photoUrl'];
    final referralCode = userData['referralCode'] ?? '';
    final referrals = userData['referrals'] as List? ?? [];
    final referralCount = referrals.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4A017),
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
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A017).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFD4A017),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.tag_fill,
                              size: 12,
                              color: Color(0xFFD4A017),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              referralCode,
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFD4A017),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4A017).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        referralCount.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD4A017),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Referrals',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white.withOpacity(0.1),
          ),

          // Referrals List
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchReferredUsers(referrals),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFD4A017),
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No referred users data available',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              final referredUsers = snapshot.data!;

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: referredUsers.length,
                separatorBuilder: (context, index) => Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.white.withOpacity(0.05),
                ),
                itemBuilder: (context, index) {
                  final referredUser = referredUsers[index];
                  return _buildReferredUserItem(referredUser, index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReferredUserItem(Map<String, dynamic> user, int index) {
    final name = user['fullname'] ?? 'Unnamed User';
    final email = user['email'] ?? 'No Email';
    final photoUrl = user['photoUrl'];
    final joinedAt = user['joinedAt'];
    final wallet = user['wallet'] ?? 0.0;

    String joinedText = 'Unknown date';
    if (joinedAt != null) {
      final date = joinedAt is Timestamp
          ? joinedAt.toDate()
          : DateTime.parse(joinedAt.toString());
      joinedText = DateFormat('MMM d, yyyy').format(date);
    }

    final formatter = NumberFormat("#,##0.00", "en_US");

    return Row(
      children: [
        // Number Badge
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white54,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF0ECB81).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.1),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? const Icon(
                    CupertinoIcons.person_fill,
                    color: Colors.white38,
                    size: 20,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    size: 11,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Joined $joinedText',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Wallet Balance
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0ECB81).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF0ECB81).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '\$${formatter.format(wallet)}',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF0ECB81),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _fetchReferredUsers(
    List referralIds,
  ) async {
    List<Map<String, dynamic>> users = [];

    for (var id in referralIds) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(id.toString())
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          users.add(data);
        }
      } catch (e) {
        print('Error fetching user $id: $e');
      }
    }

    // Sort by join date (most recent first)
    users.sort((a, b) {
      final aDate = a['joinedAt'];
      final bDate = b['joinedAt'];

      if (aDate == null) return 1;
      if (bDate == null) return -1;

      final aDateTime = aDate is Timestamp
          ? aDate.toDate()
          : DateTime.parse(aDate.toString());
      final bDateTime = bDate is Timestamp
          ? bDate.toDate()
          : DateTime.parse(bDate.toString());

      return bDateTime.compareTo(aDateTime);
    });

    return users;
  }
}
