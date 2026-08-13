import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  
  // Menggunakan Get.put secara lazy agar tidak membebani render pertama
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9), // Mengikuti tema abu-abu mudamu
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ============================================================
                // REVISI: Mengganti Material Icon dengan Custom Image Icon
                // ============================================================
                Image.asset(
                  'assets/icons/icons.png',
                  // Menyesuaikan ukuran tampilan agar pas di layar,
                  // walaupun ukuran file aslinya 500x500px.
                  width: 120, 
                  height: 120,
                  fit: BoxFit.contain, // Memastikan gambar tidak terpotong
                  errorBuilder: (context, error, stackTrace) {
                    // Pengaman jika gambar gagal dimuat/salah taruh folder
                    return const Icon(Icons.broken_image, size: 90, color: Colors.red);
                  },
                ),
                // ============================================================
                
                const SizedBox(height: 16),
                const Text(
                  "Monitoring Aeroponik",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF00C897),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan Login untuk mengakses sistem.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                
                // Input Email (Sudah disesuaikan style-nya dengan inputDecorationTheme di main.dart)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black87), 
                  decoration: const InputDecoration(
                    labelText: "Email Operator",
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF00C897)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email tidak boleh kosong";
                    if (!GetUtils.isEmail(value)) return "Format email tidak valid";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Input Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: "Kata Sandi",
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00C897)),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Kata sandi tidak boleh kosong";
                    if (value.length < 6) return "Kata sandi minimal 6 karakter";
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Tombol Masuk Log
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C897),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () {
                    // Validasi Form sebelum eksekusi login
                    if (_formKey.currentState!.validate()) {
                      authController.login(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    }
                  },
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}