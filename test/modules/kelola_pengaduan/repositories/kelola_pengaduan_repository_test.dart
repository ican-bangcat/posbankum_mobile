import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/kelola_pengaduan/repositories/kelola_pengaduan_repository.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio.Dio {}

void main() {
  late MockApiService mockApiService;
  late MockDio mockDio;
  late KelolaPengaduanRepository repository;

  setUp(() {
    mockApiService = MockApiService();
    mockDio = MockDio();
    when(() => mockApiService.dio).thenReturn(mockDio);
    repository = KelolaPengaduanRepository(apiService: mockApiService);
  });

  group('KelolaPengaduanRepository', () {
    group('simpanProgresTimeline', () {
      test('completes successfully when API returns status true', () async {
        final mockResponse = dio.Response(
          requestOptions: dio.RequestOptions(path: '/pengaduan/1/timeline'),
          data: {'status': true},
          statusCode: 200,
        );

        when(() => mockDio.post('/pengaduan/1/timeline', data: any(named: 'data')))
            .thenAnswer((_) async => mockResponse);

        expect(
          repository.simpanProgresTimeline(
            kasusId: '1',
            title: 'Progres Test',
            deskripsi: 'Deskripsi test',
            tanggal: '2026-06-27',
          ),
          completes,
        );
      });

      test('throws exception message when API returns status false', () async {
        final mockResponse = dio.Response(
          requestOptions: dio.RequestOptions(path: '/pengaduan/1/timeline'),
          data: {'status': false, 'message': 'Gagal menyimpan timeline'},
          statusCode: 400,
        );

        when(() => mockDio.post('/pengaduan/1/timeline', data: any(named: 'data')))
            .thenAnswer((_) async => mockResponse);

        expect(
          repository.simpanProgresTimeline(
            kasusId: '1',
            title: 'Progres Test',
            deskripsi: 'Deskripsi test',
            tanggal: '2026-06-27',
          ),
          throwsA('Gagal menyimpan timeline'),
        );
      });
    });

    group('updateStatusKasus', () {
      test('completes successfully when API returns status true', () async {
        final mockResponse = dio.Response(
          requestOptions: dio.RequestOptions(path: '/pengaduan/1/status'),
          data: {'status': true},
          statusCode: 200,
        );

        when(() => mockDio.patch('/pengaduan/1/status', data: any(named: 'data')))
            .thenAnswer((_) async => mockResponse);

        expect(
          repository.updateStatusKasus(
            kasusId: '1',
            status: 'selesai',
            catatanInternal: 'Catatan selesai',
          ),
          completes,
        );
      });
    });
  });
}
