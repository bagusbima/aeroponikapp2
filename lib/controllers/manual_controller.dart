import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManualController extends StatelessWidget {
  const ManualController({Key? key}) : super(key: key);

  final Color _primaryColor = const Color(0xFF00C897);
  final Color _bgColor = const Color(0xFFF5F6F9);

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      backgroundColor: _bgColor,
      body: StreamBuilder(
        stream: dbRef.child("manual").onValue,
        builder: (context, snapshot) {
          Map data = {};
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER ---
                _buildHeader("Manual Relay", "Kontrol Saklar Kelistrikan"),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Warning Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
                        child: const Text(
                          "⚠️ Gunakan dengan hati-hati. Pastikan tidak ada proses otomatis yang sedang berjalan.",
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- GRID SWITCHES ---
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.3,
                        children: [
                          _buildSwitchCard(dbRef, "Pompa Spray", "relay_spray", data, Icons.shower),
                          _buildSwitchCard(dbRef, "Pompa Mixer", "relay_mixer", data, Icons.blender),
                          _buildSwitchCard(dbRef, "Nutrisi A&B", "relay_nutri", data, Icons.local_pharmacy),
                          _buildSwitchCard(dbRef, "Sampling", "relay_sampling", data, Icons.science),
                          _buildSwitchCard(dbRef, "Buang Air", "relay_buang", data, Icons.delete_outline),
                          _buildSwitchCard(dbRef, "pH UP", "relay_ph_up", data, Icons.arrow_upward),
                          _buildSwitchCard(dbRef, "pH DOWN", "relay_ph_down", data, Icons.arrow_downward),
                          _buildSwitchCard(dbRef, "Lampu Grow", "relay_lampu", data, Icons.lightbulb),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSwitchCard(DatabaseReference ref, String label, String key, Map data, IconData icon) {
    bool isOn = data[key] ?? false;
    
    return GestureDetector(
      onTap: () {
        // Toggle nilai (True jadi False, False jadi True)
        ref.child("manual/$key").set(!isOn);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isOn ? _primaryColor : Colors.white, // Hijau kalau ON
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4))],
          border: isOn ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isOn ? Colors.white : Colors.grey, size: 28),
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: isOn ? Colors.white : Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isOn ? "ON" : "OFF", style: TextStyle(color: isOn ? Colors.white70 : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(color: isOn ? Colors.white : Colors.grey.shade800, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}