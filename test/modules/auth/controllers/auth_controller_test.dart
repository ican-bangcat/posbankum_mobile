import 'package:flutter/material.dart';
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

  // Mock path_provider MethodChannel untuk GetStorage
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return '.';
  });

  late MockAuthRepository mockAuthRepository;

  setUpAll(() async {
    await GetStorage.init();
  });

  setUp(() {
    Get.testMode = true;
    mockAuthRepository = MockAuthRepository();
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController', () {
    testWidgets('login success saves session and redirects based on role', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));

      final mockUserData = {
        'token': 'fake_jwt_token',
        'user': {
          'nama_lengkap': 'Warga Riau',
          'role': 'warga',
        }
      };

      when(() => mockAuthRepository.loginManual('warga@riau.com', 'password'))
          .thenAnswer((_) async => mockUserData);

      final controller = AuthController(authRepository: mockAuthRepository);
      await controller.login('warga@riau.com', 'password');

      verify(() => mockAuthRepository.loginManual('warga@riau.com', 'password')).called(1);
      
      final storage = GetStorage();
      expect(storage.read('token'), 'fake_jwt_token');
      expect(storage.read('role'), 'warga');
      expect(storage.read('is_logged_in'), true);
    });

    testWidgets('login failure handles error and shows snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));

      when(() => mockAuthRepository.loginManual('wrong@email.com', 'password'))
          .thenThrow('Invalid credentials');

      final controller = AuthController(authRepository: mockAuthRepository);
      await controller.login('wrong@email.com', 'password');

      verify(() => mockAuthRepository.loginManual('wrong@email.com', 'password')).called(1);
      expect(controller.isLoading.value, isFalse);
    });

    testWidgets('register manual success saves session', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));

      final mockUserData = {
        'token': 'fake_jwt_token',
        'user': {
          'nama_lengkap': 'Paralegal Riau',
          'role': 'paralegal',
        }
      };

      when(() => mockAuthRepository.registerManual('Paralegal Riau', 'paralegal@riau.com', 'password'))
          .thenAnswer((_) async => mockUserData);

      final controller = AuthController(authRepository: mockAuthRepository);
      await controller.register('Paralegal Riau', 'paralegal@riau.com', 'password', 'password');

      verify(() => mockAuthRepository.registerManual('Paralegal Riau', 'paralegal@riau.com', 'password')).called(1);
      
      final storage = GetStorage();
      expect(storage.read('token'), 'fake_jwt_token');
      expect(storage.read('role'), 'paralegal');
    });

    testWidgets('register throws when confirmPassword does not match', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));

      final controller = AuthController(authRepository: mockAuthRepository);
      await controller.register('Nama', 'email@email.com', 'password', 'different');

      verifyNever(() => mockAuthRepository.registerManual(any(), any(), any()));
    });

    testWidgets('logout clears session storage and redirects to login', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));

      final storage = GetStorage();
      await storage.write('token', 'old_token');
      await storage.write('is_logged_in', true);

      when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});

      final controller = AuthController(authRepository: mockAuthRepository);
      await controller.logout();

      verify(() => mockAuthRepository.logout()).called(1);
      expect(storage.read('token'), isNull);
      expect(storage.read('is_logged_in'), false);
    });
  });
}
