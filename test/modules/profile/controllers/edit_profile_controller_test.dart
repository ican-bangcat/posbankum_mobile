import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/modules/profile/controllers/edit_profile_controller.dart';
import 'package:posbankum/modules/profile/repositories/profile_repository.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider MethodChannel untuk GetStorage ke folder terisolasi
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_edit_profile_test_dir';
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

  group('EditProfileController', () {
    test('fetchUserData success populates form controllers', () async {
      final userData = {
        'email': 'warga@riau.com',
        'nama_lengkap': 'Warga Riau',
        'nomor_telepon': '081234567890',
        'foto_profile': 'https://image.com/avatar.png',
        'role': 'warga',
        'masyarakat': {
          'nik': '1234567890123456',
          'alamat': 'Jalan Hang Tuah No. 5',
          'id_kabupaten': 'kab-123',
          'id_kecamatan': 'kec-456',
          'id_kelurahan': 'kel-789'
        }
      };

      when(() => mockProfileRepository.fetchProfile()).thenAnswer((_) async => userData);
      when(() => mockProfileRepository.fetchKabupaten()).thenAnswer((_) async => []);
      when(() => mockProfileRepository.fetchKecamatan('kab-123')).thenAnswer((_) async => []);
      when(() => mockProfileRepository.fetchKelurahan('kec-456')).thenAnswer((_) async => []);

      final controller = EditProfileController(profileRepository: mockProfileRepository);
      await controller.fetchUserData();

      expect(controller.isLoadingData.value, isFalse);
      expect(controller.emailC.text, 'warga@riau.com');
      expect(controller.namaC.text, 'Warga Riau');
      expect(controller.noHpC.text, '081234567890');
      expect(controller.nikC.text, '1234567890123456');
      expect(controller.alamatDetailC.text, 'Jalan Hang Tuah No. 5');
      expect(controller.selectedKabupatenId.value, 'kab-123');
      expect(controller.selectedKecamatanId.value, 'kec-456');
      expect(controller.selectedKelurahanId.value, 'kel-789');
    });

    test('fetchKabupaten / fetchKecamatan / fetchKelurahan populates list state', () async {
      when(() => mockProfileRepository.fetchKabupaten()).thenAnswer((_) async => [{'id': '1', 'nama': 'Pekanbaru'}]);
      when(() => mockProfileRepository.fetchKecamatan('1')).thenAnswer((_) async => [{'id': '2', 'nama': 'Tampan'}]);
      when(() => mockProfileRepository.fetchKelurahan('2')).thenAnswer((_) async => [{'id': '3', 'nama': 'Simpang Baru'}]);

      final controller = EditProfileController(profileRepository: mockProfileRepository);

      await controller.fetchKabupaten();
      expect(controller.listKabupaten.length, 1);

      await controller.fetchKecamatan('1');
      expect(controller.listKecamatan.length, 1);

      await controller.fetchKelurahan('2');
      expect(controller.listKelurahan.length, 1);
    });

    testWidgets('simpanProfil validates form fields and updates profile on success', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = EditProfileController(profileRepository: mockProfileRepository);

      controller.namaC.text = 'Warga Baru';
      controller.nikC.text = '1234567890123456';
      controller.noHpC.text = '0812345678';
      controller.alamatDetailC.text = 'Alamat Baru';
      controller.selectedKabupatenId.value = 'kab-1';
      controller.selectedKecamatanId.value = 'kec-1';
      controller.selectedKelurahanId.value = 'kel-1';

      when(() => mockProfileRepository.updateProfile(any())).thenAnswer((_) async => {});

      await controller.simpanProfil();

      expect(controller.isSaving.value, isFalse);
      verify(() => mockProfileRepository.updateProfile(any())).called(1);

      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('simpanProfil fails validation when NIK is not 16 digits', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = EditProfileController(profileRepository: mockProfileRepository);

      controller.namaC.text = 'Warga Baru';
      controller.nikC.text = '12345'; // Invalid NIK
      controller.noHpC.text = '0812345678';
      controller.alamatDetailC.text = 'Alamat Baru';

      await controller.simpanProfil();

      expect(controller.isSaving.value, isFalse);
      verifyNever(() => mockProfileRepository.updateProfile(any()));

      await tester.pump(const Duration(seconds: 5));
    });
  });
}
