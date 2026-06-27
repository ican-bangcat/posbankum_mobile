import 'dart:io';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';
import '../models/pengaduan_models.dart';

class PengaduanRepository {
  final ApiService _apiService = ApiService();

  Future<List<PengaduanItem>> fetchDaftarPengaduan() async {
    final response = await _apiService.dio.get('/pengaduan');
    if (response.data['status'] == true) {
      final List<dynamic> resultData = response.data['data'];
      return resultData.map((e) => PengaduanItem.fromJson(e)).toList();
    } else {
      throw response.data['message'] ?? 'Gagal memuat daftar pengaduan';
    }
  }

  Future<Map<String, dynamic>> fetchRawDetailKasus(String id) async {
    final response = await _apiService.dio.get('/pengaduan/$id');
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memuat detail kasus';
    }
  }

  Future<List<LampiranItem>> fetchLampiranUrls(String id) async {
    final response = await _apiService.dio.get('/pengaduan/$id/lampiran');
    if (response.data['status'] == true) {
      return (response.data['data'] as List)
          .map((e) => LampiranItem(
                namaFile: e['nama_file'].toString(),
                pathFile: e['path_file'].toString(),
                mimeType: e['mime_type']?.toString(),
              ))
          .toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchTimeline(String id) async {
    final response = await _apiService.dio.get('/pengaduan/$id/timeline');
    if (response.data['status'] == true) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }
    return [];
  }

  Future<DetailKasus> fetchFullDetailKasus(String id) async {
    final detailData = await fetchRawDetailKasus(id);
    final lampiran = await fetchLampiranUrls(id);
    final timeline = await fetchTimeline(id);
    return DetailKasus.fromJson(detailData, lampiran, timeline);
  }

  Future<bool> batalkanPengaduan(String id) async {
    final response = await _apiService.dio.patch(
      '/pengaduan/$id/status',
      data: {
        'status': 'dibatalkan',
        'catatan_internal': 'Dibatalkan oleh Pelapor',
      },
    );
    return response.data['status'] == true;
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _apiService.dio.get('/profile');
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memuat profil';
    }
  }

  Future<Map<String, dynamic>> submitPengaduan(Map<String, dynamic> data) async {
    final response = await _apiService.dio.post('/pengaduan', data: data);
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal menyimpan pengaduan';
    }
  }

  Future<bool> uploadLampiran(String idPengaduan, File file, String fileName) async {
    dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
      'file': await dio_pkg.MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      'jenis_lampiran': 'bukti_awal',
    });

    final response = await _apiService.dio.post(
      '/pengaduan/$idPengaduan/lampiran',
      data: formData,
    );
    return response.data['status'] == true;
  }

  Future<void> downloadFile(String url, String savePath) async {
    await _apiService.dio.download(url, savePath);
  }
}
