import '../../../app/data/services/api_service.dart';
import '../models/notifikasi_model.dart';

class NotifikasiRepository {
  final ApiService _apiService;

  NotifikasiRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<NotifikasiItem>> fetchNotifikasi() async {
    final response = await _apiService.dio.get('/notifikasi');
    if (response.data['status'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => NotifikasiItem.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      throw response.data['message'] ?? 'Gagal mengambil notifikasi';
    }
  }

  Future<bool> markAsRead(String id) async {
    final response = await _apiService.dio.patch('/notifikasi/$id/read');
    return response.data['status'] == true;
  }

  Future<int> fetchUnreadCount() async {
    try {
      final response = await _apiService.dio.get('/notifikasi/unread-count');
      if (response.data['status'] == true) {
        return response.data['data']['unread_count'] as int;
      }
    } catch (_) {}
    return 0;
  }

  Future<bool> markAllAsRead() async {
    final response = await _apiService.dio.patch('/notifikasi/read-all');
    return response.data['status'] == true;
  }
}
