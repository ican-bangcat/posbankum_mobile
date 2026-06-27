import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:posbankum/modules/kelola_pengaduan/controllers/update_progres_controller.dart';
import 'package:posbankum/modules/kelola_pengaduan/repositories/kelola_pengaduan_repository.dart';

class MockKelolaPengaduanRepository extends Mock implements KelolaPengaduanRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockKelolaPengaduanRepository mockRepository;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockKelolaPengaduanRepository();
  });

  tearDown(() {
    Get.reset();
  });

  group('UpdateProgresController', () {
    test('initializes arguments correctly from constructor parameters', () {
      final controller = UpdateProgresController(repository: mockRepository, initialKasusId: '1', initialNamaKasus: 'Kasus Sengketa');
      expect(controller.kasusId, '1');
      expect(controller.namaKasus, 'Kasus Sengketa');
    });

    testWidgets('simpanProgres fails validation on empty fields and does not submit', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = UpdateProgresController(repository: mockRepository, initialKasusId: '1', initialNamaKasus: 'Kasus Sengketa');
      controller.judulController.text = '';
      controller.catatanController.text = '';

      await controller.simpanProgres(isSelesai: false);

      expect(controller.isLoading.value, isFalse);
      verifyNever(() => mockRepository.simpanProgresTimeline(
            kasusId: any(named: 'kasusId'),
            title: any(named: 'title'),
            deskripsi: any(named: 'deskripsi'),
            tanggal: any(named: 'tanggal'),
          ));
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('simpanProgres submits progress timeline successfully', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = UpdateProgresController(repository: mockRepository, initialKasusId: '1', initialNamaKasus: 'Kasus Sengketa');
      controller.judulController.text = 'Judul Progres';
      controller.catatanController.text = 'Catatan Progres';

      when(() => mockRepository.simpanProgresTimeline(
            kasusId: '1',
            title: 'Judul Progres',
            deskripsi: 'Catatan Progres',
            tanggal: any(named: 'tanggal'),
          )).thenAnswer((_) async {});

      await controller.simpanProgres(isSelesai: false);

      verify(() => mockRepository.simpanProgresTimeline(
            kasusId: '1',
            title: 'Judul Progres',
            deskripsi: 'Catatan Progres',
            tanggal: any(named: 'tanggal'),
          )).called(1);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('simpanProgres completes case when isSelesai is true', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = UpdateProgresController(repository: mockRepository, initialKasusId: '1', initialNamaKasus: 'Kasus Sengketa');
      controller.judulController.text = 'Judul Progres';
      controller.catatanController.text = 'Catatan Progres';

      when(() => mockRepository.simpanProgresTimeline(
            kasusId: '1',
            title: 'Judul Progres',
            deskripsi: 'Catatan Progres',
            tanggal: any(named: 'tanggal'),
          )).thenAnswer((_) async {});

      when(() => mockRepository.updateStatusKasus(
            kasusId: '1',
            status: 'selesai',
            catatanInternal: 'Catatan Progres',
          )).thenAnswer((_) async {});

      await controller.simpanProgres(isSelesai: true);

      verify(() => mockRepository.simpanProgresTimeline(
            kasusId: '1',
            title: 'Judul Progres',
            deskripsi: 'Catatan Progres',
            tanggal: any(named: 'tanggal'),
          )).called(1);

      verify(() => mockRepository.updateStatusKasus(
            kasusId: '1',
            status: 'selesai',
            catatanInternal: 'Catatan Progres',
          )).called(1);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
