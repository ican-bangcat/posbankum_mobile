import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:posbankum/modules/pengaduan/controllers/riwayat_pengaduan_controller.dart';
import 'package:posbankum/modules/pengaduan/repositories/pengaduan_repository.dart';
import 'package:posbankum/modules/pengaduan/models/pengaduan_models.dart';

class MockPengaduanRepository extends Mock implements PengaduanRepository {}

void main() {
  late MockPengaduanRepository mockRepository;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockPengaduanRepository();
    when(() => mockRepository.fetchDaftarPengaduan()).thenAnswer((_) async => []);
  });

  tearDown(() {
    Get.reset();
  });

  group('RiwayatPengaduanController', () {
    test('initializes and loads complaints list on success', () async {
      final items = [
        PengaduanItem(
          idDb: '1',
          idTiket: 'TKT-1',
          judul: 'Laporan 1',
          tanggal: '25 Juni 2026',
          kategoriMasalah: 'Narkotika',
          status: 'menunggu',
        )
      ];
      when(() => mockRepository.fetchDaftarPengaduan()).thenAnswer((_) async => items);

      final controller = RiwayatPengaduanController(repository: mockRepository);
      await controller.fetchRiwayatPengaduan();

      expect(controller.allItems.length, 1);
      expect(controller.filteredItems.length, 1);
      expect(controller.isLoading.value, isFalse);
      verify(() => mockRepository.fetchDaftarPengaduan()).called(1);
    });

    test('filteredItems returns items filtered by tab and query', () async {
      final items = [
        PengaduanItem(idDb: '1', idTiket: 'TKT-1', judul: 'Sengketa Tanah', tanggal: '25 Juni', kategoriMasalah: 'A', status: 'menunggu'),
        PengaduanItem(idDb: '2', idTiket: 'TKT-2', judul: 'Pencurian', tanggal: '25 Juni', kategoriMasalah: 'B', status: 'selesai')
      ];
      when(() => mockRepository.fetchDaftarPengaduan()).thenAnswer((_) async => items);

      final controller = RiwayatPengaduanController(repository: mockRepository);
      await controller.fetchRiwayatPengaduan();

      expect(controller.filteredItems.length, 2);

      controller.changeTab(StatusPengaduan.selesai);
      expect(controller.filteredItems.length, 1);
      expect(controller.filteredItems.first.judul, 'Pencurian');

      controller.changeTab(StatusPengaduan.semua);
      controller.searchQuery.value = 'tanah';
      expect(controller.filteredItems.length, 1);
      expect(controller.filteredItems.first.judul, 'Sengketa Tanah');
    });
  });
}
