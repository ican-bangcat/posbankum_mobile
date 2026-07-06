import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/modules/profil_paralegal/controllers/profil_paralegal_controller.dart';
import 'package:posbankum/modules/profile/repositories/profile_repository.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider MethodChannel untuk GetStorage ke folder terisolasi
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_profil_paralegal_test_dir';
  });

  late MockProfileRepository mockProfileRepository;

  setUpAll(() async {
    await GetStorage.init();
  });

  setUp(() {
    Get.testMode = true;
    mockProfileRepository = MockProfileRepository();
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfilParalegalController', () {
    test('fetchProfilDariWeb success populates state variables', () async {
      final profileData = {
        'id_user': 'paralegal-123',
        'email': 'paralegal@riau.com',
        'nama_lengkap': 'Paralegal Riau',
        'nomor_telepon': '081234567891',
        'foto_profile': 'https://image.com/avatar_pl.png',
        'created_at': '2026-06-27T12:00:00Z',
        'posbankum': {
          'nama_posbankum': 'POSBANKUM Pekanbaru',
        }
      };

      final statistikData = {
        'menunggu': 1,
        'diproses': 3,
        'selesai': 4,
        'dibatalkan': 1,
      };

      final riwayatData = [
        {
          'status': 'diproses',
          'judul_pengaduan': 'Kasus Kekerasan',
          'nomor_pengaduan': 'PGN-PL-001',
          'created_at': '2026-06-27T12:00:00Z'
        }
      ];

      when(() => mockProfileRepository.fetchProfile()).thenAnswer((_) async => profileData);
      when(() => mockProfileRepository.fetchStatistik()).thenAnswer((_) async => statistikData);
      when(() => mockProfileRepository.fetchRiwayatPengaduan()).thenAnswer((_) async => riwayatData);

      final controller = ProfilParalegalController(profileRepository: mockProfileRepository);
      await controller.fetchProfilDariWeb();

      expect(controller.isLoading.value, isFalse);
      expect(controller.email.value, 'paralegal@riau.com');
      expect(controller.namaLengkap.value, 'Paralegal Riau');
      expect(controller.noHp.value, '081234567891');
      expect(controller.avatarUrl.value, 'https://image.com/avatar_pl.png');
      expect(controller.namaPosbankum.value, 'POSBANKUM Pekanbaru');
      
      expect(controller.totalPengaduan.value, '9');
      expect(controller.totalDiproses.value, '3');
      expect(controller.totalSelesai.value, '4');

      expect(controller.riwayatPengaduan.length, 1);
      expect(controller.riwayatPengaduan.first['judul'], 'Kasus Kekerasan');
      expect(controller.riwayatPengaduan.first['status'], 'Diproses');
    });

    test('fetchProfilDariWeb failure handles errors safely', () async {
      when(() => mockProfileRepository.fetchProfile()).thenThrow('Network Timeout');

      final controller = ProfilParalegalController(profileRepository: mockProfileRepository);
      await controller.fetchProfilDariWeb();

      expect(controller.isLoading.value, isFalse);
      expect(controller.email.value, '');
    });
  });
}
