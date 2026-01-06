import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
// Import http dan dart:convert sudah dihapus karena tidak dipakai lagi

class MonitoringController extends StatefulWidget {
  const MonitoringController({Key? key}) : super(key: key);

  @override
  State<MonitoringController> createState() => _MonitoringControllerState();
}

class _MonitoringControllerState extends State<MonitoringController> {
  // --- WARNA TEMA ---
  final Color _primaryColor = const Color(0xFF00C897); 
  final Color _bgColor = const Color(0xFFF5F6F9); 
  final Color _cardColor = Colors.white; 

  // --- VARIABEL GRAFIK (DATA HISTORY) ---
  final List<FlSpot> _phSpots = [];
  final List<FlSpot> _ecSpots = [];
  final List<FlSpot> _waterTempSpots = [];
  final List<FlSpot> _airTempSpots = [];
  final List<FlSpot> _humSpots = [];
  final List<FlSpot> _luxSpots = [];
  
  double _timeCounter = 0; 

  // (Bagian Variabel AI & Fungsi _analyzePlant SUDAH DIHAPUS)

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      backgroundColor: _bgColor,
      body: StreamBuilder(
        stream: dbRef.child("monitoring").onValue,
        builder: (context, snapshot) {
          // Default Values
          Map<String, dynamic> rawData = {}; 
          String systemMode = "MANUAL";
          String statusText = "Menunggu...";

          if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map;
            rawData = Map<String, dynamic>.from(data);

            systemMode = rawData['system_mode'] ?? "MANUAL";
            statusText = rawData['status_text'] ?? "Siaga";

            // --- LOGIKA UPDATE GRAFIK ---
            double ph = double.tryParse(rawData['ph'].toString()) ?? 0;
            double ec = double.tryParse(rawData['ec'].toString()) ?? 0;
            double wTemp = double.tryParse(rawData['water_temp'].toString()) ?? 0;
            double aTemp = double.tryParse(rawData['temp_air'].toString()) ?? 0;
            double hum = double.tryParse(rawData['hum'].toString()) ?? 0;
            double lux = double.tryParse(rawData['lux'].toString()) ?? 0;

            if (_phSpots.isEmpty || _phSpots.last.x != _timeCounter) {
               _phSpots.add(FlSpot(_timeCounter, ph));
               _ecSpots.add(FlSpot(_timeCounter, ec));
               _waterTempSpots.add(FlSpot(_timeCounter, wTemp));
               _airTempSpots.add(FlSpot(_timeCounter, aTemp));
               _humSpots.add(FlSpot(_timeCounter, hum));
               _luxSpots.add(FlSpot(_timeCounter, lux));
               
               _timeCounter++;

               if (_phSpots.length > 20) {
                 _phSpots.removeAt(0);
                 _ecSpots.removeAt(0);
                 _waterTempSpots.removeAt(0);
                 _airTempSpots.removeAt(0);
                 _humSpots.removeAt(0);
                 _luxSpots.removeAt(0);
               }
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(systemMode, statusText),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // (Bagian Card AI SUDAH DIHAPUS)
                      
                      // 1. GRID SENSOR
                      const Text("Parameter Sensor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.3,
                        children: [
                          _sensorCard("pH Air", "${rawData['ph']??0}", "pH", Icons.water_drop, Colors.blue),
                          _sensorCard("EC Nutrisi", "${rawData['ec']??0}", "uS/cm", Icons.bolt, Colors.purple),
                          _sensorCard("Suhu Air", "${rawData['water_temp']??0}", "°C", Icons.thermostat, Colors.red),
                          _sensorCard("Suhu Udara", "${rawData['temp_air']??0}", "°C", Icons.air, Colors.orange),
                          _sensorCard("Kelembaban", "${rawData['hum']??0}", "%", Icons.cloud, Colors.lightBlue),
                          _sensorCard("Cahaya", "${rawData['lux']??0}", "Lux", Icons.wb_sunny, Colors.amber.shade700),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      const Text("Grafik Realtime", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      // 2. DAFTAR GRAFIK
                      _buildChartContainer("Grafik pH (Keasaman)", _phSpots, Colors.blue, 0, 14, 1),
                      const SizedBox(height: 15),

                      _buildChartContainer("Grafik EC (Kepekatan)", _ecSpots, Colors.purple, 0, 2500, 500),
                      const SizedBox(height: 15),

                      _buildDoubleLineChart("Grafik Suhu (Air vs Udara)", _waterTempSpots, _airTempSpots, 15, 50),
                      const SizedBox(height: 15),

                      _buildChartContainer("Grafik Kelembaban (%)", _humSpots, Colors.lightBlue, 0, 100, 20),
                      const SizedBox(height: 15),

                      _buildChartContainer("Grafik Cahaya (Lux)", _luxSpots, Colors.amber.shade700, 0, 10000, 2000),
                      const SizedBox(height: 50), 
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

  // --- WIDGET CHART ---
  Widget _buildChartContainer(String title, List<FlSpot> spots, Color color, double min, double max, double interval) {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(15, 20, 20, 10),
      decoration: BoxDecoration(
        color: _cardColor, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: min, maxY: max,
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: interval, getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade200)),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots, isCurved: true, color: color, barWidth: 3, isStrokeCapRound: true, dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoubleLineChart(String title, List<FlSpot> spots1, List<FlSpot> spots2, double min, double max) {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(15, 20, 20, 10),
      decoration: BoxDecoration(
        color: _cardColor, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Container(width: 10, height: 10, color: Colors.red), const Text(" Air ", style: TextStyle(fontSize: 10)),
                  Container(width: 10, height: 10, color: Colors.orange), const Text(" Udara", style: TextStyle(fontSize: 10)),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: min, maxY: max,
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 5, getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade200)),
                lineBarsData: [
                  LineChartBarData(spots: spots1, isCurved: true, color: Colors.red, barWidth: 3, isStrokeCapRound: true, dotData: FlDotData(show: false)),
                  LineChartBarData(spots: spots2, isCurved: true, color: Colors.orange, barWidth: 3, isStrokeCapRound: true, dotData: FlDotData(show: false)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sensorCard(String title, String val, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          Text("$unit $title", style: TextStyle(fontSize: 10, color: Colors.grey.shade500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHeader(String mode, String status) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: BoxDecoration(color: _primaryColor, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
      child: Column(children: [
        const Text("Dashboard Monitoring", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(15)),
          child: Text("Mode: $mode | Status: $status", style: const TextStyle(color: Colors.white, fontSize: 12)),
        )
      ]),
    );
  }
}