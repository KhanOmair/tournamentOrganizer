import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tourney_app/pages/home_page.dart';
import 'package:tourney_app/pages/login_page.dart';
import 'package:tourney_app/utils/theme_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC3M3P_PXNYb94MsBMNpXSf_wMoCPREB1w",
      authDomain: "tournamentscheduler-4c4d8.firebaseapp.com",
      projectId: "tournamentscheduler-4c4d8",
      storageBucket: "tournamentscheduler-4c4d8.firebasestorage.app",
      messagingSenderId: "436667867877",
      appId: "1:436667867877:web:7eae6423a580a818a4aa0c",
      measurementId: "G-798QTBCSBL",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tournament Scheduler',
      theme: orangeTheme,
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
