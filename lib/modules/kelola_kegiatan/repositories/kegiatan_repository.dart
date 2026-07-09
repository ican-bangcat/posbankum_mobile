import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';
import '../models/kegiatan_model.dart';

class KegiatanRepository {
  final ApiService _apiService;

  KegiatanRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<KegiatanItem>> fetchKegiatan() async {
    final response = await _apiService.dio.get('/kegiatan');
    if (response.data['status'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => KegiatanItem.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      throw response.data['message'] ?? 'Gagal mengambil kegiatan';
    }
  }

  Future<KegiatanItem> fetchDetailKegiatan(String id) async {
    final response = await _apiService.dio.get('/kegiatan/$id');
    if (response.data['status'] == true) {
      return KegiatanItem.fromJson(Map<String, dynamic>.from(response.data['data']));
    } else {
      throw response.data['message'] ?? 'Gagal mengambil detail kegiatan';
    }
  }

  Future<bool> simpanKegiatan(dio_pkg.FormData formData) async {
    final response = await _apiService.dio.post('/kegiatan', data: formData);
    return response.data['status'] == true;
  }

  Future<bool> updateKegiatan(String id, dio_pkg.FormData formData) async {
    final response = await _apiService.dio.post('/kegiatan/$id', data: formData);
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

  Future<Map<String, dynamic>> fetchPosbankum(String idPosbankum) async {
    final response = await _apiService.dio.get('/posbankum/$idPosbankum');
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memuat data Posbankum';
    }
  }
}
