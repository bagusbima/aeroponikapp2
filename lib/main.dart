import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

// Import halaman
import 'screens/login_page.dart';
import 'screens/home_page.dart'; 

// Import controller
import 'controllers/auth_controller.dart';

// Import config firebase
import 'firebase_options.dart'; 

// Import service notifikasi
import 'package:aeroponikapp/services/notification_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  NotificationService notificationService = NotificationService();
  await notificationService.initNotification();

  // Inisialisasi AuthController secara global dan permanen saat aplikasi start
  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aeroponik Pro V9',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00C897),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C897),
          primary: const Color(0xFF00C897),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6F9),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF00C897).withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        )
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}