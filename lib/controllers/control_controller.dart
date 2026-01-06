import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ControlController extends StatelessWidget {
  const ControlController({Key? key}) : super(key: key);

  // Warna Tema
  final Color _primaryColor = const Color(0xFF00C897);
  final Color _bgColor = const Color(0xFFF5F6F9);

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      backgroundColor: _bgColor,
      body: StreamBuilder(
        stream: dbRef.child("monitoring").onValue,
        builder: (context, snapshot) {
          bool isAuto = false;
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
             final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
             String modeStr = data['system_mode'] ?? "MANUAL";
             isAuto = (modeStr == "AUTO");
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER ---
                _buildHeader("Kontrol Proses", "Jalankan perintah manual"),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Status Banner
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isAuto ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: isAuto ? Colors.green.shade200 : Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(isAuto ? Icons.lock : Icons.lock_open, color: isAuto ? Colors.green : Colors.orange),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                isAuto 
                                  ? "Mode OTOMATIS Aktif. Tombol dikunci demi keamanan." 
                                  : "Mode MANUAL Aktif. Anda dapat mengontrol alat.",
                                style: TextStyle(color: isAuto ? Colors.green.shade800 : Colors.orange.shade800, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 25),

                      // --- TOMBOL KONTROL ---
                      _buildControlCard(
                        context, 
                        "Mulai Sampling", 
                        "Cek nutrisi & pH sekarang", 
                        Icons.science, 
                        Colors.blue, 
                        isAuto, 
                        () => _sendCommand(context, dbRef, "cmd_start_sampling", isAuto)
                      ),

                      const SizedBox(height: 20),

                      _buildControlCard(
                        context, 
                        "Semprot (Spray)", 
                        "Siram tanaman manual", 
                        Icons.shower, 
                        Colors.teal, 
                        isAuto, 
                        () => _sendCommand(context, dbRef, "cmd_start_spray", isAuto)
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

  // --- HEADER WIDGET ---
  Widget _buildHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  // --- CARD TOMBOL KONTROL ---
  Widget _buildControlCard(BuildContext context, String title, String subtitle, IconData icon, Color color, bool isLocked, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: isLocked ? 0 : 5,
      shadowColor: Colors.grey.shade200,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isLocked ? Border.all(color: Colors.grey.shade300) : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade200 : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isLocked ? Colors.grey : color, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isLocked ? Colors.grey : Colors.black87)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300)
            ],
          ),
        ),
      ),
    );
  }

  void _sendCommand(BuildContext context, DatabaseReference ref, String cmd, bool isAuto) {
    if (isAuto) {
      _showAutoAlert(context);
    } else {
      ref.child("control/$cmd").set(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Perintah dikirim ke alat!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _showAutoAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Akses Ditolak"),
        content: const Text("Matikan mode OTOMATIS terlebih dahulu untuk menggunakan kontrol manual."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }
}