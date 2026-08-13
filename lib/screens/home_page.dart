import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import controllers bawaanmu
import '../controllers/monitoring_controller.dart';
import '../controllers/control_controller.dart';
import '../controllers/manual_controller.dart';
import '../controllers/settings_controller.dart';

// Import AuthController untuk fitur logout
import '../controllers/auth_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  // Daftar Halaman (Controller UI)
  final List<Widget> _pages = [
    const MonitoringController(), 
    const ControlController(),
    const ManualController(),
    const SettingsController(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Aeroponik'), // Menambahkan judul agar tidak kosong
        centerTitle: true,
        backgroundColor: const Color(0xFF00C897),
        foregroundColor: Colors.white,
        actions: [
          // Tombol Logout di pojok kanan atas AppBar
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar Akun',
            onPressed: () {
              // Menampilkan Dialog Konfirmasi Keluar yang rapi & interaktif
              Get.defaultDialog(
                title: "Keluar Akun",
                titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                middleText: "Apakah Anda yakin ingin keluar dari aplikasi monitoring?",
                middleTextStyle: const TextStyle(color: Colors.black54),
                textConfirm: "Ya, Keluar",
                textCancel: "Batal",
                confirmTextColor: Colors.white,
                cancelTextColor: const Color(0xFF00C897),
                buttonColor: Colors.redAccent,
                radius: 12,
                onConfirm: () {
                  Get.back(); // Tutup dialog konfirmasi terlebih dahulu
                  // Panggil fungsi logout dari AuthController
                  Get.find<AuthController>().logout();
                },
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Monitor'),
          NavigationDestination(icon: Icon(Icons.play_circle_fill), label: 'Proses'),
          NavigationDestination(icon: Icon(Icons.toggle_on), label: 'Manual'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}