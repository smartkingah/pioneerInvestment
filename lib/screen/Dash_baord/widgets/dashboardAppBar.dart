import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/screen/Dash_baord/update_Profile.dart';

AppBar dashBoardAppBar({context}) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: const Color(0xFF0A0A0A),
    elevation: 0,
    title: Text(
      'Pioneer Capital Limited',
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontSize: 18,
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UpdateProfileScreen(),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    getStorage.read('photoUrl') != null &&
                        getStorage.read('photoUrl').toString().isNotEmpty
                    ? NetworkImage(getStorage.read('photoUrl'))
                    : null,
                backgroundColor: const Color(0xFF2C2C2E),
                child:
                    (getStorage.read('photoUrl') == null ||
                        getStorage.read('photoUrl').toString().isEmpty)
                    ? const Icon(Icons.person, color: Colors.white70, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                getStorage.read('fullname') ?? "John Doe",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
