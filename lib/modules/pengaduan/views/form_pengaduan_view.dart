import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const Color primaryBlue = Color(0xFF464E97);

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
          Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: darkBlueColor,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -10, right: -5,
                  child: Opacity(
                    opacity: 0.15,
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

          // ── BODY AREA ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: whiteBgColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))),
              child: Column(
                children: [
                  // Progress Bar - Pinned at the top
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildProgressBar(),
                  ),
                  
                  // Scrollable Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPadding + 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'NIK', 
                            icon: Icons.person_outline,
                            hint: 'Masukkan 16 digit NIK', 
                            controller: controller.nikC, 
                            keyboardType: TextInputType.number,
                            showDigitCount: true,
                            inputFormatters: [LengthLimitingTextInputFormatter(16)],
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            label: 'Nama Lurah/Kelurahan', 
                            icon: Icons.domain,
                            hint: 'Masukkan nama lurah/kelurahan', 
                            controller: controller.namaLurahC,
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            label: 'No. Telepon', 
                            icon: Icons.phone_outlined,
                            hint: 'Contoh: 081234567890', 
                            controller: controller.noHpC, 
                            keyboardType: TextInputType.phone,
                            inputFormatters: [LengthLimitingTextInputFormatter(13)],
                          ),
                          const SizedBox(height: 20),

                          _buildTanggalKejadianField(context),
                          const SizedBox(height: 20),

                          _buildWaktuKejadianField(context),
                          const SizedBox(height: 20),

                          _buildTextField(
                            label: 'Judul Pengaduan', 
                            icon: Icons.description_outlined,
                            hint: 'Tulis judul singkat masalah', 
                            controller: controller.judulLaporanC,
                            bottomText: 'Contoh: Sengketa Tanah Warisan',
                          ),
                          const SizedBox(height: 20),

                          _buildJenisMasalahField(),
                          const SizedBox(height: 20),

                          _buildTextField(
                            label: 'Kronologi Singkat', 
                            icon: Icons.receipt_long_outlined,
                            hint: 'Jelaskan kronologi permasalahan Anda secara detail...', 
                            controller: controller.kronologiC,
                            maxLines: 5,
                            showCharacterCount: true,
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            label: 'Lokasi Kejadian', 
                            icon: Icons.location_on_outlined,
                            hint: 'Contoh: Jl. Sudirman No. 123, Jakarta', 
                            controller: controller.lokasiC,
                          ),
                          const SizedBox(height: 20),

                          _buildLampiranField(),
                          const SizedBox(height: 32),

                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PROGRESS BAR ──
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF2A2E5E).withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Obx(() {
        final count = controller.progressCount.value;
        final displayCount = count > 8 ? 8 : count;
        final progress = (displayCount / 8.0).clamp(0.0, 1.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress Pengisian', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2A2E5E))),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                  child: Text('$displayCount/8 Lengkap'),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
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
  Widget _buildLabelWithIcon(IconData icon, String label, {String? optionalText}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFE4E6F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: primaryBlue),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2A2E5E))),
        if (optionalText != null) ...[
          const SizedBox(width: 4),
          Text(optionalText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
        ]
      ],
    );
  }

  Widget _buildTextField({
    required String label, 
    required IconData icon,
    required String hint, 
    required TextEditingController controller, 
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? bottomText,
    bool showDigitCount = false,
    bool showCharacterCount = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithIcon(icon, label),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14), 
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
        if (bottomText != null || showDigitCount || showCharacterCount) ...[
          const SizedBox(height: 6),
          if (showDigitCount)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return Text('${value.text.length}/16 digit', style: const TextStyle(fontSize: 12, color: Colors.grey));
              },
            )
          else if (showCharacterCount)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return Text('${value.text.length} karakter', style: const TextStyle(fontSize: 12, color: Colors.grey));
              },
            )
          else if (bottomText != null)
            Text(bottomText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]
      ],
    );
  }

  Widget _buildJenisMasalahField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithIcon(Icons.assignment_outlined, 'Jenis Masalah'),
        const SizedBox(height: 12),
        GetBuilder<PengaduanController>(
            builder: (controller) {
              return DropdownButtonFormField<String>(
                value: controller.selectedKategori,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                decoration: InputDecoration(
                  hintText: 'Pilih jenis masalah', 
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
                items: _kategoriMasalah.map((kategori) => DropdownMenuItem(value: kategori, child: Text(kategori, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (value) {
                  controller.selectedKategori = value;
                  controller.calculateProgress(); 
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
        _buildLabelWithIcon(Icons.calendar_today_outlined, 'Tanggal Kejadian'),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.tglKejadianC, readOnly: true, onTap: () => controller.pickDate(context),
          decoration: InputDecoration(
            hintText: 'Pilih tanggal', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14), filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildWaktuKejadianField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithIcon(Icons.access_time, 'Waktu Kejadian'),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.waktuKejadianC, readOnly: true, onTap: () => controller.pickTime(context),
          decoration: InputDecoration(
            hintText: 'Pilih jam', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14), filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: const Icon(Icons.access_time, color: AppColors.primary, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildLampiranField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithIcon(Icons.file_upload_outlined, 'Lampiran', optionalText: '(Opsional)'),
        const SizedBox(height: 12),
        Obx(() {
          return Column(
            children: [
              GestureDetector(
                onTap: () => controller.pickMultipleFiles(),
                child: _DashedBorderContainer(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)),
                          child: const Icon(Icons.file_upload_outlined, color: primaryBlue, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(controller.selectedFiles.isEmpty ? 'Klik untuk upload file' : 'Tambah file lainnya', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2A2E5E))),
                        const SizedBox(height: 4),
                        const Text('PDF, JPG, PNG (Max 5MB)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              if (controller.selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...controller.selectedFiles.asMap().entries.map((entry) {
                  int idx = entry.key; File file = entry.value; String fileName = file.path.split('/').last;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined, color: primaryBlue, size: 24),
                        const SizedBox(width: 12),
                        Expanded(child: Text(fileName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2A2E5E)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        GestureDetector(onTap: () => controller.removeFileAt(idx), child: const Icon(Icons.close, color: Colors.red, size: 20)),
                      ],
                    ),
                  );
                }),
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
      child: Obx(() {
        final isComplete = controller.progressCount.value >= 8;
        return ElevatedButton(
          onPressed: (isComplete && !controller.isLoading.value) 
              ? () => controller.submitPengaduan() 
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text('Kirim Pengaduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isComplete ? Colors.white : Colors.grey[500])),
        );
      }),
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
    final path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(12)));

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