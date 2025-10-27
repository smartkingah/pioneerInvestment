import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:investmentpro/screen/Dash_baord/dashbaord.dart';
import 'package:investmentpro/screen/admin_/suspendUseraccoundt.dart';
import 'package:investmentpro/screen/web_platform/web.dart';

class AuthState extends StatefulWidget {
  const AuthState({super.key});

  @override
  State<AuthState> createState() => _AuthStateState();
}

class _AuthStateState extends State<AuthState> {
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   setUserDat();
  // }

  // setUserDat() async {
  //   await Provider.of<AuthenticationProvider>(context, listen: false)
  //       .setUserDetails(
  //     fullName: GetStorage().read('fullName') ?? '',
  //     email: GetStorage().read('email') ?? '',
  //     phoneNumber: GetStorage().read('phoneNumber') ?? '',
  //     profilePic: GetStorage().read('profilePic') ?? '',
  //     address: GetStorage().read('address') ?? '',
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // final userId =
    // Provider.of<AuthenticationProvider>(context, listen: false).getUserId();
    return
    // OnBoardingScreen();
    // userId != null ? const MainPages() : LoginScreen();
    StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // return InvestmentDashboard();
          return SuspendedAccountWrapper(
            dashboardScreen: const InvestmentDashboard(),
          );
        } else {
          print('log in is false ------------------');
          return const InvestmentLandingPage();
        }
      },
    );
  }
}
