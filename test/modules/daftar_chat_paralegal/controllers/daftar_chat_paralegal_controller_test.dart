import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/daftar_chat_paralegal/controllers/daftar_chat_paralegal_controller.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio_pkg.Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const containerName = 'daftar_chat_paralegal_test_storage';

  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_daftar_chat_paralegal_test';
  });

  late MockApiService mockApiService;
  late MockDio mockDio;
  late GetStorage testStorage;

  setUpAll(() async {
    await GetStorage.init(containerName);
  });

  setUp(() {
    Get.testMode = true;
    mockApiService = MockApiService();
    mockDio = MockDio();
    when(() => mockApiService.dio).thenReturn(mockDio);

    testStorage = GetStorage(containerName);
    testStorage.erase();
    testStorage.write('user', {'id_user': '20'});
  });

  tearDown(() {
    Get.reset();
  });

  group('DaftarChatParalegalController', () {
    test('fetchDaftarChatParalegal filters status diproses and assigned paralegal', () async {
      final mockPengaduanResponse = {
        'status': true,
        'data': [
          {
            'id_pengaduan': 201,
            'judul_pengaduan': 'Kasus Perdata A',
            'status': 'diproses',
            'id_paralegal': 20, // Assigned ke paralegal ini
            'nama_pelapor': 'Budi',
          },
          {
            'id_pengaduan': 202,
            'judul_pengaduan': 'Kasus Perdata B',
            'status': 'diproses',
            'id_paralegal': 30, // Assigned ke orang lain
            'nama_pelapor': 'Cici',
          },
          {
            'id_pengaduan': 203,
            'judul_pengaduan': 'Kasus Perdata C',
            'status': 'menunggu', // Belum diproses
            'id_paralegal': null,
            'nama_pelapor': 'Dedi',
          }
        ]
      };

      final mockChatResponse = {
        'status': true,
        'data': [
          {
            'id_chat': 1,
            'isi_pesan': 'Halo pak',
            'pengirim_id': '10',
            'created_at': '2026-07-06T10:00:00.000Z',
          }
        ]
      };

      when(() => mockDio.get('/pengaduan')).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/pengaduan'),
          data: mockPengaduanResponse,
          statusCode: 200,
        ),
      );

      when(() => mockDio.get('/chat/201')).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/chat/201'),
          data: mockChatResponse,
          statusCode: 200,
        ),
      );

      final controller = DaftarChatParalegalController(
        apiService: mockApiService,
        storage: testStorage,
      );

      controller.onInit();
      await controller.fetchDaftarChatParalegal();

      expect(controller.isLoading.value, isFalse);
      expect(controller.chatList.length, 1);
      expect(controller.chatList[0].id, '201');
      expect(controller.chatList[0].judulKasus, 'Kasus Perdata A');
      expect(controller.chatList[0].pesanTerakhir, 'Halo pak');
    });
  });
}
