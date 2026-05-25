import 'package:get/get.dart';

class ChatMasyarakatItem {
  final String id;
  final String judulKasus;
  final String namaPosbankum; // POV Masyarakat, lawan bicaranya Posbankum
  final String pesanTerakhir;
  final String waktu;
  final int unreadCount;
  final String status;

  ChatMasyarakatItem({
    required this.id, required this.judulKasus, required this.namaPosbankum,
    required this.pesanTerakhir, required this.waktu, this.unreadCount = 0, required this.status,
  });
}

class DaftarChatMasyarakatController extends GetxController {
  var searchQuery = ''.obs;

  var chatList = <ChatMasyarakatItem>[
    ChatMasyarakatItem(
      id: '1',
      judulKasus: 'Kasus Penipuan Online',
      namaPosbankum: 'Posbakum Tuah Madani',
      pesanTerakhir: 'Bisa diceritakan lebih detail kronologinya?',
      waktu: '09:42',
      unreadCount: 1,
      status: 'Aktif',
    ),
    ChatMasyarakatItem(
      id: '2',
      judulKasus: 'Sengketa Tanah Waris',
      namaPosbankum: 'LBH Riau Mandiri',
      pesanTerakhir: 'Berkas sudah kami terima, silakan tunggu jadwal.',
      waktu: 'Kemarin',
      unreadCount: 0,
      status: 'Aktif',
    ),
  ].obs;

  List<ChatMasyarakatItem> get filteredChat {
    if (searchQuery.value.isEmpty) return chatList;
    return chatList.where((chat) =>
    chat.judulKasus.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        chat.namaPosbankum.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }
}