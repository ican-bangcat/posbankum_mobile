// update_progres_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_progres_controller.dart';

class UpdateProgresView extends StatelessWidget {
  const UpdateProgresView({super.key});

  // ✅ Ambil controller via Get.find — controller sudah didaftarkan via binding/routing
  UpdateProgresController get controller => Get.find<UpdateProgresController>();

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius:
                const BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ─── INFORMASI KASUS ───
                    const Text(
                      'Informasi Kasus',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E2452)),
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyCard(
                        'ID Kasus', '#${controller.kasusId.toUpperCase()}'),
                    const SizedBox(height: 12),
                    _buildReadOnlyCard('Nama Kasus', controller.namaKasus),
                    const SizedBox(height: 24),

                    // ─── TANGGAL PENDAMPINGAN ───
                    const Text(
                      'Tanggal Pendampingan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E2452)),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => controller.pilihTanggal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ✅ Obx hanya di bagian teks tanggal yang berubah
                            Obx(() => Text(
                              "${controller.selectedDate.value.day.toString().padLeft(2, '0')}/"
                                  "${controller.selectedDate.value.month.toString().padLeft(2, '0')}/"
                                  "${controller.selectedDate.value.year}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A)),
                            )),
                            const Icon(Icons.calendar_month_outlined,
                                color: Color(0xFF2A2E5E), size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── CATATAN / TINDAKAN ───
                    const Text(
                      'Catatan / Tindakan yang Dilakukan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E2452)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: controller.catatanController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText:
                          'Tuliskan secara detail progres, tindakan yang telah diambil, atau hasil pertemuan terbaru...',
                          hintStyle:
                          TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ─── TOMBOL AKSI (ANTI-SPAM) ───
                    // ✅ Satu Obx membungkus kedua tombol sekaligus — efisien
                    Obx(() {
                      final isLoading = controller.isLoading.value;
                      return Column(
                        children: [
                          // Tombol: Simpan Progres Biasa
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              // ✅ null = tombol otomatis disabled (tidak bisa diklik)
                              onPressed: isLoading
                                  ? null
                                  : () => controller.simpanProgres(
                                  isSelesai: false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E2452),
                                // ✅ Warna saat disabled biar tidak terlalu gelap
                                disabledBackgroundColor:
                                const Color(0xFF1E2452).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              // ✅ Tampilkan spinner ATAU teks, tidak dua-duanya
                              child: isLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                                  : const Text(
                                'Simpan Progres',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Tombol: Selesaikan Kasus
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _konfirmasiSelesai(),
                              style: OutlinedButton.styleFrom(
                                // ✅ Warna border ikut status loading
                                side: BorderSide(
                                  color:
                                  isLoading ? Colors.grey : Colors.green,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Simpan & Selesaikan Kasus',
                                style: TextStyle(
                                  color:
                                  isLoading ? Colors.grey : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiSelesai() {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText:
      'Apakah Anda yakin ingin menyelesaikan kasus ini?\nStatus tidak dapat dikembalikan ke proses.',
      textConfirm: 'Ya, Selesaikan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      // ✅ Pastikan dialog tidak bisa di-spam — controller.simpanProgres sudah ada guard-nya
      onConfirm: () {
        Get.back(); // Tutup dialog dulu
        controller.simpanProgres(isSelesai: true);
      },
    );
  }

  Widget _buildReadOnlyCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(
            bottom: 0,
            left: 0,
            child: Container(width: 50, height: 50, color: bgColor)),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: darkBlue,
              borderRadius:
              const BorderRadius.only(bottomLeft: Radius.circular(28))),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -5,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                      'assets/images/icons/building_illustration3.png',
                      width: 300,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const SizedBox()),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Update Progres Kasus',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}