import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart';
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/info_chat/controllers/info_chat_posbankum_controller.dart';

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

  group('InfoChatPosbankumController', () {
    test('loadInfoChatData success parses paralegal details and files', () async {
      final mockComplaintResponse = {
        'status': true,
        'data': {
          'id_pengaduan': 505,
          'nama_paralegal': 'Ahmad Paralegal',
          'nomor_telepon_paralegal': '08123456789',
          'lokasi_kejadian': 'Pekanbaru',
          'judul_pengaduan': 'Kasus Perdata Sengketa',
          'nomor_pengaduan': 'PB-505',
          'status': 'diproses',
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

      final controller = InfoChatPosbankumController(apiService: mockApiService);
      controller.onInit();
      await controller.loadInfoChatData();

      expect(controller.isLoading.value, isFalse);
      expect(controller.namaParalegal.value, 'Ahmad Paralegal');
      expect(controller.noHpParalegal.value, '08123456789');
      expect(controller.judulKasus.value, 'Kasus Perdata Sengketa');
      expect(controller.nomorTiket.value, 'PB-505');
      expect(controller.statusKasus.value, 'DIPROSES');
      expect(controller.listLampiran.length, 1);
      expect(controller.listLampiran[0]['nama_file'], 'bukti_transfer.png');
    });

    test('toggleMute changes isMuted state', () {
      final controller = InfoChatPosbankumController(apiService: mockApiService);
      expect(controller.isMuted.value, isFalse);

      controller.toggleMute(true);
      expect(controller.isMuted.value, isTrue);
    });
  });
}
