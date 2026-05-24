import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isSender; // true = Paralegal (kanan), false = Klien (kiri)
  final String time;
  final bool isRead; // true = centang biru ganda, false = centang abu tunggal

  ChatMessage({
    required this.text,
    required this.isSender,
    required this.time,
    this.isRead = false,
  });
}

class DetailChatParalegalController extends GetxController {
  final chatInputC = TextEditingController();

  // Data informasi Klien
  final String namaKlien = "Bapak Budi (Klien)";
  final String statusKlien = "Online";

  // Data Dummy Pesan
  var messages = <ChatMessage>[
    ChatMessage(
      text: 'Halo Bapak Budi. Saya paralegal dari Posbankum. Saya telah meninjau laporan Anda terkait kasus penipuan online.',
      isSender: true,
      time: '09:41',
      isRead: true,
    ),
    ChatMessage(
      text: 'Bisa diceritakan lebih detail sejak kapan Anda tidak bisa menarik dana tersebut?',
      isSender: true,
      time: '09:42',
      isRead: true,
    ),
    ChatMessage(
      text: 'Selamat pagi Pak. Sejak tanggal 3 Oktober dana sudah tertahan dan akun saya dibekukan secara sepihak.',
      isSender: false,
      time: '09:45',
    ),
    ChatMessage(
      text: 'Saya sudah mencoba menghubungi customer service mereka tapi nomor saya diblokir.',
      isSender: false,
      time: '09:46',
    ),
  ].obs;

  @override
  void onClose() {
    chatInputC.dispose();
    super.onClose();
  }

  // Fungsi dummy buat kirim pesan
  void kirimPesan() {
    if (chatInputC.text.trim().isNotEmpty) {
      messages.add(
        ChatMessage(
          text: chatInputC.text.trim(),
          isSender: true,
          time: '15:07', // Dummy waktu sekarang
          isRead: false,
        ),
      );
      chatInputC.clear();
    }
  }
}