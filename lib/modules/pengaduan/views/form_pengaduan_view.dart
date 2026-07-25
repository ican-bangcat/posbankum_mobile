import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/image_constants.dart';
import '../controllers/form_pengaduan_controller.dart';

class FormPengaduanScreen extends GetView<FormPengaduanController> {
  const FormPengaduanScreen({super.key});

  final List<String> _kategoriMasalah = const [
    'Kekerasan & Pelanggaran Fisik',
    'Kejahatan Seksual',
    'Narkotika & Psikotropika',
    'Kekerasan Berbasis Gender (KBG)',
    'Perundungan (Bullying) & Kekerasan Non-fisik',
    'Kekerasan Siber / Kejahatan Digital',
    'Konflik Keluarga & Perdata Rumah Tangga',
    'Kasus Perburuhan / Ketenagakerjaan',
    'Sengketa Tanah & Lingkungan',
    'Tindak Pidana Properti / Harta Benda',
    'Sengketa Perdata Umum',
    'Administrasi Pemerintahan / Layanan Publik',
    'Lain-lain',
  ];

  static const Color primaryBlue = Color(0xFF464E97);
  static const Color fieldBgColor = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    const Color darkBlueColor = Color(0xFF2A2E5E);
    const Color whiteBgColor = Color(0xFFF2F4FB);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650.0),
          child: Column(
            children: [
              // ── 1. HEADER AREA (PERSIS DENGAN DAFTAR PENGADUAN) ──
              Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(width: 50, height: 50, color: whiteBgColor),
                  ),
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: darkBlueColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.zero,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -10,
                          right: -5,
                          child: Opacity(
                            opacity: 0.8,
                            child: Image.asset(
                              ImageConstants.headerBgWarga,
                              width: 300,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.location_city,
                                size: 200,
                                color: Colors.white10,
                              ),
                            ),
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
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Formulir Pengaduan Hukum',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
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
              ),

              // ── 2. BODY AREA (BERBENTUK CARD SEPERTI FIGMA) ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: whiteBgColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(28),
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Progress Bar - Pinned at the top
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _buildProgressBar(),
                      ),

                      // Scrollable Form Content (Grouped into Figma Cards)
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── SECTION 1: DATA PELAPOR ──
                              _buildSectionTitle('DATA PELAPOR'),
                              const SizedBox(height: 10),
                              _buildCardContainer(
                                children: [
                                  _buildTextField(
                                    label: 'NIK',
                                    icon: Icons.credit_card_rounded,
                                    hint: 'Masukkan 16 digit NIK',
                                    controller: controller.nikC,
                                    keyboardType: TextInputType.number,
                                    showDigitCount: true,
                                    bottomText: 'Otomatis terisi dari profil (dapat disesuaikan)',
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(16),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    label: 'Nama Lurah',
                                    optionalText: '(Opsional)',
                                    icon: Icons.apartment_rounded,
                                    hint: 'Masukkan nama lurah',
                                    controller: controller.namaLurahC,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    label: 'No. Telepon',
                                    icon: Icons.phone_rounded,
                                    hint: 'Contoh: 081234567890',
                                    controller: controller.noHpC,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(13),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTanggalKejadianField(context),
                                  const SizedBox(height: 20),
                                  _buildWaktuKejadianField(context),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // ── SECTION 2: ISI LAPORAN ──
                              _buildSectionTitle('ISI LAPORAN'),
                              const SizedBox(height: 10),
                              _buildCardContainer(
                                children: [
                                  _buildTextField(
                                    label: 'Judul Pengaduan',
                                    icon: Icons.description_rounded,
                                    hint: 'Tulis judul singkat masalah',
                                    controller: controller.judulLaporanC,
                                    bottomText: 'Contoh: Sengketa Tanah Warisan',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildJenisMasalahField(context),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    label: 'Kronologi Singkat',
                                    icon: Icons.receipt_long_rounded,
                                    hint: 'Jelaskan kronologi permasalahan Anda secara detail...',
                                    controller: controller.kronologiC,
                                    maxLines: 5,
                                    showCharacterCount: true,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    label: 'Lokasi Kejadian',
                                    icon: Icons.location_on_rounded,
                                    hint: 'Contoh: Jl. Sudirman No. 123, Jakarta',
                                    controller: controller.lokasiC,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildLampiranField(),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // ── SUBMIT BUTTON ──
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
        ),
      ),
    );
  }

  // ── SECTION TITLE BADGE ──
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── CARD CONTAINER (SAMA SEPERTI FIGMA) ──
  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A2E5E).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ── PROGRESS BAR ──
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A2E5E).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                const Text(
                  'Progress Pengisian',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A2E5E),
                  ),
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
                    value: val,
                    minHeight: 8,
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

  // ── ICON BADGE + LABEL HELPER ──
  Widget _buildLabelWithIcon(IconData icon, String label, {String? optionalText}) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: primaryBlue),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2A2E5E),
          ),
        ),
        if (optionalText != null) ...[
          const SizedBox(width: 4),
          Text(
            optionalText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ]
      ],
    );
  }

  // ── TEXT FIELD DENGAN DESAIN SOFT INPUT FIGMA ──
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? bottomText,
    String? optionalText,
    bool showDigitCount = false,
    bool showCharacterCount = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithIcon(icon, label, optionalText: optionalText),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: fieldBgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primaryBlue, width: 1.5),
            ),
          ),
        ),
        if (bottomText != null || showDigitCount || showCharacterCount) ...[
          const SizedBox(height: 6),
          if (showDigitCount)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return Text(
                  '${value.text.length}/16 digit',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                );
              },
            )
          else if (showCharacterCount)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return Text(
                  '${value.text.length} karakter',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                );
              },
            )
          else if (bottomText != null)
            Text(
              bottomText,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
        ]
      ],
    );
  }

  void _showKategoriSheet(BuildContext context) {
    Get.bottomSheet(
      Builder(
        builder: (sheetContext) {
          final double sheetBottomPadding = MediaQuery.of(sheetContext).padding.bottom;
          return Container(
            height: Get.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Pilih Jenis Masalah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2E5E),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'Silakan pilih jenis masalah hukum yang paling sesuai dengan laporan Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: GetBuilder<FormPengaduanController>(
                    builder: (ctrl) {
                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 20 + sheetBottomPadding),
                        itemCount: _kategoriMasalah.length,
                        itemBuilder: (ctx, i) {
                          final item = _kategoriMasalah[i];
                          final isSelected = ctrl.selectedKategori == item;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF2F4FB) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? primaryBlue.withValues(alpha: 0.3) : Colors.grey[200]!,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              title: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? primaryBlue : const Color(0xFF2A2E5E),
                                ),
                              ),
                              leading: Radio<String>(
                                value: item,
                                groupValue: ctrl.selectedKategori,
                                activeColor: primaryBlue,
                                onChanged: (value) {
                                  if (value != null) {
                                    ctrl.selectedKategori = value;
                                    ctrl.calculateProgress();
                                    ctrl.update();
                                    Future.delayed(const Duration(milliseconds: 200), () {
                                      Get.back();
                                    });
                                  }
                                },
                              ),
                              onTap: () {
                                ctrl.selectedKategori = item;
                                ctrl.calculateProgress();
                                ctrl.update();
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  Get.back();
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildJenisMasalahField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithIcon(Icons.gavel_rounded, 'Jenis Masalah'),
        const SizedBox(height: 10),
        GetBuilder<FormPengaduanController>(
          builder: (ctrl) {
            final hasValue = ctrl.selectedKategori != null && ctrl.selectedKategori!.isNotEmpty;
            return GestureDetector(
              onTap: () => _showKategoriSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: fieldBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: hasValue
                      ? Border.all(color: primaryBlue, width: 1.5)
                      : Border.all(color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasValue ? ctrl.selectedKategori! : 'Pilih jenis masalah',
                        style: TextStyle(
                          color: hasValue ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 22),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTanggalKejadianField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithIcon(Icons.calendar_today_rounded, 'Tanggal Kejadian'),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller.tglKejadianC,
          readOnly: true,
          onTap: () => controller.pickDate(context),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Pilih tanggal',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: fieldBgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF94A3B8), size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaktuKejadianField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithIcon(Icons.access_time_rounded, 'Waktu Kejadian'),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller.waktuKejadianC,
          readOnly: true,
          onTap: () => controller.pickTime(context),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Pilih jam',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: fieldBgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: const Icon(Icons.access_time_outlined, color: Color(0xFF94A3B8), size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLampiranField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithIcon(Icons.file_upload_rounded, 'Lampiran', optionalText: '(Opsional)'),
        const SizedBox(height: 10),
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
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_upload_outlined, color: primaryBlue, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.selectedFiles.isEmpty
                              ? 'Klik untuk upload file'
                              : 'Tambah file lainnya',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2A2E5E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PDF, JPG, PNG (Max 5MB)',
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (controller.selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...controller.selectedFiles.asMap().entries.map((entry) {
                  int idx = entry.key;
                  File file = entry.value;
                  String fileName = file.path.split('/').last;
                  bool isImage = fileName.toLowerCase().endsWith('.jpg') ||
                      fileName.toLowerCase().endsWith('.jpeg') ||
                      fileName.toLowerCase().endsWith('.png');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: fieldBgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge dan Tombol Silang
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => controller.removeFileAt(idx),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Konten Tengah
                        if (isImage)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                file,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
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
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.description_outlined, color: Colors.white, size: 32),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Dokumen PDF',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Info File di Bawah
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fileName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isImage ? 'Gambar' : 'Dokumen PDF',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (isImage) {
                                    Get.dialog(
                                      Dialog(
                                        insetPadding: const EdgeInsets.all(16),
                                        backgroundColor: Colors.transparent,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: Get.height * 0.7,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                              child: Image.file(file, fit: BoxFit.contain),
                                            ),
                                            Positioned(
                                              top: 12,
                                              right: 12,
                                              child: GestureDetector(
                                                onTap: () => Get.back(),
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.black54,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    controller.bukaFileLokal(file.path);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.visibility_outlined, color: primaryBlue, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Lihat',
                                        style: TextStyle(
                                          color: primaryBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
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
      width: double.infinity,
      height: 54,
      child: Obx(() {
        final isComplete = controller.progressCount.value >= 8;
        return ElevatedButton(
          onPressed: (isComplete && !controller.isLoading.value)
              ? () => controller.submitPengaduan()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  'Kirim Pengaduan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isComplete ? Colors.white : Colors.grey[500],
                  ),
                ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CUSTOM PAINTER (DASHED BORDER)
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
    const double dashWidth = 6;
    const double dashSpace = 5;
    final paint = Paint()
      ..color = const Color(0xFFC7D2FE)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(14),
        ),
      );

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}