import 'package:flutter/material.dart';
// Import controller
import '../controllers/monitoring_controller.dart';
import '../controllers/control_controller.dart';
import '../controllers/manual_controller.dart';
import '../controllers/settings_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  // Daftar Halaman (Controller UI)
  final List<Widget> _pages = [
    const MonitoringController(), // Pastikan file ini ada & nama class benar
    const ControlController(),
    const ManualController(),
    const SettingsController(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        backgroundColor: const Color(0xFF00C897),
        foregroundColor: Colors.white,
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