import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/kelola_pengaduan/controllers/detail_kasus_paralegal_controller.dart';

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
  });

  tearDown(() {
    Get.reset();
  });

  group('DetailKasusParalegalController', () {
    test('initializes and fails to load with missing arguments', () async {
      final controller = DetailKasusParalegalController(apiService: mockApiService);
      controller.onInit();
      expect(controller.errorMessage.value, contains("ID Kasus hilang"));
      expect(controller.isLoading.value, isFalse);
    });

    test('fetchDetailKasus fetches details, attachments, and timeline successfully', () async {
      final detailResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/pengaduan/1'),
        data: {
          'status': true,
          'data': {
            'id_pengaduan': '1',
            'nomor_pengaduan': 'PGN-1',
            'judul_pengaduan': 'Tanah Waris',
            'jenis_masalah': 'Perdata',
            'status': 'menunggu',
            'prioritas': 'Tinggi',
            'tanggal_kejadian': '2026-06-25',
            'created_at': '2026-06-25T12:00:00Z',
            'nama_pelapor': 'Pelapor A',
            'nik': '1234567890123456',
            'nomor_telepon': '08123456',
            'deskripsi_kronologi': 'Detail kronologi kejadian.',
          }
        },
        statusCode: 200,
      );

      final lampiranResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/pengaduan/1/lampiran'),
        data: {'status': true, 'data': []},
        statusCode: 200,
      );

      final timelineResponse = dio.Response(
        requestOptions: dio.RequestOptions(path: '/pengaduan/1/timeline'),
        data: {'status': true, 'data': []},
        statusCode: 200,
      );

      when(() => mockDio.get('/pengaduan/1')).thenAnswer((_) async => detailResponse);
      when(() => mockDio.get('/pengaduan/1/lampiran')).thenAnswer((_) async => lampiranResponse);
      when(() => mockDio.get('/pengaduan/1/timeline')).thenAnswer((_) async => timelineResponse);

      final controller = DetailKasusParalegalController(apiService: mockApiService, kasusId: '1');
      await controller.fetchDetailKasus('1');

      expect(controller.kasus, isNotNull);
      expect(controller.kasus!.judul, 'Tanah Waris');
      expect(controller.isLoading.value, isFalse);
      expect(controller.listProgres.length, 1); // contains dynamically generated "Pengaduan diajukan"
    });
  });
}
