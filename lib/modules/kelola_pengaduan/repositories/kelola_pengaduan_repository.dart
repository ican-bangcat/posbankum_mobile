import '../../../app/data/services/api_service.dart';

class KelolaPengaduanRepository {
  final ApiService _apiService;

  KelolaPengaduanRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<void> simpanProgresTimeline({
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
