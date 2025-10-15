import 'package:flutter/material.dart';
import 'package:investmentpro/screen/web_platform/Widgets/about_widget.dart';
import 'package:investmentpro/screen/web_platform/Widgets/ambassador_Page.dart';
import 'package:investmentpro/screen/web_platform/Widgets/footer_area.dart';
import 'package:investmentpro/screen/web_platform/Widgets/how_it_works.dart';
import 'package:investmentpro/screen/web_platform/Widgets/investment_highlight_page.dart';
import 'package:investmentpro/screen/web_platform/Widgets/package.dart';
import 'package:investmentpro/screen/web_platform/Widgets/security_assurance_page.dart';
import 'package:investmentpro/screen/web_platform/Widgets/why_choose_us.dart';

class DesktopScreen extends StatefulWidget {
  const DesktopScreen({super.key});

  @override
  State<DesktopScreen> createState() => _DesktopScreenState();
}

class _DesktopScreenState extends State<DesktopScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        AboutInvestProPage(),
        WhyChooseInvestProPage(),
        InvestmentPackagesPage(),
        HowItWorksPage(),
        InvestmentHighlightsPage(),
        SecurityAssurancePage(),
        AmbassadorPage(),
        InvestProFooter(),

        /// nothing much really done yet
        ///
      ],
    );
  }
}
