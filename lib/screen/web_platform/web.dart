import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/screen/web_platform/Widgets/customer_support.dart';
import 'package:investmentpro/screen/web_platform/Widgets/firstSide.dart';
import 'package:investmentpro/screen/web_platform/desktop_screen.dart';

class InvestmentLandingPage extends StatelessWidget {
  const InvestmentLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1,
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl:
                              'https://res.cloudinary.com/dy523yrlh/image/upload/v1760526626/modern-business-buildings-financial-district_mjt0jl.jpg',
                        ),
                      ),
                      Container(
                        // height: MediaQuery.of(context).size.height / 2,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFD4AF37),
                              Color(0xFFD4AF37).withOpacity(0.7),
                              Colors.transparent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),

                      firstSide(context: context),
                    ],
                  ),
                ),
                _buildDesktopLayout(context),
              ],
            ),
          ),

          ///customer care
          /// customer care floating bottom-right
          // Positioned(bottom: 8, right: 8, child: CustomerCareSection()),
        ],
      ),
    );
  }

  // 22427787915
  // 🟢 Desktop layout
  Widget _buildDesktopLayout(BuildContext context) {
    return DesktopScreen();
  }
}
