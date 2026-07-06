import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/modules/profil_paralegal/controllers/edit_profil_paralegal_controller.dart';
import 'package:posbankum/modules/profile/repositories/profile_repository.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider MethodChannel untuk GetStorage ke folder terisolasi
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return './temp_edit_profil_paralegal_test_dir';
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

  group('EditProfilParalegalController', () {
    test('fetchUserData success populates form controllers', () async {
      final userData = {
        'email': 'paralegal@riau.com',
        'nama_lengkap': 'Paralegal Riau',
        'nomor_telepon': '081234567891',
        'foto_profile': 'https://image.com/avatar_pl.png',
        'role': 'paralegal',
        'posbankum': {
          'nama_posbankum': 'POSBANKUM Pekanbaru',
        }
      };

      when(() => mockProfileRepository.fetchProfile()).thenAnswer((_) async => userData);

      final controller = EditProfilParalegalController(profileRepository: mockProfileRepository);
      await controller.fetchUserData();

      expect(controller.isLoadingData.value, isFalse);
      expect(controller.emailC.text, 'paralegal@riau.com');
      expect(controller.namaC.text, 'Paralegal Riau');
      expect(controller.noHpC.text, '081234567891');
      expect(controller.posbankumName.value, 'POSBANKUM Pekanbaru');
    });

    testWidgets('simpanProfil validates form fields and updates profile on success', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      final controller = EditProfilParalegalController(profileRepository: mockProfileRepository);

      controller.namaC.text = 'Paralegal Baru';
      controller.noHpC.text = '081234567890';

      when(() => mockProfileRepository.updateProfile(any())).thenAnswer((_) async => {});

      await controller.simpanProfil();

      expect(controller.isSaving.value, isFalse);
      verify(() => mockProfileRepository.updateProfile(any())).called(1);

      await tester.pump(const Duration(seconds: 5));
    });
  });
}
