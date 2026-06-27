import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/kelola_pengaduan/controllers/kelola_pengaduan_controller.dart';
import 'package:posbankum/modules/kelola_pengaduan/models/kasus_model.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio.Dio {}

void main() {
  late MockApiService mockApiService;
  late MockDio mockDio;

  setUp(() {
    Get.testMode = true;
    mockApiService = MockApiService();
    mockDio = MockDio();
    when(() => mockApiService.dio).thenReturn(mockDio);

    final mockResponse = dio.Response(
      requestOptions: dio.RequestOptions(path: '/pengaduan'),
      data: {'status': true, 'data': []},
      statusCode: 200,
    );
    when(() => mockDio.get('/pengaduan', queryParameters: any(named: 'queryParameters')))
        .thenAnswer((_) async => mockResponse);
  });

  tearDown(() {
    Get.reset();
  });

  group('KelolaPengaduanController', () {
    test('initializes and calls fetchPengaduan on init', () async {
      final controller = KelolaPengaduanController(apiService: mockApiService);
      controller.onInit();
      verify(() => mockDio.get('/pengaduan', queryParameters: any(named: 'queryParameters'))).called(1);
      expect(controller.isLoading.value, isTrue);
    });

    test('fetchPengaduan populates cases list on success', () async {
      final mockResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/pengaduan'),
        data: {
          'status': true,
          'data': [
            {
              'id_pengaduan': '1',
              'nomor_pengaduan': 'PGN-1',
              'judul_pengaduan': 'Sengketa Tanah',
              'jenis_masalah': 'Sengketa',
              'status': 'menunggu',
              'prioritas': 'Tinggi',
              'tanggal_kejadian': '2026-06-25',
              'created_at': '2026-06-25T12:00:00Z',
              'nama_pelapor': 'Warga A',
            }
          ]
        },
        statusCode: 200,
      );

      when(() => mockDio.get('/pengaduan', queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final controller = KelolaPengaduanController(apiService: mockApiService);
      await controller.fetchPengaduan();

      expect(controller.allKasus.length, 1);
      expect(controller.allKasus.first.judul, 'Sengketa Tanah');
      expect(controller.isLoading.value, isFalse);
    });

    test('changeTab updates active tab selection', () {
      final controller = KelolaPengaduanController(apiService: mockApiService);
      expect(controller.selectedTab.value, 0);

      controller.changeTab(2);
      expect(controller.selectedTab.value, 2);
    });

    test('resetFilters resets the filter values to default', () {
      final controller = KelolaPengaduanController(apiService: mockApiService);
      controller.sortBy.value = 'newest';
      controller.filterPriority.value = 'Tinggi';

      controller.resetFilters();

      expect(controller.sortBy.value, 'priority');
      expect(controller.filterPriority.value, 'Semua');
    });
  });
}
