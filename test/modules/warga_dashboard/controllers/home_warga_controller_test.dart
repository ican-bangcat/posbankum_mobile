import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/warga_dashboard/controllers/home_warga_controller.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio.Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider MethodChannel untuk GetStorage ke folder terisolasi
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_home_warga_test_dir';
  });

  late MockApiService mockApiService;
  late MockDio mockDio;

  setUpAll(() async {
    await GetStorage.init();
  });

  setUp(() {
    Get.testMode = true;
    mockApiService = MockApiService();
    mockDio = MockDio();
    when(() => mockApiService.dio).thenReturn(mockDio);
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeWargaController', () {
    test('fetchDashboardData success populates dashboard stats and recentHistory', () async {
      final profileResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/profile'),
        data: {
          'status': true,
          'data': {
            'nama_lengkap': 'Warga Riau',
            'nomor_telepon': '081234567890',
            'masyarakat': {
              'nik': '1234567890123456',
              'alamat': 'Jalan Riau',
              'id_kelurahan': 'kel-123'
            }
          }
        },
        statusCode: 200,
      );

      final statsResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/pengaduan/statistik'),
        data: {
          'status': true,
          'data': {
            'menunggu': 1,
            'diproses': 2,
            'selesai': 3,
            'dibatalkan': 1,
          }
        },
        statusCode: 200,
      );

      final pengaduanResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/pengaduan'),
        data: {
          'status': true,
          'data': [
            {
              'id_pengaduan': '12345-abcde',
              'status': 'diproses',
              'judul_pengaduan': 'Sengketa Batas Tanah',
              'created_at': '2026-06-27T12:00:00Z'
            }
          ]
        },
        statusCode: 200,
      );

      when(() => mockDio.get('/profile')).thenAnswer((_) async => profileResponse);
      when(() => mockDio.get('/pengaduan/statistik')).thenAnswer((_) async => statsResponse);
      when(() => mockDio.get('/pengaduan')).thenAnswer((_) async => pengaduanResponse);

      final controller = HomeWargaController(apiService: mockApiService);
      await controller.fetchDashboardData();

      expect(controller.isLoadingData.value, isFalse);
      expect(controller.userName.value, 'Warga Riau');
      expect(controller.isProfileIncomplete.value, isFalse);
      expect(controller.countAktif.value, 3); // 1 menunggu + 2 diproses
      expect(controller.countSelesai.value, 3);
      expect(controller.recentHistory.length, 1);
      expect(controller.recentHistory.first['judul_pengaduan'], 'Sengketa Batas Tanah');
    });

    test('fetchDashboardData sets profile incomplete correctly when field is missing', () async {
      final profileResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/profile'),
        data: {
          'status': true,
          'data': {
            'nama_lengkap': 'Warga Riau',
            'nomor_telepon': '', // Incomplete
            'masyarakat': null
          }
        },
        statusCode: 200,
      );

      when(() => mockDio.get('/profile')).thenAnswer((_) async => profileResponse);
      when(() => mockDio.get('/pengaduan/statistik')).thenThrow('Mock error to skip remaining calls');

      final controller = HomeWargaController(apiService: mockApiService);
      await controller.fetchDashboardData();

      expect(controller.isLoadingData.value, isFalse);
      expect(controller.isProfileIncomplete.value, isTrue);
    });
  });
}
