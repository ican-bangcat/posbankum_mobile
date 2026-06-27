import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _apiService.dio.get('/profile');
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memuat profil';
    }
  }

  Future<Map<String, dynamic>> fetchStatistik() async {
    final response = await _apiService.dio.get('/pengaduan/statistik');
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memuat statistik';
    }
  }

  Future<List<dynamic>> fetchRiwayatPengaduan() async {
    final response = await _apiService.dio.get('/pengaduan');
    if (response.data['status'] == true) {
      return response.data['data'] as List<dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memuat riwayat pengaduan';
    }
  }

  Future<List<dynamic>> fetchKabupaten() async {
    final response = await _apiService.dio.get('/wilayah/kabupaten');
    if (response.data['status'] == true) {
      return response.data['data'] as List<dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memuat data kabupaten';
    }
  }

  Future<List<dynamic>> fetchKecamatan(String kabId) async {
    final response = await _apiService.dio.get(
      '/wilayah/kecamatan',
      queryParameters: {'id_kabupaten': kabId},
    );
    if (response.data['status'] == true) {
      return response.data['data'] as List<dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memuat data kecamatan';
    }
  }

  Future<List<dynamic>> fetchKelurahan(String kecId) async {
    final response = await _apiService.dio.get(
      '/wilayah/kelurahan',
      queryParameters: {'id_kecamatan': kecId},
    );
    if (response.data['status'] == true) {
      return response.data['data'] as List<dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memuat data kelurahan';
    }
  }

  Future<Map<String, dynamic>> uploadFotoProfil(dio_pkg.FormData formData) async {
    final response = await _apiService.dio.post(
      '/upload/foto-profil',
      data: formData,
    );
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal mengunggah foto profil';
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiService.dio.put('/profile', data: data);
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal memperbarui profil';
    }
  }
}
