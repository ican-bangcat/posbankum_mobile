import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../controllers/pengaduan_controller.dart';

class FormPengaduanScreen extends GetView<PengaduanController> {
  const FormPengaduanScreen({super.key});

  final List<String> _kategoriMasalah = const [
    'Kekerasan & Pelanggaran Fisik', 'Kejahatan Seksual', 'Narkotika & Psikotropika',
    'Kekerasan Berbasis Gender (KBG)', 'Perundungan (Bullying) & Kekerasan Non-fisik', 'Kekerasan Siber / Kejahatan Digital',
    'Konflik Keluarga & Perdata Rumah Tangga', 'Kasus Perburuhan / Ketenagakerjaan', 'Sengketa Tanah & Lingkungan',
    'Tindak Pidana Properti / Harta Benda', 'Sengketa Perdata Umum', 'Administrasi Pemerintahan / Layanan Publik', 'Lain-lain',
  ];

  @override
  Widget build(BuildContext context) {
    const Color darkBlueColor = Color(0xFF2A2E5E);
    const Color whiteBgColor = Color(0xFFF2F4FB);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Column(
        children: [
          // ── HEADER AREA ──
          Stack(
            children: [
              Positioned(bottom: 0, left: 0, child: Container(width: 50, height: 50, color: whiteBgColor)),
              Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: darkBlueColor,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -10, right: -5,
                      child: Opacity(
                        opacity: 0.8,
                        child: Image.asset('assets/images/icons/building_illustration3.png', width: 300, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const SizedBox()),
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
                                decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text('Buat Pengaduan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── BODY AREA ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: whiteBgColor, borderRadius: BorderRadius.only(topRight: Radius.circular(28))),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPadding + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ PROGRESS BAR CLAUDE MASUK KESINI
                    _buildProgressBar(),
                    const SizedBox(height: 24),

                    _buildHeaderIcon(),
                    const SizedBox(height: 24),

                    _buildTextField(label: 'NIK', hint: 'Masukkan 16 digit NIK', controller: controller.nikC, keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    _buildTextField(label: 'Nama Lurah/Kelurahan', hint: 'Masukkan nama lurah/kelurahan', controller: controller.namaLurahC),
                    const SizedBox(height: 20),
                    _buildTextField(label: 'No. Telepon', hint: 'Contoh: 081234567890', controller: controller.noHpC, keyboardType: TextInputType.phone),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: _buildTanggalKejadianField(context)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildWaktuKejadianField(context)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(label: 'Judul Pengaduan', hint: 'Contoh: Sengketa Tanah Warisan', controller: controller.judulLaporanC),
                    const SizedBox(height: 20),

                    _buildJenisMasalahField(),
                    const SizedBox(height: 20),

                    _buildKronologiField(),
                    const SizedBox(height: 20),

                    _buildTextField(label: 'Lokasi Kejadian', hint: 'Contoh: Jl. Sudirman No. 123, Jakarta', controller: controller.lokasiC),
                    const SizedBox(height: 20),

                    // ✅ WIDGET MULTI-FILE DENGAN GAYA DASHED BORDER CLAUDE
                    _buildLampiranField(),
                    const SizedBox(height: 32),

                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PROGRESS BAR WIDGET (FROM CLAUDE) ──
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF2A2E5E).withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Obx(() {
        final count = controller.progressCount.value;
        final progress = count / 9.0; // ✅ Menggunakan 9 field wajib
        final isComplete = count == 9;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress Pengisian', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFF5B5FCF),
                  ),
                  child: Text('$count/9 Lengkap'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (_, val, __) {
                  return LinearProgressIndicator(
                    value: val, minHeight: 8,
                    backgroundColor: const Color(0xFFE4E6F5),
                    valueColor: AlwaysStoppedAnimation<Color>(isComplete ? const Color(0xFF6C63FF) : const Color(0xFF5B5FCF)),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── FORM HELPERS ──
  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.edit_document, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buat Pengaduan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('Isi form di bawah untuk membuat pengaduan', style: TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJenisMasalahField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jenis Masalah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        GetBuilder<PengaduanController>(
            builder: (controller) {
              return DropdownButtonFormField<String>(
                value: controller.selectedKategori,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Pilih jenis masalah', filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
                items: _kategoriMasalah.map((kategori) => DropdownMenuItem(value: kategori, child: Text(kategori, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (value) {
                  controller.selectedKategori = value;
                  controller.calculateProgress(); // ✅ Trigger progress bar
                  controller.update();
                },
              );
            }
        ),
      ],
    );
  }

  Widget _buildTanggalKejadianField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal Kejadian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.tglKejadianC, readOnly: true, onTap: () => controller.pickDate(context),
          decoration: InputDecoration(
            hintText: 'Pilih tanggal', hintStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildWaktuKejadianField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Waktu Kejadian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.waktuKejadianC, readOnly: true, onTap: () => controller.pickTime(context),
          decoration: InputDecoration(
            hintText: 'Pilih jam', hintStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.white,
            suffixIcon: const Icon(Icons.access_time, color: AppColors.primary, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildKronologiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kronologi Singkat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.kronologiC, maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Jelaskan kronologi permasalahan secara detail...', hintStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  // ✅ WIDGET LAMPIRAN DENGAN DASHED BORDER CLAUDE
  Widget _buildLampiranField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lampiran Bukti (Opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Obx(() {
          return Column(
            children: [
              // Kotak Putus-putus Claude
              GestureDetector(
                onTap: () => controller.pickMultipleFiles(),
                child: _DashedBorderContainer(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF2A2E5E).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: const Icon(Icons.upload_rounded, color: Color(0xFF5B5FCF), size: 26),
                        ),
                        const SizedBox(height: 12),
                        Text(controller.selectedFiles.isEmpty ? 'Klik untuk upload file' : 'Tambah file lainnya', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3D3F6B))),
                        const SizedBox(height: 4),
                        const Text('PDF, JPG, PNG (Max 5MB/file)', style: TextStyle(fontSize: 11, color: Color(0xFFBDBDC7))),
                      ],
                    ),
                  ),
                ),
              ),

              // Daftar File
              if (controller.selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...controller.selectedFiles.asMap().entries.map((entry) {
                  int idx = entry.key; File file = entry.value; String fileName = file.path.split('/').last;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green[200]!)),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file, color: Colors.green[700], size: 24),
                        const SizedBox(width: 12),
                        Expanded(child: Text(fileName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        GestureDetector(onTap: () => controller.removeFileAt(idx), child: const Icon(Icons.close, color: Colors.red, size: 20)),
                      ],
                    ),
                  );
                }).toList(),
              ]
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 54,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : () => controller.submitPengaduan(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text('Kirim Pengaduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CUSTOM PAINTER CLAUDE (DASHED BORDER)
// ─────────────────────────────────────────────────────────────
class _DashedBorderContainer extends StatelessWidget {
  final Widget child;
  const _DashedBorderContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 6; const double dashSpace = 5;
    final paint = Paint()..color = const Color(0xFFB0B3D6)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)));

    // ✅ Tulisan import tadi sudah dipindah ke atas, sekarang tinggal pakai ui.PathMetrics
    final ui.PathMetrics pathMetrics = path.computeMetrics();
    for (final ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}