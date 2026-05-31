import 'package:get/get.dart';
import '../../modules/pengaduan/controllers/daftar_pengaduan_controller.dart';
import '../../modules/splash/views/splash_screen.dart';
import '../../modules/splash/controllers/splash_controller.dart';
import '../../modules/onboarding/views/onboarding_screen.dart';
import '../../modules/onboarding/controllers/onboarding_controller.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/login_form_screen.dart';
import '../../modules/auth/views/home_masyarakat_screen.dart';
import '../../modules/auth/views/home_paralegal_screen.dart';
import '../../modules/pengaduan/views/form_pengaduan_view.dart';
import '../../modules/pengaduan/views/pengaduan_success_screen.dart';
import '../../modules/pengaduan/controllers/FormPengaduanController.dart';
import '../../modules/auth/views/forgot_password_screen.dart';
import '../../modules/auth/controllers/forgot_password_controller.dart';
import '../../modules/auth/views/update_password_screen.dart';
import '../../modules/auth/controllers/update_password_controller.dart';
import '../../modules/pengaduan/views/daftar_pengaduan_view.dart';
import '../../modules/pengaduan/controllers/riwayat_pengaduan_controller.dart';
import '../../modules/pengaduan/views/detail_kasus_view.dart';
import '../../modules/pengaduan/bindings/detail_kasus_binding.dart';
import 'app_routes.dart';
import '../../modules/main_dashboard/views/main_dashboard_view.dart';
import '../../modules/main_dashboard/bindings/main_dashboard_binding.dart';
import '../../modules/main_dashboard_admin/views/main_dashboard_admin_view.dart';
import '../../modules/main_dashboard_admin/bindings/main_dashboard_admin_binding.dart';
import '../../modules/kelola_pengaduan/views/detail_kasus_paralegal_view.dart';
import '../../modules/kelola_pengaduan/controllers/detail_kasus_paralegal_controller.dart';
import '../../modules/kelola_pengaduan/views/update_progres_view.dart';
import '../../modules/kelola_pengaduan/controllers/update_progres_controller.dart';
import '../../modules/kelola_kegiatan/controllers/tambah_kegiatan_controller.dart';
import '../../modules/kelola_kegiatan/views/tambah_kegiatan_view.dart';
import '../../modules/kelola_kegiatan/bindings/tambah_kegiatan_binding.dart';
import '../../modules/kelola_kegiatan/views/konfirmasi_kegiatan_view.dart';
import '../../modules/kelola_kegiatan/views/detail_kegiatan_view.dart';
import '../../modules/kelola_kegiatan/bindings/detail_kegiatan_binding.dart';
import '../../modules/kelola_kegiatan/views/edit_kegiatan_view.dart';
import '../../modules/kelola_kegiatan/bindings/edit_kegiatan_binding.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/edit_profile_view.dart';
import '../../modules/profile/bindings/edit_profile_binding.dart';
import '../../modules/profil_posbankum/bindings/profil_posbankum_binding.dart';
import '../../modules/profil_posbankum/views/profil_posbankum_view.dart';
import '../../modules/notifikasi_masyarakat/views/notifikasi_masyarakat_view.dart';
import '../../modules/notifikasi_masyarakat/bindings/notifikasi_masyarakat_binding.dart';
import '../../modules/daftar_chat_paralegal/controllers/daftar_chat_paralegal_controller.dart';
import '../../modules/daftar_chat_paralegal/views/daftar_chat_paralegal_view.dart';
import '../../modules/daftar_chat_paralegal/controllers/detail_chat_paralegal_controller.dart';
import '../../modules/daftar_chat_paralegal/views/detail_chat_paralegal_view.dart';
import '../../modules/daftar_chat_paralegal/controllers/info_chat_posbankum_controller.dart';
import '../../modules/daftar_chat_paralegal/views/info_chat_posbankum_view.dart';
import '../../modules/daftar_chat_masyarakat/controllers/daftar_chat_masyarakat_controller.dart';
import '../../modules/daftar_chat_masyarakat/views/daftar_chat_masyarakat_view.dart';
import '../../modules/daftar_chat_masyarakat/controllers/detail_chat_masyarakat_controller.dart';
import '../../modules/daftar_chat_masyarakat/views/detail_chat_masyarakat_view.dart';


/// App Pages Configuration
class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingController>(() => OnboardingController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    GetPage(
      name: AppRoutes.LOGIN_FORM,
      page: () => const LoginFormScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Home Masyarakat
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeMasyarakatScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ✅ FORGOT PASSWORD (BARU)
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        // LazyPut: Controller hanya dibuat saat halaman dibuka
        Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ✅ UPDATE PASSWORD (BARU)
    GetPage(
      name: AppRoutes.UPDATE_PASSWORD,
      page: () => const UpdatePasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UpdatePasswordController>(() => UpdatePasswordController());
      }),
      transition: Transition.fadeIn, // Fade in karena ini biasanya otomatis
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ✅ PENGADUAN ROUTES (SUDAH DISESUAIKAN)
    GetPage(
      name: AppRoutes.FORM_PENGADUAN,
      page: () => const FormPengaduanScreen(),
      binding: BindingsBuilder(() {
        // Wajib inject Controller di sini biar gak error!
        Get.lazyPut<PengaduanController>(() => PengaduanController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.PENGADUAN_SUCCESS,
      page: () {
        // Ambil data dari arguments yang dikirim controller sebagai Map
        final args = Get.arguments as Map<String, dynamic>? ?? {};

        final pengaduanId = args['pengaduanId'] as String? ?? 'PGN-UNKNOWN';
        final uuidDb = args['uuidDb'] as String? ?? '';

        return PengaduanSuccessScreen(
          pengaduanId: pengaduanId,
          uuidDb: uuidDb, // 🚀 Masukkan parameter kedua di sini!
        );
      },
    ),
    // ✅ Route ke Daftar Pengaduan
    GetPage(
      name: '/daftar-pengaduan', // Atur path rutenya
      page: () => const DaftarPengaduanView(), // Arahkan ke View baru
      binding: BindingsBuilder(() {
        // Ikat (Bind) Controller barunya ke View ini
        Get.lazyPut<DaftarPengaduanController>(() => DaftarPengaduanController());
      }),
    ),
    GetPage(
      name: AppRoutes.DETAIL_KASUS,
      page: () => const DetailKasusView(),
      binding: DetailKasusBinding(),
      transition: Transition.rightToLeft, // Animasi geser yang smooth
    ),
    GetPage(
      name: AppRoutes.MAIN_DASHBOARD,
      page: () => const MainDashboardView(),
      binding: MainDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.MAIN_DASHBOARD_ADMIN,
      page: () => const MainDashboardAdminView(),
      binding: MainDashboardAdminBinding(),
    ),

    // ✅ DETAIL KASUS KHUSUS PARALEGAL
    GetPage(
      name: AppRoutes.DETAIL_KASUS_PARALEGAL,
      page: () => const DetailKasusParalegalView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DetailKasusParalegalController>(() => DetailKasusParalegalController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.UPDATE_PROGRES,
      page: () => const UpdateProgresView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UpdateProgresController>(() => UpdateProgresController());
      }),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.TAMBAH_KEGIATAN,
      page: () => const TambahKegiatanView(),
      binding: TambahKegiatanBinding(), // Kita buatkan bindingnya sekalian
    ),
    GetPage(
      name: AppRoutes.KONFIRMASI_KEGIATAN,
      page: () => const KonfirmasiKegiatanView(),
      // Nggak perlu binding/controller khusus karena cuma tampilan statis
    ),
    GetPage(
      name: AppRoutes.DETAIL_KEGIATAN,
      page: () =>  DetailKegiatanView(),
      binding: DetailKegiatanBinding(),
    ),
    // Edit Kegiatan
    GetPage(
      name: AppRoutes.EDIT_KEGIATAN,
      page: () => const EditKegiatanView(),
      binding: EditKegiatanBinding(),
    ),
    //Register
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterView(), // Pastikan nama class-nya udah diganti
    ),

    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      // Kalau kamu bikin binding, masukin binding-nya di sini
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(), // ✅ Tambahkan baris ini
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE, // Atau Routes.EDIT_PROFILE (sesuaikan dengan nama class kamu)
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFIL_POSBANKUM,
      page: () => const ProfilPosbankumView(),
      binding: ProfilPosbankumBinding(),
    ),
    GetPage(
      name: AppRoutes.NOTIFICATION,
      page: () => const NotifikasiMasyarakatView(),
      binding: NotifikasiMasyarakatBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.DAFTAR_CHAT_PARALEGAL,
      page: () => const DaftarChatParalegalView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DaftarChatParalegalController>(() => DaftarChatParalegalController());
      }),
    ),
    GetPage(
      name: AppRoutes.DETAIL_CHAT_PARALEGAL,
      page: () => const DetailChatParalegalView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DetailChatParalegalController>(() => DetailChatParalegalController());
      }),
    ),
    GetPage(
      name: AppRoutes.INFO_CHAT_POSBANKUM,
      page: () => const InfoChatPosbankumView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InfoChatPosbankumController>(() => InfoChatPosbankumController());
      }),
    ),
    GetPage(
      name: AppRoutes.DAFTAR_CHAT_MASYARAKAT,
      page: () => const DaftarChatMasyarakatView(),
    ),
    GetPage(
      name: AppRoutes.DETAIL_CHAT_MASYARAKAT,
      page: () => const DetailChatMasyarakatView(),
    ),
  ];
}