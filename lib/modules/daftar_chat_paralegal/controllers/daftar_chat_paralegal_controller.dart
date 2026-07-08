import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/chat_room_paralegal_model.dart';
import '../repositories/daftar_chat_paralegal_repository.dart';

class DaftarChatParalegalController extends GetxController {
  final DaftarChatParalegalRepository _repository;
  final GetStorage _storage;
  Timer? _timer;

  DaftarChatParalegalController({
    DaftarChatParalegalRepository? repository,
    GetStorage? storage,
  })  : _repository = repository ?? DaftarChatParalegalRepository(),
        _storage = storage ?? GetStorage();

  var searchQuery = ''.obs;
  var chatList = <ChatRoomItem>[].obs;
  var isLoading = true.obs;
  String _currentUserId = '';

  @override
  void onInit() {
    super.onInit();
    final user = _storage.read('user');
    _currentUserId = (user?['id_user'] ?? '').toString();

    fetchDaftarChatParalegal();
    // Refresh daftar chat setiap 10 detik
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchDaftarChatParalegal(silent: true));
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchDaftarChatParalegal({bool silent = false}) async {
    try {
      if (!silent && chatList.isEmpty) isLoading.value = true;

      final listKasus = await _repository.fetchComplaints();

      // Filter: Kasus status 'diproses' dan id_paralegal == currentUserId
      final filteredKasus = listKasus.where((item) {
        final status = (item['status'] ?? '').toString().toLowerCase();
        final idParalegal = (item['id_paralegal'] ?? '').toString();
        return status == 'diproses' && idParalegal == _currentUserId;
      }).toList();

      final List<ChatRoomItem> mappedList = [];

      for (var item in filteredKasus) {
        final idPengaduan = item['id_pengaduan']?.toString() ?? '';
        final judulKasus = item['judul_pengaduan'] ?? item['jenis_masalah'] ?? 'Kasus Hukum';
        final namaPelapor = item['nama_pelapor'] ?? 'Klien';
        final rawMsg = item['last_message']?.toString() ?? '';
        final fotoLawanBicara = item['foto_profile_lawan_bicara']?.toString() ?? '';
        
        // Unread count
        final int unreadVal = int.tryParse(item['unread_count']?.toString() ?? '0') ?? 0;

        String lastMsg = 'Belum ada obrolan';
        if (rawMsg.isNotEmpty) {
          if (rawMsg.startsWith('[FILE]')) {
            lastMsg = '📎 Mengirim berkas';
          } else {
            lastMsg = rawMsg;
          }
        }

        String timeStr = '';
        DateTime? lastMsgTime;

        if (item['last_message_time'] != null) {
          try {
            String rawTime = item['last_message_time'].toString();
            if (!rawTime.endsWith('Z') && !rawTime.contains('+')) {
              rawTime += 'Z'; // Server menyimpan dalam UTC
            }
            final dt = DateTime.parse(rawTime).toLocal();
            lastMsgTime = dt;
            final now = DateTime.now();
            if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
              timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
            } else {
              timeStr = "${dt.day} ${_getMonthName(dt.month)}";
            }
          } catch (_) {}
        }

        mappedList.add(ChatRoomItem(
          id: idPengaduan,
          judulKasus: judulKasus,
          namaLawanBicara: "$namaPelapor (Klien)",
          pesanTerakhir: lastMsg,
          waktuwaktu: timeStr.isNotEmpty ? timeStr : '-',
          unreadCount: unreadVal,
          status: 'Aktif',
          lastMsgTime: lastMsgTime,
          fotoLawanBicara: fotoLawanBicara,
        ));
      }

      // Sort: chat dengan pesan terbaru di atas
      mappedList.sort((a, b) {
        if (a.lastMsgTime == null && b.lastMsgTime == null) return 0;
        if (a.lastMsgTime == null) return 1;
        if (b.lastMsgTime == null) return -1;
        return b.lastMsgTime!.compareTo(a.lastMsgTime!);
      });

      chatList.assignAll(mappedList);
    } catch (e) {
      print("❌ Error fetch daftar chat paralegal: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  // Fitur Pencarian
  List<ChatRoomItem> get filteredChat {
    if (searchQuery.value.isEmpty) return chatList;
    return chatList.where((chat) =>
      chat.judulKasus.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      chat.namaLawanBicara.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }
}