import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A9E7E),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF7A9E7E),
          secondary: const Color(0xFFD4E6D5),
          surface: const Color(0xFFF8FAF8),
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          iconTheme: IconThemeData(color: Color(0xFF2D2D2D)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A9E7E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF7A9E7E),
            side: const BorderSide(color: Color(0xFF7A9E7E)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD4E6D5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF7A9E7E), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF7A9E7E),
          unselectedItemColor: Color(0xFFBDBDBD),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 20,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String? userLogin;
  void setUser(String login) {
    userLogin = login;
    notifyListeners();
  }

  void logout() {
    userLogin = null;
    notifyListeners();
  }
}
