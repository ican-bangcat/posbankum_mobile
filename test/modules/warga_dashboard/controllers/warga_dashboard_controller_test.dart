import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/warga_dashboard/controllers/warga_dashboard_controller.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio.Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider MethodChannel untuk GetStorage ke folder terisolasi
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_warga_dashboard_test_dir';
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

  group('WargaDashboardController', () {
    test('changeTab updates selectedIndex', () {
      final controller = WargaDashboardController(apiService: mockApiService);
      expect(controller.selectedIndex.value, 2);

      controller.changeTab(1);
      expect(controller.selectedIndex.value, 1);
    });

    test('checkProfileCompleteness success sets observables correctly', () async {
      final response = dio.Response(
        requestOptions: dio.RequestOptions(path: '/profile'),
        data: {
          'status': true,
          'data': {
            'nama_lengkap': 'Warga Riau',
            'nomor_telepon': '081234567890',
            'role': 'warga',
            'masyarakat': {
              'nik': '1234567890123456',
              'alamat': 'Jalan Riau',
              'id_kabupaten': 'kab-123',
              'id_kecamatan': 'kec-456',
              'id_kelurahan': 'kel-789'
            }
          }
        },
        statusCode: 200,
      );

      when(() => mockDio.get('/profile')).thenAnswer((_) async => response);

      final controller = WargaDashboardController(apiService: mockApiService);
      await controller.checkProfileCompleteness();

      expect(controller.isProfileChecking.value, isFalse);
      expect(controller.isNamaComplete.value, isTrue);
      expect(controller.isTeleponComplete.value, isTrue);
      expect(controller.isNikComplete.value, isTrue);
      expect(controller.isAlamatComplete.value, isTrue);
      expect(controller.isAllComplete, isTrue);
    });
  });
}
