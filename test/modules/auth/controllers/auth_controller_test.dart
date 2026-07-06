import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/modules/auth/controllers/auth_controller.dart';
import 'package:posbankum/modules/auth/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const containerName = 'auth_unit_test';

  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_auth_unit_test';
  });

  late MockAuthRepository mockRepo;
  late GetStorage testStorage;

  setUpAll(() async {
    await GetStorage.init(containerName);
  });

  setUp(() {
    Get.testMode = true;
    mockRepo = MockAuthRepository();
    testStorage = GetStorage(containerName);
    testStorage.erase();
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController', () {
    // ============================================
    // Test saveSession: logika penyimpanan sesi
    // ============================================
    test('saveSession writes token, user, role, is_logged_in to storage', () async {
      final controller = AuthController(
        authRepository: mockRepo,
        storage: testStorage,
        testMode: true,
      );

      await controller.saveSession({
        'token': 'jwt_abc123',
        'user': {'nama_lengkap': 'Warga Riau', 'role': 'warga'},
      });

      expect(testStorage.read('token'), 'jwt_abc123');
      expect(testStorage.read('role'), 'warga');
      expect(testStorage.read('is_logged_in'), true);
      expect(testStorage.read('user'), isA<Map>());
    });

    // ============================================
    // Test clearSession: logika pembersihan sesi
    // ============================================
    test('clearSession removes token, user, role and sets is_logged_in to false', () async {
      await testStorage.write('token', 'old_token');
      await testStorage.write('user', {'nama': 'Test'});
      await testStorage.write('role', 'warga');
      await testStorage.write('is_logged_in', true);

      final controller = AuthController(
        authRepository: mockRepo,
        storage: testStorage,
        testMode: true,
      );

      await controller.clearSession();

      expect(testStorage.read('token'), isNull);
      expect(testStorage.read('user'), isNull);
      expect(testStorage.read('role'), isNull);
      expect(testStorage.read('is_logged_in'), false);
    });

    // ============================================
    // Test register validation
    // ============================================
    test('register does not call API when confirmPassword does not match', () async {
      final controller = AuthController(
        authRepository: mockRepo,
        storage: testStorage,
        testMode: true,
      );

      await controller.register('Nama', 'email@test.com', 'password', 'different');

      verifyNever(() => mockRepo.registerManual(any(), any(), any()));
      expect(controller.isLoading.value, isFalse);
    });

    // ============================================
    // Test login berhasil: repository dipanggil & sesi tersimpan
    // ============================================
    test('login success calls loginManual and saves session to storage', () async {
      when(() => mockRepo.loginManual('warga@riau.com', 'pass123'))
          .thenAnswer((_) async => {
                'token': 'jwt_test',
                'user': {'nama_lengkap': 'Warga', 'role': 'warga'}
              });

      final controller = AuthController(
        authRepository: mockRepo,
        storage: testStorage,
        testMode: true,
      );

      await controller.login('warga@riau.com', 'pass123');

      verify(() => mockRepo.loginManual('warga@riau.com', 'pass123')).called(1);
      expect(testStorage.read('token'), 'jwt_test');
      expect(testStorage.read('role'), 'warga');
      expect(testStorage.read('is_logged_in'), true);
      expect(controller.isLoading.value, isFalse);
    });

    // ============================================
    // Test login gagal: isLoading kembali false
    // ============================================
    test('login failure sets isLoading to false', () async {
      when(() => mockRepo.loginManual('bad@email.com', 'wrong'))
          .thenThrow('Invalid credentials');

      final controller = AuthController(
        authRepository: mockRepo,
        storage: testStorage,
        testMode: true,
      );

      await controller.login('bad@email.com', 'wrong');

      verify(() => mockRepo.loginManual('bad@email.com', 'wrong')).called(1);
      expect(controller.isLoading.value, isFalse);
    });
  });
}
