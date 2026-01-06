import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsController extends StatefulWidget {
  const SettingsController({Key? key}) : super(key: key);

  @override
  State<SettingsController> createState() => _SettingsControllerState();
}

class _SettingsControllerState extends State<SettingsController> {
  final _dbRef = FirebaseDatabase.instance.ref();
  
  // Style Vars
  final Color _primaryColor = const Color(0xFF00C897);
  final Color _bgColor = const Color(0xFFF5F6F9);

  // Controllers
  final _phCtrl = TextEditingController();
  final _ecCtrl = TextEditingController();
  final _sprayIntCtrl = TextEditingController();
  final _sprayDurCtrl = TextEditingController();
  final _sampleIntCtrl = TextEditingController();
  final _luxCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final snap = await _dbRef.child("setpoints").get();
    if (snap.exists) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      setState(() {
        _phCtrl.text = (data['target_ph'] ?? 6.0).toString();
        _ecCtrl.text = (data['target_ec'] ?? 1200).toString();
        _sprayIntCtrl.text = (data['spray_interval'] ?? 15).toString();
        _sprayDurCtrl.text = (data['spray_duration'] ?? 120).toString();
        _sampleIntCtrl.text = (data['sample_interval'] ?? 6).toString();
        _luxCtrl.text = (data['lux_target'] ?? 5000).toString();
        _tempCtrl.text = (data['max_temp'] ?? 35.0).toString();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _save() {
    if (_phCtrl.text.isEmpty) return;
    _dbRef.child("setpoints").update({
      "target_ph": double.tryParse(_phCtrl.text) ?? 6.0,
      "target_ec": double.tryParse(_ecCtrl.text) ?? 1200,
      "spray_interval": int.tryParse(_sprayIntCtrl.text) ?? 15,
      "spray_duration": int.tryParse(_sprayDurCtrl.text) ?? 120,
      "sample_interval": int.tryParse(_sampleIntCtrl.text) ?? 6,
      "lux_target": double.tryParse(_luxCtrl.text) ?? 5000,
      "max_temp": double.tryParse(_tempCtrl.text) ?? 35.0,
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pengaturan Disimpan!"), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: _bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pengaturan", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Konfigurasi parameter alat", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // CARD 1: NUTRISI
                  _buildSectionCard("Target Nutrisi", Icons.local_florist, [
                    _buildInput("Target pH", _phCtrl, "Contoh: 6.0"),
                    _buildInput("Target EC", _ecCtrl, "uS/cm"),
                  ]),

                  const SizedBox(height: 20),

                  // CARD 2: JADWAL
                  _buildSectionCard("Jadwal & Timer", Icons.timer, [
                    Row(
                      children: [
                        Expanded(child: _buildInput("Interval Spray", _sprayIntCtrl, "Menit")),
                        const SizedBox(width: 15),
                        Expanded(child: _buildInput("Durasi Spray", _sprayDurCtrl, "Detik")),
                      ],
                    ),
                    _buildInput("Cek Nutrisi Setiap", _sampleIntCtrl, "Jam"),
                  ]),

                  const SizedBox(height: 20),
                  
                  // CARD 3: LINGKUNGAN
                  _buildSectionCard("Batas Lingkungan", Icons.thermostat, [
                    _buildInput("Target Cahaya", _luxCtrl, "Lux"),
                    _buildInput("Max Suhu Air", _tempCtrl, "°C"),
                  ]),

                  const SizedBox(height: 30),

                  // TOMBOL SIMPAN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      onPressed: _save,
                      child: const Text("SIMPAN PERUBAHAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // SYNC TIME BUTTON
                  TextButton.icon(
                    onPressed: () {
                      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                      _dbRef.child("control/cmd_sync_time").set(timestamp);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perintah Sync Jam Dikirim!")));
                    }, 
                    icon: const Icon(Icons.access_time, color: Colors.purple), 
                    label: const Text("Sinkronisasi Jam Alat", style: TextStyle(color: Colors.purple))
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryColor),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            ],
          ),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              filled: true,
              fillColor: _bgColor,
              hintText: suffix,
              suffixText: suffix,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}