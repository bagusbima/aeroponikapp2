import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Rx<User?> _user;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.userChanges());
    ever(_user, _initialScreen);
  }

  // LOGIKA PENGAMAN: Mencegah looping rute yang bikin aplikasi freeze
  void _initialScreen(User? user) {
    if (user == null) {
      print("🔐 Pengguna tidak terautentikasi.");
      // Hanya arahkan ke login jika saat ini TIDAK sedang berada di halaman login
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } else {
      print("🔓 Pengguna terautentikasi: ${user.email}.");
      // Hanya arahkan ke home jika saat ini TIDAK sedang berada di halaman home
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFF00C897))),
        barrierDismissible: false,
      );
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.back(); 
    } on FirebaseAuthException catch (e) {
      Get.back(); 
      String message = "";
      if (e.code == 'user-not-found') {
        message = 'Email tidak ditemukan di sistem.';
      } else if (e.code == 'wrong-password') {
        message = 'Kata sandi yang Anda masukkan salah.';
      } else {
        message = e.message ?? 'Terjadi kesalahan jaringan.';
      }
      
      Get.snackbar(
        "Gagal Masuk Log",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}