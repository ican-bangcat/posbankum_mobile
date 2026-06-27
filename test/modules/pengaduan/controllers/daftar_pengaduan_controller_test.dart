import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:posbankum/modules/pengaduan/controllers/daftar_pengaduan_controller.dart';
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

  group('DaftarPengaduanController', () {
    test('initializes and calls fetchDaftarPengaduan', () async {
      final controller = DaftarPengaduanController(repository: mockRepository);
      controller.onInit();
      verify(() => mockRepository.fetchDaftarPengaduan()).called(1);
      expect(controller.isLoading.value, isTrue);
    });

    test('fetchDaftarPengaduan sets allItems and filteredItems on success', () async {
      final items = [
        PengaduanItem(
          idDb: '1',
          idTiket: 'PGN-1',
          judul: 'Test Kasus',
          tanggal: '27 Juni 2026',
          kategoriMasalah: 'Narkotika',
          status: 'menunggu',
        )
      ];
      when(() => mockRepository.fetchDaftarPengaduan()).thenAnswer((_) async => items);

      final controller = DaftarPengaduanController(repository: mockRepository);
      controller.onInit();
      await controller.fetchDaftarPengaduan();

      expect(controller.allItems.length, 1);
      expect(controller.filteredItems.length, 1);
      expect(controller.filteredItems.first.judul, 'Test Kasus');
      expect(controller.isLoading.value, isFalse);
    });

    test('changeTab filters items by status', () async {
      final items = [
        PengaduanItem(idDb: '1', idTiket: 'PGN-1', judul: 'K 1', tanggal: '27 Juni', kategoriMasalah: 'A', status: 'menunggu'),
        PengaduanItem(idDb: '2', idTiket: 'PGN-2', judul: 'K 2', tanggal: '27 Juni', kategoriMasalah: 'B', status: 'proses'),
        PengaduanItem(idDb: '3', idTiket: 'PGN-3', judul: 'K 3', tanggal: '27 Juni', kategoriMasalah: 'C', status: 'selesai'),
      ];
      when(() => mockRepository.fetchDaftarPengaduan()).thenAnswer((_) async => items);

      final controller = DaftarPengaduanController(repository: mockRepository);
      controller.onInit();
      await controller.fetchDaftarPengaduan();

      expect(controller.filteredItems.length, 3);

      controller.changeTab(StatusPengaduan.dalamProses);
      controller.applyFilterAndSearch();
      expect(controller.filteredItems.length, 1);
      expect(controller.filteredItems.first.status, 'proses');

      controller.changeTab(StatusPengaduan.selesai);
      controller.applyFilterAndSearch();
      expect(controller.filteredItems.length, 1);
      expect(controller.filteredItems.first.status, 'selesai');
    });

    test('search query filters items by title or ticket ID', () async {
      final items = [
        PengaduanItem(idDb: '1', idTiket: 'XYZ-999', judul: 'Sengketa Tanah', tanggal: '27 Juni', kategoriMasalah: 'A', status: 'menunggu'),
        PengaduanItem(idDb: '2', idTiket: 'ABC-123', judul: 'Penganiayaan', tanggal: '27 Juni', kategoriMasalah: 'B', status: 'proses'),
      ];
      when(() => mockRepository.fetchDaftarPengaduan()).thenAnswer((_) async => items);

      final controller = DaftarPengaduanController(repository: mockRepository);
      controller.onInit();
      await controller.fetchDaftarPengaduan();

      controller.searchQuery.value = 'tanah';
      controller.applyFilterAndSearch();
      expect(controller.filteredItems.length, 1);
      expect(controller.filteredItems.first.judul, 'Sengketa Tanah');

      controller.searchQuery.value = 'ABC';
      controller.applyFilterAndSearch();
      expect(controller.filteredItems.length, 1);
      expect(controller.filteredItems.first.judul, 'Penganiayaan');
    });
  });
}
