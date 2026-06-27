import '../../../app/data/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final response = await _apiService.dio.post('/auth/google/callback', data: {
      'id_token': idToken,
    });
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Gagal otorisasi Google.';
    }
  }

  Future<Map<String, dynamic>> loginManual(String email, String password) async {
    final response = await _apiService.dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Login manual gagal.';
    }
  }

  Future<Map<String, dynamic>> registerManual(String name, String email, String password) async {
    final response = await _apiService.dio.post('/register', data: {
      'nama_lengkap': name,
      'email': email,
      'password': password,
    });
    if (response.data['status'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw response.data['message'] ?? 'Registrasi manual gagal.';
    }
  }

  Future<void> logout() async {
    await _apiService.dio.post('/logout');
  }
}
