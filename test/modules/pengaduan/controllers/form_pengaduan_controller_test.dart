import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:posbankum/modules/pengaduan/controllers/form_pengaduan_controller.dart';
import 'package:posbankum/modules/pengaduan/repositories/pengaduan_repository.dart';

class MockPengaduanRepository extends Mock implements PengaduanRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPengaduanRepository mockRepository;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockPengaduanRepository();
  });

  tearDown(() {
    Get.reset();
  });

  group('FormPengaduanController', () {
    test('calculateProgress calculates field completion', () {
      final controller = FormPengaduanController(repository: mockRepository);
      controller.onInit();
      expect(controller.progressCount.value, 0);

      controller.nikC.text = '1234567890123456';
      expect(controller.progressCount.value, 1);

      controller.judulLaporanC.text = 'Laporan Sengketa';
      expect(controller.progressCount.value, 2);
    });

    testWidgets('submitPengaduan fails validation if NIK is not 16 digits', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = FormPengaduanController(repository: mockRepository);
      controller.onInit();
      controller.nikC.text = '123'; // invalid length
      controller.progressCount.value = 9; // force progress limit passing

      await controller.submitPengaduan();

      expect(controller.isLoading.value, isFalse);
      verifyNever(() => mockRepository.fetchProfile());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('submitPengaduan fails validation if progressCount is less than 9', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = FormPengaduanController(repository: mockRepository);
      controller.onInit();
      controller.nikC.text = '1234567890123456';
      controller.progressCount.value = 5; // not complete

      await controller.submitPengaduan();

      expect(controller.isLoading.value, isFalse);
      verifyNever(() => mockRepository.fetchProfile());
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
