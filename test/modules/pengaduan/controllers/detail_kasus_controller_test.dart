import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:posbankum/modules/pengaduan/controllers/detail_kasus_controller.dart';
import 'package:posbankum/modules/pengaduan/repositories/pengaduan_repository.dart';
import 'package:posbankum/modules/pengaduan/models/pengaduan_models.dart';

class MockPengaduanRepository extends Mock implements PengaduanRepository {}

void main() {
  late MockPengaduanRepository mockRepository;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockPengaduanRepository();
  });

  tearDown(() {
    Get.reset();
  });

  group('DetailKasusController', () {
    test('initializes, calls fetchFullDetailKasus and updates loading state', () async {
      final detail = DetailKasus(
        id: '1',
        judulLaporan: 'Laporan Test',
        kategoriMasalah: 'Narkotika',
        idKasus: 'PGN-123',
        tanggalDibuat: '25 Juni 2026',
        status: 'proses',
        kronologi: 'Kronologi lengkap',
        timeline: [],
        lampiranUrls: [],
        lokasi: 'Kelurahan Buna Teddy',
        namaPelapor: 'Buna Teddy',
        nikPelapor: '1234567890123456',
        noTelpPelapor: '08123456789',
        tanggalKejadian: '24 Juni 2026, 14:00 WIB',
        waktuKejadian: '14:00',
        namaParalegal: 'Paralegal A',
      );

      when(() => mockRepository.fetchFullDetailKasus('1')).thenAnswer((_) async => detail);

      final controller = DetailKasusController(repository: mockRepository, kasusId: '1');
      await controller.fetchDetailKasus();

      expect(controller.kasus.value, isNotNull);
      expect(controller.kasus.value!.judulLaporan, 'Laporan Test');
      expect(controller.kasus.value!.namaParalegal, 'Paralegal A');
      expect(controller.isLoading.value, isFalse);
      verify(() => mockRepository.fetchFullDetailKasus('1')).called(1);
    });

    test('handles exceptions gracefully on API error', () async {
      when(() => mockRepository.fetchFullDetailKasus('1')).thenThrow('API Error');

      final controller = DetailKasusController(repository: mockRepository, kasusId: '1');
      await controller.fetchDetailKasus();

      expect(controller.kasus.value, isNull);
      expect(controller.isLoading.value, isFalse);
    });
  });
}
