import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar appBarDetails({context}) {
  return AppBar(
    backgroundColor: const Color(0xFF0A0A0A),
    elevation: 0,
    leading: IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(CupertinoIcons.back, color: Colors.white, size: 20),
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
  );
}
