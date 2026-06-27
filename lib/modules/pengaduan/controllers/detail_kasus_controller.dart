import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../widgets/pdf_viewer_screen.dart';
import '../models/pengaduan_models.dart';
import '../repositories/pengaduan_repository.dart';
import 'daftar_pengaduan_controller.dart';

class DetailKasusController extends GetxController {
  final PengaduanRepository _repository;
  final kasus = Rx<DetailKasus?>(null);
  final isLoading = true.obs;

  DetailKasusController({PengaduanRepository? repository})
      : _repository = repository ?? PengaduanRepository();

  @override
  void onInit() {
    super.onInit();
    fetchDetailKasus();
  }

  Future<void> fetchDetailKasus({bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      final rawId = Get.arguments;
      if (rawId == null) return;

      final pengaduanId = rawId.toString();
      kasus.value = await _repository.fetchFullDetailKasus(pengaduanId);
    } catch (e) {
      print("❌ Error Fetch Detail: $e");
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> bukaLampiran(String urlFromDb, String? mimeType, {String? namaFile}) async {
    try {
      final String lowerPath = urlFromDb.toLowerCase();
      bool isImage = false;
      if (mimeType != null) {
        isImage = mimeType.toLowerCase().contains('image');
      } else {
        isImage = lowerPath.contains('.jpg') || lowerPath.contains('.jpeg') || lowerPath.contains('.png') || lowerPath.contains('image');
      }

      final token = GetStorage().read('token');
      final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

      if (isImage) {
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      urlFromDb,
                      headers: headers,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: const Text('Gagal memuat gambar', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0, right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white, size: 36),
                    onPressed: () => Get.back(),
                  ),
                )
              ],
            ),
          ),
        );
      } else {
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: Colors.white)),
          barrierDismissible: false,
        );

        final directory = await getTemporaryDirectory();
        final filename = namaFile ?? urlFromDb.split('/').last.split('?').first;
        final tempPath = "${directory.path}/$filename";

        await _repository.downloadFile(urlFromDb, tempPath);

        Get.back(); // Tutup loading

        Get.to(() => PdfViewerScreen(
          pdfPath: tempPath,
          title: filename,
        ));
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      String msg = e.toString();
      if (e is dio_pkg.DioException && e.response?.data != null) {
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          msg = e.response?.data['message'].toString() ?? msg;
        }
      }
      Get.snackbar("Error", "Gagal membuka lampiran: $msg", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> batalkanPengaduan() async {
    if (kasus.value == null) return;
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final success = await _repository.batalkanPengaduan(kasus.value!.id);

      Get.back();
      if (success) {
        fetchDetailKasus();
        if (Get.isRegistered<DaftarPengaduanController>()) {
          Get.find<DaftarPengaduanController>().fetchDaftarPengaduan(silent: true);
        }
        Get.snackbar("Berhasil", "Pengaduan telah dibatalkan.", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw 'Gagal membatalkan pengaduan';
      }
    } catch (e) {
      Get.back();
      print("❌ Error Batal Pengaduan: $e");
      Get.snackbar("Gagal", "Gagal membatalkan pengaduan.", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}