import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart';
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/info_chat/controllers/info_chat_warga_controller.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio_pkg.Dio {}

void main() {
  late MockApiService mockApiService;
  late MockDio mockDio;

  setUp(() {
    Get.testMode = true;
    mockApiService = MockApiService();
    mockDio = MockDio();
    when(() => mockApiService.dio).thenReturn(mockDio);

    Get.routing.args = '505';
  });

  tearDown(() {
    Get.reset();
  });

  group('InfoChatWargaController', () {
    test('loadInfoChatData success parses client details and files', () async {
      final mockComplaintResponse = {
        'status': true,
        'data': {
          'id_pengaduan': 505,
          'nama_pelapor': 'Budi Mulyono',
          'nik': '1234567890123456',
          'nomor_telepon': '08123456789',
          'lokasi_kejadian': 'Pekanbaru',
          'judul_pengaduan': 'Kasus Perdata Sengketa',
          'nomor_pengaduan': 'PB-505',
          'status': 'diproses',
          'kronologi': 'Lurah/Kelurahan: Kelurahan Sidomulyo\n\nKronologi:\nIni detail kronologi...',
        }
      };

      final mockLampiranResponse = {
        'status': true,
        'data': [
          {
            'nama_file': 'bukti_transfer.png',
            'path_file': 'https://api.sibapak.pocari.id/storage/chat/bukti.png',
            'mime_type': 'image/png',
            'jenis_lampiran': 'chat',
          }
        ]
      };

      when(() => mockDio.get('/pengaduan/505')).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/pengaduan/505'),
          data: mockComplaintResponse,
          statusCode: 200,
        ),
      );

      when(() => mockDio.get('/pengaduan/505/lampiran')).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/pengaduan/505/lampiran'),
          data: mockLampiranResponse,
          statusCode: 200,
        ),
      );

      final controller = InfoChatWargaController(apiService: mockApiService);
      controller.onInit();
      await controller.loadInfoChatData();

      expect(controller.isLoading.value, isFalse);
      expect(controller.namaKlien.value, 'Budi Mulyono');
      expect(controller.nik.value, '1234567890123456');
      expect(controller.noHp.value, '08123456789');
      expect(controller.judulKasus.value, 'Kasus Perdata Sengketa');
      expect(controller.nomorTiket.value, 'PB-505');
      expect(controller.statusKasus.value, 'DIPROSES');
      expect(controller.namaLurah.value, 'Kelurahan Sidomulyo');
      expect(controller.listLampiran.length, 1);
      expect(controller.listLampiran[0]['nama_file'], 'bukti_transfer.png');
    });

    test('toggleMute changes isMuted state', () {
      final controller = InfoChatWargaController(apiService: mockApiService);
      expect(controller.isMuted.value, isFalse);

      controller.toggleMute(true);
      expect(controller.isMuted.value, isTrue);
    });
  });
}
