import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Import halaman
import 'screens/home_page.dart'; 

// Import config firebase (pastikan file ini sudah dipindah ke folder lib)
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

// ... imports

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aeroponik Pro V9',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Ganti Primary Swatch dengan warna custom agar mirip referensi
        primaryColor: const Color(0xFF00C897),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C897),
          primary: const Color(0xFF00C897), // Warna Hijau Tosca
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6F9), // Background abu muda
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        // Style Navigation Bar bawah
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF00C897).withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        )
      ),
      home: const HomePage(),
    );
  }
}