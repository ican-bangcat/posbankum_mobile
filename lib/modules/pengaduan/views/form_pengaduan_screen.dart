import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../controllers/pengaduan_controller.dart';

class FormPengaduanScreen extends GetView<PengaduanController> {
  const FormPengaduanScreen({super.key});

  // Daftar Kategori (UI Only)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Buat Pengaduan'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Icon
            _buildHeaderIcon(),

            const SizedBox(height: 24),

            // Jenis Masalah (Dropdown)
            _buildJenisMasalahField(),

            const SizedBox(height: 20),
          // ✅ POSISI BARU: Tanggal Kejadian
            _buildTanggalKejadianField(context),
            const SizedBox(height: 20),
            // Kronologi Singkat
            _buildKronologiField(),

            const SizedBox(height: 20),

            // Lokasi Kejadian
            _buildLokasiField(),

            const SizedBox(height: 20),

            // Lampiran
            _buildLampiranField(),

            const SizedBox(height: 32),

            // Submit Button
            _buildSubmitButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_document,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat Pengaduan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Isi form di bawah untuk membuat pengaduan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
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
        const Text(
          'Jenis Masalah',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),

        // Pake GetBuilder supaya UI Dropdown ke-refresh saat dipilih
        GetBuilder<PengaduanController>(
            builder: (controller) {
              return DropdownButtonFormField<String>(
                value: controller.selectedKategori,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Pilih jenis masalah',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
                items: _kategoriMasalah.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(
                      kategori,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedKategori = value;
                  controller.update(); // Refresh tampilan dropdown
                },
              );
            }
        ),
      ],
    );
  }

  Widget _buildKronologiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kronologi Singkat',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.kronologiC, // Konek ke Controller
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Jelaskan kronologi permasalahan Anda...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }
// ✅ WIDGET BARU: INPUT TANGGAL
  Widget _buildTanggalKejadianField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Kejadian',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.tglKejadianC, // Konek ke controller
          readOnly: true, // Gaboleh ketik manual, harus lewat kalender
          onTap: () => controller.pickDate(context), // Buka Kalender saat diklik
          decoration: InputDecoration(
            hintText: 'Pilih tanggal kejadian',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }
  Widget _buildLokasiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi Kejadian',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.lokasiC, // Konek ke Controller
          decoration: InputDecoration(
            hintText: 'Masukkan lokasi kejadian',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildLampiranField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lampiran (Opsional)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),

        // Obx untuk memantau perubahan nama file
        Obx(() {
          // KONDISI 1: Belum pilih file
          if (controller.selectedFileName.value.isEmpty) {
            return InkWell(
              onTap: () => controller.pickFile(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unggah Lampiran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('File: PDF, JPG, PNG (maks 5 MB)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            );
          }

          // KONDISI 2: Sudah pilih file
          else {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file, color: Colors.green[700], size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.selectedFileName.value,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text('File berhasil dipilih', style: TextStyle(fontSize: 12, color: Colors.green)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.removeFile(),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : () => controller.submitPengaduan(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text('Kirim Pengaduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      )),
    );
  }
}