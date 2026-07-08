import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/daftar_chat_masyarakat/controllers/detail_chat_masyarakat_controller.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio_pkg.Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const containerName = 'detail_chat_masyarakat_test_storage';

  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_detail_chat_masyarakat_test';
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
    testStorage.write('user', {'id_user': '99'});

    // Definisikan arguments navigasi
    Get.routing.args = {
      'id_pengaduan': '123',
      'judul_laporan': 'Sengketa Lahan',
      'nama_paralegal': 'Ahmad Paralegal',
    };
  });

  tearDown(() {
    Get.reset();
  });

  group('DetailChatMasyarakatController', () {
    test('onInit retrieves arguments and loads messages', () async {
      final mockMessagesResponse = {
        'status': true,
        'data': [
          {
            'id_chat': 1,
            'isi_pesan': 'Halo, ada yang bisa dibantu?',
            'pengirim_id': '45', // Klien/Posbankum lain
            'created_at': '2026-07-06T10:00:00.000Z',
          },
          {
            'id_chat': 2,
            'isi_pesan': 'Saya butuh bantuan waris.',
            'pengirim_id': '99', // Diri sendiri
            'created_at': '2026-07-06T10:02:00.000Z',
          }
        ]
      };

      when(() => mockDio.get('/chat/123')).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/chat/123'),
          data: mockMessagesResponse,
          statusCode: 200,
        ),
      );

      final controller = DetailChatMasyarakatController(
        apiService: mockApiService,
        storage: testStorage,
        testMode: true,
      );

      controller.onInit();
      await controller.fetchMessages();

      expect(controller.idPengaduan, '123');
      expect(controller.judulLaporan, 'Sengketa Lahan');
      expect(controller.namaParalegal, 'Ahmad Paralegal');
      expect(controller.messages.length, 2);
      expect(controller.messages[0].isSender, isFalse); // pengirim_id '45' != '99'
      expect(controller.messages[1].isSender, isTrue); // pengirim_id '99' == '99'
    });

    test('kirimPesan success clears input and reloads messages', () async {
      when(() => mockDio.post('/chat/123', data: {'pesan': 'Pesan baru'})).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/chat/123'),
          data: {'status': true},
          statusCode: 200,
        ),
      );

      when(() => mockDio.get('/chat/123')).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/chat/123'),
          data: {'status': true, 'data': []},
          statusCode: 200,
        ),
      );

      final controller = DetailChatMasyarakatController(
        apiService: mockApiService,
        storage: testStorage,
        testMode: true,
      );

      controller.onInit();
      controller.chatInputC.text = 'Pesan baru';

      await controller.kirimPesan();

      verify(() => mockDio.post('/chat/123', data: {'pesan': 'Pesan baru'})).called(1);
      expect(controller.chatInputC.text, isEmpty);
    });
  });
}
