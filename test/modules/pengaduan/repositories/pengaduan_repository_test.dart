import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/pengaduan/repositories/pengaduan_repository.dart';
import 'package:posbankum/modules/pengaduan/models/pengaduan_models.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio.Dio {}

void main() {
  late MockApiService mockApiService;
  late MockDio mockDio;
  late PengaduanRepository repository;

  setUp(() {
    mockApiService = MockApiService();
    mockDio = MockDio();
    when(() => mockApiService.dio).thenReturn(mockDio);
    repository = PengaduanRepository(apiService: mockApiService);
  });

  group('PengaduanRepository', () {
    group('fetchDaftarPengaduan', () {
      test('returns List<PengaduanItem> on success', () async {
        final mockResponse = dio.Response(
          requestOptions: dio.RequestOptions(path: '/pengaduan'),
          data: {
            'status': true,
            'data': [
              {
                'id_pengaduan': '1',
                'nomor_pengaduan': 'PGN-1',
                'judul_pengaduan': 'Test Judul',
                'created_at': '2026-06-25T12:00:00Z',
                'jenis_masalah': 'Narkotika',
                'status': 'menunggu'
              }
            ]
          },
          statusCode: 200,
        );

        when(() => mockDio.get('/pengaduan')).thenAnswer((_) async => mockResponse);

        final result = await repository.fetchDaftarPengaduan();

        expect(result, isA<List<PengaduanItem>>());
        expect(result.length, 1);
        expect(result.first.judul, 'Test Judul');
        expect(result.first.idDb, '1');
        verify(() => mockDio.get('/pengaduan')).called(1);
      });

      test('throws string message on failure', () async {
        final mockResponse = dio.Response(
          requestOptions: dio.RequestOptions(path: '/pengaduan'),
          data: {'status': false, 'message': 'API Error'},
          statusCode: 400,
        );

        when(() => mockDio.get('/pengaduan')).thenAnswer((_) async => mockResponse);

        expect(() => repository.fetchDaftarPengaduan(), throwsA('API Error'));
      });
    });

    group('fetchRawDetailKasus', () {
      test('returns data map on success', () async {
        final mockResponse = dio.Response(
          requestOptions: dio.RequestOptions(path: '/pengaduan/1'),
          data: {
            'status': true,
            'data': {'id_pengaduan': '1', 'judul_pengaduan': 'Test Detail'}
          },
          statusCode: 200,
        );

        when(() => mockDio.get('/pengaduan/1')).thenAnswer((_) async => mockResponse);

        final result = await repository.fetchRawDetailKasus('1');

        expect(result, isA<Map<String, dynamic>>());
        expect(result['judul_pengaduan'], 'Test Detail');
      });
    });

    group('batalkanPengaduan', () {
      test('returns true on successful cancellation', () async {
        final mockResponse = dio.Response(
          requestOptions: dio.RequestOptions(path: '/pengaduan/1/status'),
          data: {'status': true},
          statusCode: 200,
        );

        when(() => mockDio.patch('/pengaduan/1/status', data: any(named: 'data')))
            .thenAnswer((_) async => mockResponse);

        final result = await repository.batalkanPengaduan('1');

        expect(result, isTrue);
      });
    });
  });
}
