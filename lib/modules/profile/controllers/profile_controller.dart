import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  // Fungsi untuk Logout
  void logout() {
    Get.defaultDialog(
      title: "Keluar",
      middleText: "Apakah Anda yakin ingin keluar dari akun ini?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFE53E3E), // Warna merah
      onConfirm: () {
        // Nanti isi logic Supabase Auth SignOut di sini
        Get.offAllNamed('/login'); // Lempar kembali ke halaman login
      },
    );
  }
}