import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- MODEL DATA CHAT ---
class ChatRoomItem {
  final String id;
  final String judulKasus;
  final String namaLawanBicara; // Bisa nama Klien / Advokat
  final String pesanTerakhir;
  final String waktuwaktu;
  final int unreadCount;
  final String status; // 'Aktif', 'Selesai', 'Menunggu'

  ChatRoomItem({
    required this.id,
    required this.judulKasus,
    required this.namaLawanBicara,
    required this.pesanTerakhir,
    required this.waktuwaktu,
    this.unreadCount = 0,
    required this.status,
  });
}

class DaftarChatParalegalController extends GetxController {
  var searchQuery = ''.obs;

  // Data Dummy persis seperti di desain UI-mu
  var chatList = <ChatRoomItem>[
    ChatRoomItem(
      id: '1',
      judulKasus: 'Kasus Penipuan Online',
      namaLawanBicara: 'M. Ikhsan (Klien)',
      pesanTerakhir: 'Bisa diceritakan lebih detail kronologinya?',
      waktuwaktu: '09:42',
      unreadCount: 2,
      status: 'Aktif',
    ),
    ChatRoomItem(
      id: '2',
      judulKasus: 'Sengketa Tanah - Tugu...',
      namaLawanBicara: 'Bapak Budi (Klien)',
      pesanTerakhir: 'Berkas sudah kami terima dan sedang direview.',
      waktuwaktu: 'Kemarin',
      unreadCount: 0,
      status: 'Aktif',
    ),
    ChatRoomItem(
      id: '3',
      judulKasus: 'Konsultasi KDRT',
      namaLawanBicara: 'Ibu Siti Aminah (Klien)',
      pesanTerakhir: '✓ Baik, terima kasih atas bantuannya pak.',
      waktuwaktu: '12 Okt',
      unreadCount: 0,
      status: 'Selesai',
    ),
    ChatRoomItem(
      id: '4',
      judulKasus: 'Sengketa Waris',
      namaLawanBicara: 'Keluarga Bpk. Santoso',
      pesanTerakhir: 'Mohon ditunggu jadwal mediasinya ya.',
      waktuwaktu: '05 Okt',
      unreadCount: 0,
      status: 'Menunggu',
    ),
  ].obs;

  // Fitur Pencarian
  List<ChatRoomItem> get filteredChat {
    if (searchQuery.value.isEmpty) return chatList;
    return chatList.where((chat) =>
    chat.judulKasus.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        chat.namaLawanBicara.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }
}