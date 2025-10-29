import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/screen/Dash_baord/update_Profile.dart';

AppBar dashBoardAppBar({context}) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: const Color(0xFF0A0A0A),
    elevation: 0,
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl:
            'https://res.cloudinary.com/dy523yrlh/image/upload/v1761692169/PCL_LOGO_tjuaw6.png',
        // width: double.infinity,
        // height: double.infinity,
        width: 60,
        height: 60,
      ),
    ),
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
        padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
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
