import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/screen/authentication/update_profile_photo.dart';
import 'package:investmentpro/screen/submit_button.dart';
import 'login.dart'; // for navigation back to login

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _fullname = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _country = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _referredBy = TextEditingController();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  Future<void> _signup() async {
    final fullname = _fullname.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final country = _country.text.trim();
    final address = _address.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;
    final referredBy = _referredBy.text;

    if (fullname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        country.isEmpty ||
        phone.isEmpty ||
        confirm.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password != confirm) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      setState(() => _loading = true);
      final user = await AuthService.signUp(
        fullname: fullname,
        email: email,
        password: password,
        phone: phone,
        country: country,
        address: address,
        context: context,
        referredBy: referredBy,
      );
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProfilePhotoPage(uid: user.uid);
            },
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Signup Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _fullname.dispose();
    _email.dispose();
    _phone.dispose();
    _country.dispose();
    _address.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFD400);
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl:
                    'https://res.cloudinary.com/dy523yrlh/image/upload/v1761692169/PCL_LOGO_tjuaw6.png',
                // width: double.infinity,
                // height: double.infinity,
                width: 120,
                height: 120,
              ),
            ),
            // Icon(Icons.layers, color: yellow, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Join our investment platform',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 22),

            // input fields
            _buildField('Full Name', _fullname, hint: 'Enter your full name'),
            const SizedBox(height: 12),
            _buildField(
              'Email',
              _email,
              hint: 'you@example.com',
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildField(
              'Phone Number',
              _phone,
              hint: '+1 3332...',
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildField('Country', _country, hint: 'United States'),
            const SizedBox(height: 12),
            _buildField('Address', _address, hint: 'Street / City'),
            const SizedBox(height: 12),

            // password
            _buildField(
              'Password',
              _password,
              hint: 'Enter your password',
              obscure: _obscurePass,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              'Confirm Password',
              _confirm,
              hint: 'Re-enter your password',
              obscure: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            const SizedBox(height: 12),
            _buildField('Referred By', _referredBy, hint: '0000 (OPTIONAL)'),
            const SizedBox(height: 22),

            LongButton(
              title: _loading ? 'Creating Account...' : 'Sign Up',
              onTap: _loading ? null : _signup,
              textColor: _loading ? Colors.white : Colors.black,
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => const LoginPage()),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: yellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
