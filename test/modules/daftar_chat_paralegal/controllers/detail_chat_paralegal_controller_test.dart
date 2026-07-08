import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/app/data/services/api_service.dart';
import 'package:posbankum/modules/daftar_chat_paralegal/controllers/detail_chat_paralegal_controller.dart';

class MockApiService extends Mock implements ApiService {}
class MockDio extends Mock implements dio_pkg.Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const containerName = 'detail_chat_paralegal_test_storage';

  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_detail_chat_paralegal_test';
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

    Get.routing.args = {
      'id_pengaduan': '201',
      'judul_kasus': 'Kasus Perdata A',
      'nama_klien': 'Budi Pelapor',
    };
  });

  tearDown(() {
    Get.reset();
  });

  group('DetailChatParalegalController', () {
    test('onInit retrieves arguments and loads messages', () async {
      final mockMessagesResponse = {
        'status': true,
        'data': [
          {
            'id_chat': 1,
            'isi_pesan': 'Halo paralegal Budi',
            'pengirim_id': '10', // Klien
            'created_at': '2026-07-06T10:00:00.000Z',
          },
          {
            'id_chat': 2,
            'isi_pesan': 'Halo, ada yang bisa saya bantu?',
            'pengirim_id': '20', // Paralegal (diri sendiri)
            'created_at': '2026-07-06T10:01:00.000Z',
          }
        ]
      };

      when(() => mockDio.get('/chat/201')).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/chat/201'),
          data: mockMessagesResponse,
          statusCode: 200,
        ),
      );

      final controller = DetailChatParalegalController(
        apiService: mockApiService,
        storage: testStorage,
        testMode: true,
      );

      controller.onInit();
      await controller.fetchMessages();

      expect(controller.idPengaduan, '201');
      expect(controller.judulKasus, 'Kasus Perdata A');
      expect(controller.namaKlien, 'Budi Pelapor');
      expect(controller.messages.length, 2);
      expect(controller.messages[0].isSender, isFalse); // pengirim_id '10' != '20' (klien)
      expect(controller.messages[1].isSender, isTrue); // pengirim_id '20' == '20' (paralegal)
    });

    test('kirimPesan success clears input and reloads messages', () async {
      when(() => mockDio.post('/chat/201', data: {'pesan': 'Pesan dari paralegal'})).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/chat/201'),
          data: {'status': true},
          statusCode: 200,
        ),
      );

      when(() => mockDio.get('/chat/201')).thenAnswer(
        (_) async => dio_pkg.Response(
          requestOptions: dio_pkg.RequestOptions(path: '/chat/201'),
          data: {'status': true, 'data': []},
          statusCode: 200,
        ),
      );

      final controller = DetailChatParalegalController(
        apiService: mockApiService,
        storage: testStorage,
        testMode: true,
      );

      controller.onInit();
      controller.chatInputC.text = 'Pesan dari paralegal';

      await controller.kirimPesan();

      verify(() => mockDio.post('/chat/201', data: {'pesan': 'Pesan dari paralegal'})).called(1);
      expect(controller.chatInputC.text, isEmpty);
    });
  });
}
