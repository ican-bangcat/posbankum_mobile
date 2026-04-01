import 'package:get/get.dart';
import '../controllers/main_dashboard_admin_controller.dart';
// import '../../auth/controllers/home_paralegal_controller.dart'; // (Kalau ada controllernya)

class MainDashboardAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainDashboardAdminController>(() => MainDashboardAdminController());
    // Panggil koki (controller) halaman anak-anaknya di sini nanti
  }
}