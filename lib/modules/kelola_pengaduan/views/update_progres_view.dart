import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_progres_controller.dart';

class UpdateProgresView extends StatelessWidget {
  const UpdateProgresView({super.key});

  UpdateProgresController get controller => Get.find<UpdateProgresController>();

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650.0),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomPadding),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
    
                        // ─── INFORMASI KASUS ───
                        const Text(
                          'Informasi Kasus',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E2452), fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyCard('ID Kasus', controller.kasusId.length >= 8 ? '#${controller.kasusId.substring(0, 8).toUpperCase()}' : '#${controller.kasusId.toUpperCase()}'),
                        const SizedBox(height: 12),
                        _buildReadOnlyCard('Nama Kasus', controller.namaKasus),
                        const SizedBox(height: 24),
    
                        // ─── TANGGAL PENDAMPINGAN ───
                        const Text(
                          'Tanggal Pendampingan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E2452), fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => controller.pilihTanggal(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() {
                                  final date = controller.selectedDate.value;
                                  if (date == null) {
                                    return const Text(
                                      'Pilih Tanggal Pendampingan',
                                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontFamily: 'Poppins'),
                                    );
                                  }
                                  return Text(
                                    "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Poppins'),
                                  );
                                }),
                                const Icon(Icons.calendar_today_rounded, color: Color(0xFF2A2E5E), size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
    
                        // ─── JUDUL PROGRES ───
                        const Text(
                          'Judul Progres',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E2452), fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller.judulController,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Contoh: Pendampingan Mediasi',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontFamily: 'Poppins'),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF2A2E5E), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
    
                        // ─── CATATAN / TINDAKAN ───
                        const Text(
                          'Catatan / Tindakan yang Dilakukan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E2452), fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller.catatanController,
                          maxLines: 6,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500, fontFamily: 'Poppins', height: 1.5),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Tuliskan secara detail progres, tindakan yang telah diambil, atau hasil pertemuan terbaru...',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontFamily: 'Poppins'),
                            contentPadding: const EdgeInsets.all(18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF2A2E5E), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── LAMPIRAN BUKTI (OPSIONAL) ───
                        const Text(
                          'Lampiran Bukti (Opsional)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E2452), fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 12),
                        _buildLampiranField(),
                        const SizedBox(height: 40),
    
                        // ─── TOMBOL AKSI ───
                        Obx(() {
                          final isLoading = controller.isLoading.value;
                          return Column(
                            children: [
                              // Tombol: Simpan Progres Biasa
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : () => _showSimpanProgresDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2A2E5E),
                                    disabledBackgroundColor: const Color(0xFF2A2E5E).withOpacity(0.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Simpan Progres', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins')),
                                ),
                              ),
                              const SizedBox(height: 12),
    
                              // Tombol: Selesaikan Kasus (Solid Green)
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : () => _showSimpanSelesaiDialog(context),
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                  label: const Text(
                                    'Simpan & Selesaikan Kasus',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    disabledBackgroundColor: Colors.grey.shade400,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
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
        ),
      ),
    );
  }

  void _showSimpanProgresDialog(BuildContext context) {
    if (controller.judulController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Judul / Tahapan Progres wajib diisi!', backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }
    if (controller.catatanController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Catatan / Tindakan wajib diisi!', backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }

    final String namaJudulProgres = controller.judulController.text.trim();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Badge Biru Muda
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Color(0xFF3B82F6),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Simpan Progres?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2554),
                  ),
                ),
                const SizedBox(height: 12),

                // Body Description
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                    children: [
                      const TextSpan(text: 'Progres "'),
                      TextSpan(
                        text: namaJudulProgres,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E2554)),
                      ),
                      const TextSpan(text: '" akan disimpan ke riwayat kasus.'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                Get.back();
                                controller.simpanProgres(isSelesai: false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2554),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text(
                                'Ya, Simpan',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showSimpanSelesaiDialog(BuildContext context) {
    if (controller.judulController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Judul / Tahapan Progres wajib diisi!', backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }
    if (controller.catatanController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Catatan / Tindakan wajib diisi!', backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }

    final String namaKasus = (controller.namaKasus.trim().isNotEmpty && controller.namaKasus != 'Kasus')
        ? controller.namaKasus
        : 'Kasus Ini';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Badge Hijau
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF16A34A),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Simpan & Selesaikan Kasus?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2554),
                  ),
                ),
                const SizedBox(height: 12),

                // Body Description
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                    children: [
                      const TextSpan(text: 'Progres akan disimpan dan kasus "'),
                      TextSpan(
                        text: namaKasus,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E2554)),
                      ),
                      const TextSpan(text: '" akan ditandai '),
                      const TextSpan(
                        text: 'Selesai',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                      ),
                      const TextSpan(text: '.\nTindakan ini tidak bisa dibatalkan.'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                Get.back();
                                controller.simpanProgres(isSelesai: true);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text(
                                'Ya, Selesaikan',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildReadOnlyCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(bottom: 0, left: 0, child: Container(width: 50, height: 50, color: bgColor)),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28))),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -5,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                      'assets/images/icons/building_illustration3.png',
                      width: 300, fit: BoxFit.contain,
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
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Update Progres',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontFamily: 'Poppins',
                        ),
                      ),
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

  Widget _buildLampiranField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => controller.pickFiles(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.file_upload_outlined, color: Color(0xFF2A2E5E), size: 24),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Text(
                    controller.selectedFiles.isEmpty ? 'Klik untuk upload lampiran (Gambar/PDF)' : 'Tambah lampiran lainnya',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2A2E5E), fontFamily: 'Poppins'),
                  )),
                  const SizedBox(height: 4),
                  const Text('Format: PDF, JPG, PNG (Max 5MB)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'Poppins')),
                ],
              ),
            ),
          ),
        ),
        Obx(() {
          if (controller.selectedFiles.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const SizedBox(height: 16),
              ...controller.selectedFiles.asMap().entries.map((entry) {
                int idx = entry.key;
                File file = entry.value;
                String fileName = file.path.split(Platform.pathSeparator).last;
                bool isImage = fileName.toLowerCase().endsWith('.jpg') ||
                    fileName.toLowerCase().endsWith('.jpeg') ||
                    fileName.toLowerCase().endsWith('.png');

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isImage ? const Color(0xFF0D9488) : const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isImage ? 'IMAGE' : 'PDF',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.removeFileAt(idx),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isImage)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(file, height: 120, width: double.infinity, fit: BoxFit.cover),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.description_outlined, color: Colors.white, size: 32),
                                ),
                                const SizedBox(height: 8),
                                const Text('Dokumen PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155), fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFamily: 'Poppins'), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }),
      ],
    );
  }
}