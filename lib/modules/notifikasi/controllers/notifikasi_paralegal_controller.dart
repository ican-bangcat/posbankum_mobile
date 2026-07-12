import 'package:get/get.dart';
import '../models/notifikasi_model.dart';
import '../repositories/notifikasi_repository.dart';
import '../../../app/routes/app_routes.dart';

class NotifikasiParalegalController extends GetxController {
  final NotifikasiRepository _repository;
  
  var isLoading = true.obs;
  var allNotifications = <NotifikasiItem>[].obs;
  
  // 0: Semua, 1: Belum Dibaca, 2: Sudah Dibaca
  var selectedFilter = 0.obs;

  NotifikasiParalegalController({NotifikasiRepository? repository})
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
      print("Error fetch notifications for paralegal: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<NotifikasiItem> get filteredNotifications {
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

    // Navigasi ke detail terkait
    if (item.refTable == 'pengaduan' && item.refId != null && item.refId!.isNotEmpty) {
      Get.toNamed(AppRoutes.DETAIL_KASUS_PARALEGAL, arguments: {'id': item.refId});
    } else if (item.refTable == 'kegiatan' && item.refId != null && item.refId!.isNotEmpty) {
      Get.toNamed(AppRoutes.DETAIL_KEGIATAN, arguments: item.refId);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;
      await _repository.markAllAsRead();
      await fetchNotifications();
    } catch (e) {
      print("Error mark all read for paralegal: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
