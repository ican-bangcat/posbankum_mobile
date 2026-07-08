import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';

class ChatMessageMasyarakat {
  final String text;
  final bool isSender; // true = Masyarakat (Kanan), false = Posbankum (Kiri)
  final String time;
  final bool isRead;

  ChatMessageMasyarakat({required this.text, required this.isSender, required this.time, this.isRead = false});
}

class DetailChatMasyarakatController extends GetxController {
  final chatInputC = TextEditingController();
  final scrollController = ScrollController();
  final ApiService _apiService;
  final GetStorage _storage;
  final bool testMode;

  DetailChatMasyarakatController({
    ApiService? apiService,
    GetStorage? storage,
    this.testMode = false,
  })  : _apiService = apiService ?? ApiService(),
        _storage = storage ?? GetStorage();

  late String idPengaduan;
  late String judulLaporan;
  late String namaParalegal;
  final String statusPosbankum = "Online";
  var fotoLawanBicara = ''.obs;

  var messages = <ChatMessageMasyarakat>[].obs;
  var isLoading = true.obs;
  Timer? _pollingTimer;
  String _currentUserId = '';

  @override
  void onInit() {
    super.onInit();
    
    // Ambil data user yang sedang login
    final user = _storage.read('user');
    _currentUserId = (user?['id_user'] ?? '').toString();

    // Mengambil arguments dari navigasi
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    idPengaduan = args['id_pengaduan']?.toString() ?? '';
    judulLaporan = args['judul_laporan']?.toString() ?? 'Konsultasi Hukum';
    namaParalegal = args['nama_paralegal']?.toString() ?? 'Paralegal Posbankum';

    if (idPengaduan.isNotEmpty) {
      fetchMessages();
      fetchLawanBicaraProfile();
      // Setup Polling tiap 3 detik
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => fetchMessages(silent: true));
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    chatInputC.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Mengambil riwayat pesan dari server
  Future<void> fetchMessages({bool silent = false}) async {
    if (idPengaduan.isEmpty) return;
    try {
      if (!silent && messages.isEmpty) isLoading.value = true;

      final response = await _apiService.dio.get('/chat/$idPengaduan');

      if (response.data['status'] == true) {
        final List<dynamic> listPesan = response.data['data'] ?? [];
        final previousCount = messages.length;

        final mapped = listPesan.map((item) {
          final text = item['isi_pesan']?.toString() ?? '';
          final senderId = item['pengirim_id']?.toString() ?? '';
          final bool isSender = senderId == _currentUserId;

          String formattedTime = '';
          if (item['created_at'] != null) {
            try {
              String rawTime = item['created_at'].toString();
              if (!rawTime.endsWith('Z') && !rawTime.contains('+')) {
                rawTime += 'Z'; // Server menyimpan dalam UTC
              }
              final dt = DateTime.parse(rawTime).toLocal();
              formattedTime = DateFormat('HH:mm').format(dt);
            } catch (_) {}
          }

          return ChatMessageMasyarakat(
            text: text,
            isSender: isSender,
            time: formattedTime,
            isRead: true, // Backend saat ini tidak tracking read status, default true
          );
        }).toList();

        messages.assignAll(mapped);

        // Auto scroll ke bawah jika ada pesan baru
        if (messages.length > previousCount) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollToBottom();
          });
        }
      }
    } catch (e) {
      print("❌ Error fetch messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Mengirim pesan teks ke server
  Future<void> kirimPesan() async {
    final isiPesan = chatInputC.text.trim();
    if (isiPesan.isEmpty || idPengaduan.isEmpty) return;

    chatInputC.clear();

    try {
      final response = await _apiService.dio.post(
        '/chat/$idPengaduan',
        data: {'pesan': isiPesan},
      );

      if (response.data['status'] == true) {
        // Refresh langsung setelah mengirim pesan
        fetchMessages(silent: true);
      }
    } catch (e) {
      if (!testMode) {
        Get.snackbar("Error", "Gagal mengirim pesan: $e", backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  // Pilih & Unggah Media (Gambar/PDF)
  Future<void> pilihDanKirimMedia(bool isCamera) async {
    if (idPengaduan.isEmpty) return;
    try {
      File? file;
      String? fileName;

      if (isCamera) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
        if (pickedFile != null) {
          file = File(pickedFile.path);
          fileName = pickedFile.name;
        }
      } else {
        // Tampilkan pilihan picker: Galeri (Foto) atau Document
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        );
        if (result != null && result.files.single.path != null) {
          file = File(result.files.single.path!);
          fileName = result.files.single.name;
        }
      }

      if (file == null || fileName == null) return;

      if (!testMode) {
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: Colors.white)),
          barrierDismissible: false,
        );
      }

      // 1. Upload ke API Lampiran
      final dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
        'file': await dio_pkg.MultipartFile.fromFile(file.path, filename: fileName),
        'jenis_lampiran': 'chat',
      });

      final uploadResponse = await _apiService.dio.post(
        '/pengaduan/$idPengaduan/lampiran',
        data: formData,
      );

      if (!testMode) Get.back(); // Tutup loading dialog

      if (uploadResponse.data['status'] == true) {
        final uploadData = uploadResponse.data['data'];
        final secureUrl = uploadData['path_file'] ?? '';

        // 2. Kirim pesan chat dengan format khusus [FILE]
        final String fileMessage = "[FILE]$fileName|$secureUrl";
        
        await _apiService.dio.post(
          '/chat/$idPengaduan',
          data: {'pesan': fileMessage},
        );

        fetchMessages(silent: true);
      } else {
        throw uploadResponse.data['message'] ?? 'Gagal mengunggah berkas';
      }
    } catch (e) {
      if (!testMode) {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar("Error Upload", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> fetchLawanBicaraProfile() async {
    if (idPengaduan.isEmpty) return;
    try {
      final response = await _apiService.dio.get('/pengaduan/$idPengaduan');
      if (response.data['status'] == true) {
        final data = response.data['data'];
        fotoLawanBicara.value = data['foto_profile_paralegal'] ?? '';
      }
    } catch (_) {}
  }
}