import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/daftar_chat_masyarakat_controller.dart';

class DaftarChatMasyarakatView extends GetView<DaftarChatMasyarakatController> {
  const DaftarChatMasyarakatView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    Get.put(DaftarChatMasyarakatController());

    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          // HEADER SCREEN
          _buildHeader(),

          // BODY AREA
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.acceptedComplaints.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  itemCount: controller.acceptedComplaints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final kasus = controller.acceptedComplaints[index];

                    final idPengaduan = kasus['id'] ?? '';
                    final judulLaporan = kasus['judul_laporan'] ?? kasus['kategori_masalah'] ?? 'Tanpa Judul';
                    final namaParalegal = kasus['nama_paralegal_ditugaskan'] ?? 'Mencari Paralegal...';

                    return GestureDetector(
                      onTap: () => controller.pindahKeDetailChat(idPengaduan, judulLaporan, namaParalegal),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Avatar Room
                            Container(
                              width: 48, height: 48,
                              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                              child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2563EB), size: 22),
                            ),
                            const SizedBox(width: 14),
                            // Konten Informasi Ruang Chat
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    judulLaporan,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Paralegal: $namaParalegal",
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Klik untuk masuk ke ruang obrolan",
                                        style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                                        child: const Text('Aktif', style: TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: darkBlue),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Row(
            children: [
              const Icon(Icons.mark_chat_unread_outlined, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              const Text(
                'Konsultasi Hukum',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Fitur Chat Belum Terbuka',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ruang obrolan otomatis aktif setelah laporan pengaduan Anda divalidasi dan "Diterima" oleh Paralegal Posbankum.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}