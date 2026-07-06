import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posbankum/modules/auth/controllers/forgot_password_controller.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    Get.testMode = true;
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  });

  tearDown(() {
    Get.reset();
  });

  group('ForgotPasswordController', () {
    test('isValidEmail returns true for valid emails and false for invalid ones', () {
      final controller = ForgotPasswordController(supabaseClient: mockSupabaseClient);
      
      expect(controller.isValidEmail('test@example.com'), isTrue);
      expect(controller.isValidEmail('user.name@domain.co.id'), isTrue);
      expect(controller.isValidEmail('invalid-email'), isFalse);
      expect(controller.isValidEmail('invalid@domain'), isFalse);
    });

    testWidgets('sendResetLink fails when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = ForgotPasswordController(supabaseClient: mockSupabaseClient);
      controller.emailController.text = '';

      await controller.sendResetLink();

      expect(controller.isLoading.value, isFalse);
      expect(controller.isSuccess.value, isFalse);
      verifyNever(() => mockGoTrueClient.resetPasswordForEmail(any(), redirectTo: any(named: 'redirectTo')));
      
      // Settle and clean up GetX snackbar timer
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('sendResetLink fails when email format is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = ForgotPasswordController(supabaseClient: mockSupabaseClient);
      controller.emailController.text = 'invalid_email';

      await controller.sendResetLink();

      expect(controller.isLoading.value, isFalse);
      expect(controller.isSuccess.value, isFalse);
      verifyNever(() => mockGoTrueClient.resetPasswordForEmail(any(), redirectTo: any(named: 'redirectTo')));
      
      // Settle and clean up GetX snackbar timer
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('sendResetLink success sets isSuccess to true', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = ForgotPasswordController(supabaseClient: mockSupabaseClient);
      controller.emailController.text = 'warga@riau.com';

      when(() => mockGoTrueClient.resetPasswordForEmail(
            'warga@riau.com',
            redirectTo: 'io.posbankum.app://login-callback',
          )).thenAnswer((_) async {});

      await controller.sendResetLink();

      expect(controller.isLoading.value, isFalse);
      expect(controller.isSuccess.value, isTrue);
      verify(() => mockGoTrueClient.resetPasswordForEmail(
            'warga@riau.com',
            redirectTo: 'io.posbankum.app://login-callback',
          )).called(1);

      // Settle and clean up GetX snackbar timer
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('sendResetLink failure handles AuthException', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = ForgotPasswordController(supabaseClient: mockSupabaseClient);
      controller.emailController.text = 'error@riau.com';

      when(() => mockGoTrueClient.resetPasswordForEmail(
            'error@riau.com',
            redirectTo: 'io.posbankum.app://login-callback',
          )).thenThrow(const AuthException('User not found'));

      await controller.sendResetLink();

      expect(controller.isLoading.value, isFalse);
      expect(controller.isSuccess.value, isFalse);

      // Settle and clean up GetX snackbar timer
      await tester.pump(const Duration(seconds: 5));
    });

    test('resetState clears email and resets success/loading status', () {
      final controller = ForgotPasswordController(supabaseClient: mockSupabaseClient);
      controller.emailController.text = 'some@email.com';
      controller.isSuccess.value = true;
      controller.isLoading.value = true;

      controller.resetState();

      expect(controller.emailController.text, '');
      expect(controller.isSuccess.value, isFalse);
      expect(controller.isLoading.value, isFalse);
    });
  });
}
