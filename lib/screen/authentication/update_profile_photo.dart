import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/Services/cloudinary_services.dart';
import 'package:investmentpro/screen/Dash_baord/dashbaord.dart';

class ProfilePhotoPage extends StatefulWidget {
  final String uid;
  const ProfilePhotoPage({super.key, required this.uid});

  @override
  State<ProfilePhotoPage> createState() => _ProfilePhotoPageState();
}

class _ProfilePhotoPageState extends State<ProfilePhotoPage> {
  File? _pickedFile;
  Uint8List? _webImage;
  bool _uploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _webImage = result.files.single.bytes;
          _pickedFile = null; // ensure not mixing
        });
      } else {
        setState(() {
          _pickedFile = File(result.files.single.path!);
          _webImage = null;
        });
      }
    }
  }

  Future<void> _uploadAndContinue() async {
    if (_pickedFile == null && _webImage == null) {
      Get.snackbar(
        'Error',
        'Please select a photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _uploading = true);

    String? url;

    if (kIsWeb && _webImage != null) {
      url = await CloudinaryService.uploadWebImage(_webImage!);
    } else if (!kIsWeb && _pickedFile != null) {
      url = await CloudinaryService.uploadImage(_pickedFile!);
    }

    if (url != null) {
      await AuthService.updatePhotoUrl(widget.uid, url, context);
      Get.snackbar(
        'Success 🎉',
        'Profile photo uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.greenAccent,
        colorText: Colors.black,
      );

      // Wait a moment before navigating
      await Future.delayed(const Duration(seconds: 1));
      Get.off(() => const InvestmentDashboard());
    } else {
      Get.snackbar(
        'Upload Error',
        'Failed to upload photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }

    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (kIsWeb && _webImage != null) {
      imageProvider = MemoryImage(_webImage!);
    } else if (!kIsWeb && _pickedFile != null) {
      imageProvider = FileImage(_pickedFile!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text('Upload Profile Photo'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 65,
              backgroundColor: Colors.grey[800],
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 65, color: Colors.white24)
                  : null,
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Select Photo from Device'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD400),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploading ? null : _uploadAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD400),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _uploading
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : const Text(
                      'Save & Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
