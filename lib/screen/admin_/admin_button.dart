import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investmentpro/screen/admin_/admin_page.dart';

class AdminButton extends StatefulWidget {
  const AdminButton({super.key});

  @override
  State<AdminButton> createState() => _AdminButtonState();
}

class _AdminButtonState extends State<AdminButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('admin')
          .doc('adminList')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox.shrink();
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        List adminEmails = snap.data!['adminEmails'] ?? [];
        bool isAdmin = adminEmails.contains(
          FirebaseAuth.instance.currentUser?.email,
        );
        return isAdmin
            ? FloatingActionButton.small(
                backgroundColor: const Color(0xFF2C2C2E),
                elevation: 2,
                onPressed: () {
                  Get.to(() => AdminUserManagementScreen());
                  // showLogoutDialog();
                },
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.amber,
                  size: 20,
                ),
              )
            : SizedBox.shrink();
      },
    );
  }
}
