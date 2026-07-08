import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';

class DaftarChatParalegalRepository {
  final ApiService _apiService;

  DaftarChatParalegalRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<dynamic>> fetchComplaints() async {
    final response = await _apiService.dio.get('/pengaduan');
    if (response.data['status'] == true) {
      return response.data['data'] ?? [];
    }
    throw response.data['message'] ?? 'Gagal mengambil daftar pengaduan';
  }

  Future<List<dynamic>> fetchMessages(String idPengaduan) async {
    final response = await _apiService.dio.get('/chat/$idPengaduan');
    if (response.data['status'] == true) {
      return response.data['data'] ?? [];
    }
    throw response.data['message'] ?? 'Gagal mengambil pesan';
  }

  Future<bool> sendMessage(String idPengaduan, String text) async {
    final response = await _apiService.dio.post(
      '/chat/$idPengaduan',
      data: {'pesan': text},
    );
    return response.data['status'] == true;
  }

  Future<Map<String, dynamic>> uploadAttachment(String idPengaduan, String filePath, String fileName) async {
    final dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
      'file': await dio_pkg.MultipartFile.fromFile(filePath, filename: fileName),
      'jenis_lampiran': 'chat',
    });

    final response = await _apiService.dio.post(
      '/pengaduan/$idPengaduan/lampiran',
      data: formData,
    );

    if (response.data['status'] == true) {
      return response.data['data'] ?? {};
    }
    throw response.data['message'] ?? 'Gagal mengunggah berkas';
  }

  Future<String> fetchLawanBicaraProfile(String idPengaduan) async {
    final response = await _apiService.dio.get('/pengaduan/$idPengaduan');
    if (response.data['status'] == true) {
      final data = response.data['data'] ?? {};
      return data['foto_profile_pelapor'] ?? '';
    }
    return '';
  }
}
