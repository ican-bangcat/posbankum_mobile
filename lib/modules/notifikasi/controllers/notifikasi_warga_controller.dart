import 'package:get/get.dart';
import '../models/notifikasi_model.dart';
import '../repositories/notifikasi_repository.dart';
import '../../../app/routes/app_routes.dart';

class NotifikasiWargaController extends GetxController {
  final NotifikasiRepository _repository;
  
  var isLoading = true.obs;
  var allNotifications = <NotifikasiItem>[].obs;
  
  // 0: Semua, 1: Belum Dibaca, 2: Sudah Dibaca
  var selectedFilter = 0.obs;

  NotifikasiWargaController({NotifikasiRepository? repository})
      : _repository = repository ?? (Get.isRegistered<NotifikasiRepository>()
            ? Get.find<NotifikasiRepository>()
            : NotifikasiRepository());

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final list = await _repository.fetchNotifikasi();
      allNotifications.value = list;
    } catch (e) {
      print("Error fetch notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<NotifikasiItem> get filteredNotifications {
    // touch the observables to ensure reactivity
    selectedFilter.value;
    allNotifications.length;

    if (selectedFilter.value == 1) {
      return allNotifications.where((e) => !e.isRead).toList();
    } else if (selectedFilter.value == 2) {
      return allNotifications.where((e) => e.isRead).toList();
    }
    return allNotifications.toList();
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
  }

  Future<void> markAsRead(NotifikasiItem item) async {
    if (!item.isRead) {
      try {
        await _repository.markAsRead(item.idNotifikasi);
        // update local list
        final index = allNotifications.indexWhere((e) => e.idNotifikasi == item.idNotifikasi);
        if (index != -1) {
          final updated = NotifikasiItem(
            idNotifikasi: item.idNotifikasi,
            idPosbankum: item.idPosbankum,
            idUserPenerima: item.idUserPenerima,
            judul: item.judul,
            pesan: item.pesan,
            kategori: item.kategori,
            prioritas: item.prioritas,
            isRead: true,
            readAt: DateTime.now().toIso8601String(),
            refTable: item.refTable,
            refId: item.refId,
            createdAt: item.createdAt,
            formattedTime: item.formattedTime,
          );
          allNotifications[index] = updated;
        }
      } catch (e) {
        print("Error mark read: $e");
      }
    }

    // Navigasi ke detail
    if (item.refTable == 'pengaduan' && item.refId != null && item.refId!.isNotEmpty) {
      Get.toNamed(AppRoutes.DETAIL_KASUS, arguments: item.refId);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;
      await _repository.markAllAsRead();
      await fetchNotifications();
    } catch (e) {
      print("Error mark all read: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
