import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessageMasyarakat {
  final String text;
  final bool isSender; // true = Masyarakat (Kanan), false = Posbankum (Kiri)
  final String time;
  final bool isRead;

  ChatMessageMasyarakat({required this.text, required this.isSender, required this.time, this.isRead = false});
}

class DetailChatMasyarakatController extends GetxController {
  final chatInputC = TextEditingController();

  final String namaPosbankum = "Posbakum Tuah Madani";
  final String statusPosbankum = "Online";

  // Logika dibalik: Sekarang Masyarakat di kanan (true), Paralegal di kiri (false)
  var messages = <ChatMessageMasyarakat>[
    ChatMessageMasyarakat(
      text: 'Halo Bapak/Ibu. Saya paralegal dari Posbakum Tuah Madani. Saya telah meninjau laporan Anda.',
      isSender: false, // Dari Paralegal (Kiri)
      time: '09:41',
    ),
    ChatMessageMasyarakat(
      text: 'Selamat pagi. Sejak tanggal 3 Oktober dana sudah tertahan dan akun saya dibekukan.',
      isSender: true, // Dari Masyarakat (Kanan)
      time: '09:45',
      isRead: true,
    ),
    ChatMessageMasyarakat(
      text: 'Baik, bisa dikirimkan bukti transfer terakhirnya?',
      isSender: false, // Dari Paralegal (Kiri)
      time: '09:46',
    ),
  ].obs;

  @override
  void onClose() {
    chatInputC.dispose();
    super.onClose();
  }

  void kirimPesan() {
    if (chatInputC.text.trim().isNotEmpty) {
      messages.add(
        ChatMessageMasyarakat(text: chatInputC.text.trim(), isSender: true, time: '10:00', isRead: false),
      );
      chatInputC.clear();
    }
  }
}