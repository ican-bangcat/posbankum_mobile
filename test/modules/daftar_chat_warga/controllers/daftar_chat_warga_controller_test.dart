import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart';
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/daftar_chat_warga/controllers/daftar_chat_warga_controller.dart';
import 'package:posbankum/modules/daftar_chat_warga/repositories/daftar_chat_warga_repository.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio_pkg.Dio {}

void main() {
  late MockApiService mockApiService;
  late MockDio mockDio;
  late DaftarChatWargaRepository repository;

  setUp(() {
    Get.testMode = true;
    mockApiService = MockApiService();
    mockDio = MockDio();
    when(() => mockApiService.dio).thenReturn(mockDio);
    repository = DaftarChatWargaRepository(apiService: mockApiService);
  });

  tearDown(() {
    Get.reset();
  });

  group('DaftarChatWargaController', () {
    test('fetchDaftarChatBerjalan success filters status diproses and maps data', () async {
      final mockResponse = {
        'status': true,
        'data': [
          {
            'id_pengaduan': 101,
            'judul_pengaduan': 'Sengketa Waris',
            'jenis_masalah': 'Perdata',
            'status': 'diproses',
            'paralegal': {'nama_lengkap': 'Paralegal Ahmad'},
          },
          {
            'id_pengaduan': 102,
            'judul_pengaduan': 'Kekerasan Rumah Tangga',
            'jenis_masalah': 'Pidana',
            'status': 'menunggu', // Harus difilter (bukan diproses)
            'paralegal': null,
          }
        ]
      };

      when(() => mockDio.get('/pengaduan')).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/pengaduan'),
          data: mockResponse,
          statusCode: 200,
        ),
      );

      final controller = DaftarChatWargaController(repository: repository);
      await controller.fetchDaftarChatBerjalan();

      expect(controller.isLoading.value, isFalse);
      expect(controller.acceptedComplaints.length, 1);
      expect(controller.acceptedComplaints[0].id, '101');
      expect(controller.acceptedComplaints[0].judulLaporan, 'Sengketa Waris');
      expect(controller.acceptedComplaints[0].namaParalegalDitugaskan, 'Paralegal Ahmad');
    });

    test('fetchDaftarChatBerjalan handles error safely', () async {
      when(() => mockDio.get('/pengaduan')).thenThrow(
        dio_pkg.DioException(
          requestOptions: dio_pkg.RequestOptions(path: '/pengaduan'),
          message: 'Network Error',
        ),
      );

      final controller = DaftarChatWargaController(repository: repository);
      await controller.fetchDaftarChatBerjalan();

      expect(controller.isLoading.value, isFalse);
      expect(controller.acceptedComplaints, isEmpty);
    });
  });
}
