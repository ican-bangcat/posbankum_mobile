import 'dart:io';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';

class KelolaPengaduanRepository {
  final ApiService _apiService;

  KelolaPengaduanRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Simpan progres timeline dan kembalikan id_timeline untuk upload lampiran.
  Future<String> simpanProgresTimeline({
    required String kasusId,
    required String title,
    required String deskripsi,
    required String tanggal,
  }) async {
    final response = await _apiService.dio.post(
      '/pengaduan/$kasusId/timeline',
      data: {
        'title': title,
        'deskripsi': deskripsi,
        'tanggal': tanggal,
      },
    );
    if (response.data['status'] != true) {
      throw response.data['message'] ?? 'Gagal menyimpan progres timeline';
    }
    // Ambil id_timeline dari response backend
    return response.data['data']['id_timeline']?.toString() ?? '';
  }

  /// Upload lampiran progres (gambar/PDF) yang terhubung ke entry timeline tertentu.
  Future<bool> uploadLampiranProgres({
    required String kasusId,
    required String idTimeline,
    required File file,
    required String fileName,
  }) async {
    dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
      'file': await dio_pkg.MultipartFile.fromFile(file.path, filename: fileName),
      'jenis_lampiran': 'progress',
      'id_timeline': idTimeline,
    });
    final response = await _apiService.dio.post(
      '/pengaduan/$kasusId/lampiran',
      data: formData,
    );
    return response.data['status'] == true;
  }

  Future<void> updateStatusKasus({
    required String kasusId,
    required String status,
    required String catatanInternal,
  }) async {
    final response = await _apiService.dio.patch(
      '/pengaduan/$kasusId/status',
      data: {
        'status': status,
        'catatan_internal': catatanInternal,
      },
    );
    if (response.data['status'] != true) {
      throw response.data['message'] ?? 'Gagal memperbarui status pengaduan';
    }
  }
}

