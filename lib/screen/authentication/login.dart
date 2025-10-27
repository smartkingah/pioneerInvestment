import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investmentpro/Services/authentication_services.dart';
import 'package:investmentpro/screen/Auth/auth_screen.dart';
import 'package:investmentpro/screen/Dash_baord/dashbaord.dart';
import 'package:investmentpro/screen/authentication/forgot_password.dart';
import 'package:investmentpro/screen/authentication/signup.dart';
import 'package:investmentpro/screen/authentication/update_profile_photo.dart';
import 'package:investmentpro/screen/submit_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      Get.snackbar(
        'Error',
        'Enter email and password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      setState(() => _loading = true);
      final user = await AuthService.signIn(
        email: email,
        password: pass,
        context: context,
      );
      // if (user != null) {
      //   final userDoc = await AuthService.getUserDoc(user.uid);
      //   final photo = userDoc?['photoUrl'] as String?;
      //   if (photo == null || photo.isEmpty) {
      //     // go to photo upload
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) {
      //           return ProfilePhotoPage(uid: user.uid);
      //         },
      //       ),
      //     );
      //   } else {
      //     // go to dashboard
      //   }
      // }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AuthState();
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login error',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFD400);
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // top logo
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                child: Icon(Icons.layers, size: 64, color: yellow),
              ),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Log in to your account',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // email field
              _buildField(
                'Email',
                hint: 'you@example.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // password field with visibility toggle
              _buildField(
                'Password',
                hint: 'Enter your password',
                controller: _passCtrl,
                obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() {
                    _obscure = !_obscure;
                  }),
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Get.to(() => const ForgotPasswordPage());
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.amber),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // login button
              LongButton(
                title: _loading ? 'Logging in...' : 'Login',
                onTap: _loading ? null : _login,
                textColor: _loading ? Colors.white : Colors.black,
              ),

              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New to our platform? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const SignupPage()),
                    child: const Text(
                      'Create an account',
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label, {
    String? hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
