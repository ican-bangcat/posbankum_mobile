import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/paralegal_dashboard/controllers/home_paralegal_controller.dart';
import 'package:posbankum/modules/paralegal_dashboard/controllers/paralegal_dashboard_controller.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio.Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider MethodChannel untuk GetStorage ke folder terisolasi
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_home_paralegal_test_dir';
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

  group('HomeParalegalController', () {
    test('fetchDashboardData success populates state metrics and recentActivities', () async {
      final profileResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/profile'),
        data: {
          'status': true,
          'data': {
            'nama_lengkap': 'Paralegal Riau',
          }
        },
        statusCode: 200,
      );

      final statsResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/pengaduan/statistik'),
        data: {
          'status': true,
          'data': {
            'menunggu': 2,
            'diproses': 4,
            'selesai': 5,
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
              'id_pengaduan': '1234-5678',
              'status': 'diproses',
              'judul_pengaduan': 'Kasus Kekerasan Rumah Tangga',
              'created_at': '2026-06-27T12:00:00Z'
            }
          ]
        },
        statusCode: 200,
      );

      when(() => mockDio.get('/profile')).thenAnswer((_) async => profileResponse);
      when(() => mockDio.get('/pengaduan/statistik')).thenAnswer((_) async => statsResponse);
      when(() => mockDio.get('/pengaduan')).thenAnswer((_) async => pengaduanResponse);

      final controller = HomeParalegalController(apiService: mockApiService);
      await controller.fetchDashboardData();

      expect(controller.isLoadingData.value, isFalse);
      expect(controller.userName.value, 'Paralegal Riau');
      expect(controller.countPending.value, 2);
      expect(controller.countProses.value, 4);
      expect(controller.countSelesai.value, 5);
      expect(controller.recentActivities.length, 1);
      expect(controller.recentActivities.first['judul_pengaduan'], 'Kasus Kekerasan Rumah Tangga');
    });

    test('ParalegalDashboardController changeTab updates selectedIndex', () {
      final controller = ParalegalDashboardController();
      expect(controller.selectedIndex.value, 2);

      controller.changeTab(0);
      expect(controller.selectedIndex.value, 0);
    });
  });
}
