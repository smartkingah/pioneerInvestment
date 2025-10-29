import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/Services/cloudinary_services.dart';
import 'package:investmentpro/screen/Dash_baord/widgets/referal_widget.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usdtAddressController = TextEditingController();
  final TextEditingController _careerController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _pickedFile;
  Uint8List? _webImage;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = getStorage.read('fullname') ?? '';
    _phoneController.text = getStorage.read('phone') ?? '';
    _usdtAddressController.text = getStorage.read('usdtAddress') ?? '';
    _careerController.text = getStorage.read('career') ?? '';
    _addressController.text = getStorage.read('address') ?? '';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _webImage = result.files.single.bytes;
          _pickedFile = null;
        });
      } else {
        setState(() {
          _pickedFile = File(result.files.single.path!);
          _webImage = null;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _uploading = true);

    try {
      String? imageUrl;
      if (_webImage != null || _pickedFile != null) {
        if (kIsWeb && _webImage != null) {
          imageUrl = await CloudinaryService.uploadWebImage(_webImage!);
        } else if (!kIsWeb && _pickedFile != null) {
          imageUrl = await CloudinaryService.uploadImage(_pickedFile!);
        }

        if (imageUrl != null) {
          await getStorage.write('photoUrl', imageUrl);
        }
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
            'fullname': _fullNameController.text,
            'phone': _phoneController.text,
            'usdtAddress': _usdtAddressController.text,
            'career': _careerController.text,
            'address': _addressController.text,
            if (imageUrl != null) 'photoUrl': imageUrl,
          });

      await getStorage.write('fullname', _fullNameController.text);
      await getStorage.write('phone', _phoneController.text);
      await getStorage.write('usdtAddress', _usdtAddressController.text);
      await getStorage.write('career', _careerController.text);
      await getStorage.write('address', _addressController.text);

      if (mounted) {
        AuthService().showSuccessSnackBar(
          context: context,
          title: 'Success',
          subTitle: 'Profile Updated Successfully',
        );

        Navigator.pop(context);
      }
    } catch (e) {
      AuthService().showErrorSnackBar(
        context: context,
        title: 'Error',
        subTitle: 'Failed to update profile: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (kIsWeb && _webImage != null) {
      imageProvider = MemoryImage(_webImage!);
    } else if (!kIsWeb && _pickedFile != null) {
      imageProvider = FileImage(_pickedFile!);
    } else if (getStorage.read('photoUrl') != null) {
      imageProvider = NetworkImage(getStorage.read('photoUrl'));
    }

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
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Picture Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0A0A0A), const Color(0xFF111111)],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD400).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? const Icon(
                                  CupertinoIcons.person_fill,
                                  size: 50,
                                  color: Colors.white38,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD400),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              CupertinoIcons.camera_fill,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      if (_uploading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFD400),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to change photo',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildModernTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: CupertinoIcons.person,
                    hint: 'Enter your full name',
                  ),
                  const SizedBox(height: 16),

                  _buildModernTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: CupertinoIcons.phone,
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  _buildModernTextField(
                    controller: _careerController,
                    label: 'Current Job/Career',
                    icon: CupertinoIcons.briefcase,
                    hint: 'Enter your profession',
                  ),
                  const SizedBox(height: 16),

                  _buildModernTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: CupertinoIcons.location,
                    hint: 'Enter your address',
                    maxLines: 2,
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Financial Information',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildModernTextField(
                    controller: _usdtAddressController,
                    label: 'USDT Wallet Address',
                    icon: CupertinoIcons.money_dollar_circle,
                    hint: 'Enter your USDT address',
                    suffixIcon: CupertinoIcons.qrcode,
                  ),

                  const SizedBox(height: 32),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _uploading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD400),
                        disabledBackgroundColor: const Color(
                          0xFFFFD400,
                        ).withOpacity(0.5),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _uploading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Updating...',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.check_mark_circled_solid,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Update Profile',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  referralCodeWidget(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFFFD400)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 15),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.white38, size: 20)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFFFD400),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: maxLines > 1 ? 16 : 18,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _usdtAddressController.dispose();
    _careerController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
