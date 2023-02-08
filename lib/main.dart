import 'package:cooktime/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'BottomNavBar.dart';
import 'Screens/Auth/SignIn/SignInScreen.dart';
import 'Screens/Auth/VerifyEmail/VerifyEmailScreen.dart';
import 'package:cooktime/Provider/BottomNavigationBarProvider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CookTime',
        theme: buildThemeData(),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapshot) {
              if (snapshot.hasData) {
                if (!snapshot.data!.emailVerified) {
                  return VerifyEmailScreen();
                }
                return (ChangeNotifierProvider<BottomNavigationBarProvider>(
                  child: BottomNavBar(),
                  create: (BuildContext context) =>
                      BottomNavigationBarProvider(),
                ));
              } else {
                return SignInScreen();
              }
            }));
  }
}
