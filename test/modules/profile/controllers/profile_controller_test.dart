import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/modules/profile/controllers/profile_controller.dart';
import 'package:posbankum/modules/profile/repositories/profile_repository.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider MethodChannel untuk GetStorage ke folder terisolasi
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_profile_test_dir';
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

  group('ProfileController', () {
    test('fetchUserData success populates profile, statistik, and riwayat', () async {
      final profileData = {
        'id_user': '12345678-abcd',
        'email': 'warga@riau.com',
        'nama_lengkap': 'Warga Riau',
        'nomor_telepon': '081234567890',
        'foto_profile': 'https://image.com/avatar.png',
        'role': 'warga',
        'created_at': '2026-06-27T12:00:00Z',
        'masyarakat': {
          'nik': '1234567890123456',
          'alamat': 'Jalan Hang Tuah No. 5',
          'kelurahan': {'nama': 'Rintis'},
          'kecamatan': {'nama': 'Limapuluh'},
          'kabupaten': {'nama': 'Pekanbaru'}
        }
      };

      final statistikData = {
        'menunggu': 1,
        'diproses': 2,
        'selesai': 3,
        'dibatalkan': 1,
      };

      final riwayatData = [
        {
          'status': 'diproses',
          'judul_pengaduan': 'Kasus Tanah',
          'nomor_pengaduan': 'PGN-001',
          'created_at': '2026-06-27T12:00:00Z'
        }
      ];

      when(() => mockProfileRepository.fetchProfile()).thenAnswer((_) async => profileData);
      when(() => mockProfileRepository.fetchStatistik()).thenAnswer((_) async => statistikData);
      when(() => mockProfileRepository.fetchRiwayatPengaduan()).thenAnswer((_) async => riwayatData);

      final controller = ProfileController(profileRepository: mockProfileRepository);
      await controller.fetchUserData();

      expect(controller.isLoading.value, isFalse);
      expect(controller.email.value, 'warga@riau.com');
      expect(controller.namaLengkap.value, 'Warga Riau');
      expect(controller.noHp.value, '081234567890');
      expect(controller.avatarUrl.value, 'https://image.com/avatar.png');
      expect(controller.role.value, 'warga');
      expect(controller.nik.value, '1234567890123456');
      expect(controller.alamat.value, 'Jalan Hang Tuah No. 5');
      expect(controller.kelurahanInfo.value, 'Rintis, Limapuluh, Pekanbaru');
      
      expect(controller.totalPengaduan.value, '7');
      expect(controller.totalDiproses.value, '2');
      expect(controller.totalSelesai.value, '3');
      
      expect(controller.riwayatPengaduan.length, 1);
      expect(controller.riwayatPengaduan.first['judul'], 'Kasus Tanah');
      expect(controller.riwayatPengaduan.first['status'], 'Diproses');
    });

    test('fetchUserData handles exception safely without breaking', () async {
      when(() => mockProfileRepository.fetchProfile()).thenThrow('Network Error');

      final controller = ProfileController(profileRepository: mockProfileRepository);
      await controller.fetchUserData();

      expect(controller.isLoading.value, isFalse);
      expect(controller.email.value, '');
    });
  });
}
