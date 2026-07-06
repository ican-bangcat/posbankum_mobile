import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posbankum/modules/auth/controllers/update_password_controller.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockUserResponse extends Mock implements UserResponse {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUpAll(() {
    registerFallbackValue(UserAttributes(password: ''));
  });

  setUp(() {
    Get.testMode = true;
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  });

  tearDown(() {
    Get.reset();
  });

  group('UpdatePasswordController', () {
    testWidgets('validatePasswords fails when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = UpdatePasswordController(supabaseClient: mockSupabaseClient);
      controller.newPasswordController.text = '';
      controller.confirmPasswordController.text = '';

      expect(controller.validatePasswords(), isFalse);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('validatePasswords fails when password is less than 6 characters', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = UpdatePasswordController(supabaseClient: mockSupabaseClient);
      controller.newPasswordController.text = '12345';
      controller.confirmPasswordController.text = '12345';

      expect(controller.validatePasswords(), isFalse);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('validatePasswords fails when passwords mismatch', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = UpdatePasswordController(supabaseClient: mockSupabaseClient);
      controller.newPasswordController.text = '123456';
      controller.confirmPasswordController.text = '1234567';

      expect(controller.validatePasswords(), isFalse);
      await tester.pump(const Duration(seconds: 5));
    });

    test('validatePasswords passes for valid matching passwords', () {
      final controller = UpdatePasswordController(supabaseClient: mockSupabaseClient);
      controller.newPasswordController.text = 'securepass';
      controller.confirmPasswordController.text = 'securepass';

      expect(controller.validatePasswords(), isTrue);
    });

    testWidgets('updatePassword success calls supabase updateUser', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = UpdatePasswordController(supabaseClient: mockSupabaseClient);
      controller.newPasswordController.text = 'securepass';
      controller.confirmPasswordController.text = 'securepass';

      final mockUser = MockUser();
      final mockResponse = MockUserResponse();
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockGoTrueClient.updateUser(any()))
          .thenAnswer((_) async => mockResponse);

      await controller.updatePassword();

      expect(controller.isLoading.value, isFalse);
      verify(() => mockGoTrueClient.updateUser(any())).called(1);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('updatePassword failure sets errorMessage on AuthException', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = UpdatePasswordController(supabaseClient: mockSupabaseClient);
      controller.newPasswordController.text = 'securepass';
      controller.confirmPasswordController.text = 'securepass';

      when(() => mockGoTrueClient.updateUser(any()))
          .thenThrow(const AuthException('Password is too weak'));

      await controller.updatePassword();

      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, 'Password is too weak');
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
