import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/modules/auth/controllers/auth_controller.dart';
import 'package:posbankum/modules/auth/repositories/auth_repository.dart';
import 'package:posbankum/app/routes/app_routes.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const containerName = 'auth_test_container';

  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_auth_test_isolated';
  });

  late MockAuthRepository mockAuthRepository;
  late GetStorage testStorage;

  setUpAll(() async {
    await GetStorage.init(containerName);
  });

  setUp(() {
    Get.testMode = true;
    mockAuthRepository = MockAuthRepository();
    testStorage = GetStorage(containerName);
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController', () {
    // Test login success — menggunakan testWidgets agar Get.snackbar & Get.offAllNamed bekerja
    testWidgets('login success saves token, role, and is_logged_in to storage', (tester) async {
      // Setup GetMaterialApp dengan routes agar navigation tidak error
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(name: AppRoutes.WARGA_DASHBOARD, page: () => const Scaffold()),
          GetPage(name: AppRoutes.PARALEGAL_DASHBOARD, page: () => const Scaffold()),
          GetPage(name: AppRoutes.LOGIN, page: () => const Scaffold()),
        ],
      ));

      await testStorage.erase();

      final mockUserData = {
        'token': 'fake_jwt_token',
        'user': {
          'nama_lengkap': 'Warga Riau',
          'role': 'warga',
        }
      };

      when(() => mockAuthRepository.loginManual('warga@riau.com', 'password'))
          .thenAnswer((_) async => mockUserData);

      final controller = AuthController(
        authRepository: mockAuthRepository,
        storage: testStorage,
      );
      await controller.login('warga@riau.com', 'password');
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.loginManual('warga@riau.com', 'password')).called(1);
      expect(testStorage.read('token'), 'fake_jwt_token');
      expect(testStorage.read('role'), 'warga');
      expect(testStorage.read('is_logged_in'), true);
    });

    // Test login failure — isLoading kembali false setelah gagal
    testWidgets('login failure sets isLoading to false', (tester) async {
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(name: AppRoutes.LOGIN, page: () => const Scaffold()),
        ],
      ));

      when(() => mockAuthRepository.loginManual('wrong@email.com', 'password'))
          .thenThrow('Invalid credentials');

      final controller = AuthController(
        authRepository: mockAuthRepository,
        storage: testStorage,
      );
      await controller.login('wrong@email.com', 'password');
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.loginManual('wrong@email.com', 'password')).called(1);
      expect(controller.isLoading.value, isFalse);
    });

    // Test register gagal jika password tidak cocok
    test('register fails when confirmPassword does not match', () async {
      final controller = AuthController(
        authRepository: mockAuthRepository,
        storage: testStorage,
      );
      await controller.register('Nama', 'email@email.com', 'password', 'different');

      verifyNever(() => mockAuthRepository.registerManual(any(), any(), any()));
    });

    // Test register berhasil
    testWidgets('register success saves session data', (tester) async {
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(name: AppRoutes.WARGA_DASHBOARD, page: () => const Scaffold()),
          GetPage(name: AppRoutes.PARALEGAL_DASHBOARD, page: () => const Scaffold()),
          GetPage(name: AppRoutes.LOGIN, page: () => const Scaffold()),
        ],
      ));

      await testStorage.erase();

      final mockUserData = {
        'token': 'register_token',
        'user': {
          'nama_lengkap': 'User Baru',
          'role': 'warga',
        }
      };

      when(() => mockAuthRepository.registerManual('User Baru', 'baru@email.com', 'password'))
          .thenAnswer((_) async => mockUserData);

      final controller = AuthController(
        authRepository: mockAuthRepository,
        storage: testStorage,
      );
      await controller.register('User Baru', 'baru@email.com', 'password', 'password');
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.registerManual('User Baru', 'baru@email.com', 'password')).called(1);
      expect(testStorage.read('token'), 'register_token');
      expect(testStorage.read('role'), 'warga');
      expect(testStorage.read('is_logged_in'), true);
    });

    // Test logout membersihkan storage
    testWidgets('logout clears session storage', (tester) async {
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(name: AppRoutes.LOGIN, page: () => const Scaffold()),
          GetPage(name: AppRoutes.WARGA_DASHBOARD, page: () => const Scaffold()),
        ],
      ));

      await testStorage.write('token', 'old_token');
      await testStorage.write('is_logged_in', true);

      when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});

      final controller = AuthController(
        authRepository: mockAuthRepository,
        storage: testStorage,
      );
      await controller.logout();
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.logout()).called(1);
      expect(testStorage.read('token'), isNull);
      expect(testStorage.read('is_logged_in'), false);
    });
  });
}
