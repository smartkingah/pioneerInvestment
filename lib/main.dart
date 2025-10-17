import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:investmentpro/firebase_options.dart';
import 'package:investmentpro/providers/model_provider.dart';
import 'package:investmentpro/screen/Auth/auth_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage().writeIfNull('authState', false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ModelProvider())],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        // scrollBehavior: MyCustomScrollBehavior(),
        title: 'Pioneer Capital Limited',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: AuthState(),
      ),
    );
  }
}
