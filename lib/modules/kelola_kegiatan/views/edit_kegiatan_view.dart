import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/edit_kegiatan_controller.dart';

class EditKegiatanView extends GetView<EditKegiatanController> {
  const EditKegiatanView({super.key});

  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: Obx(() {
                if (controller.isLoading.value && controller.judulCtrl.text.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- FOTO SAMPUL ---
                      const Text("Foto Sampul", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary)),
                      const SizedBox(height: 12),
                      _buildPhotoUploader(),

                      const SizedBox(height: 24),

                      // --- FORM INPUTS ---
                      _buildFieldLabel("Judul Kegiatan"),
                      _buildTextField(controller.judulCtrl, "Contoh: Penyuluhan Hukum..."),

                      const SizedBox(height: 20),

                      // Row Tanggal & Waktu
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel("Tanggal"),
                                _buildClickableField(
                                  onTap: () => controller.pickDate(context),
                                  text: controller.selectedDate.value == null
                                      ? "Pilih"
                                      : DateFormat('dd/MM/yyyy').format(controller.selectedDate.value!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel("Waktu"),
                                _buildClickableField(
                                  onTap: () => controller.pickTime(context),
                                  text: controller.selectedTime.value == null
                                      ? "Pilih"
                                      : "${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildFieldLabel("Lokasi"),
                      _buildTextField(controller.lokasiCtrl, "Balai Desa...", icon: Icons.location_on_outlined),

                      const SizedBox(height: 20),
                      _buildFieldLabel("Deskripsi Kegiatan"),
                      _buildTextField(controller.deskripsiCtrl, "Jelaskan detail...", isMultiLine: true),

                      const SizedBox(height: 32),

                      // --- TOMBOL SIMPAN ---
                      ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.updateKegiatan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Simpan Kegiatan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Desain kotak gambar + tombol Ganti Foto
  Widget _buildPhotoUploader() {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Gambar
          SizedBox(
            height: 160,
            width: double.infinity,
            child: controller.selectedImage.value != null
                ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
                : (controller.existingImageUrl.value.isNotEmpty
                ? Image.network(controller.existingImageUrl.value, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image, color: Colors.grey))
                : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40))),
          ),
          // Bagian Bawah Gambar (Teks & Tombol)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ubah Foto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary)),
                      SizedBox(height: 4),
                      Text('Klik untuk mengganti foto kegiatan', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: controller.pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlueColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Ganti F...', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {IconData? icon, bool isMultiLine = false}) {
    return TextField(
      controller: ctrl,
      maxLines: isMultiLine ? 5 : 1,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF94A3B8), size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildClickableField({required VoidCallback onTap, required String text}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(color: text == "Pilih" ? const Color(0xFF94A3B8) : textPrimary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(bottom: 0, left: 0, child: Container(width: 50, height: 50, color: bgLight)),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(color: darkBlueColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28))),
          child: Stack(
            children: [
              Positioned(
                top: -10, right: -5,
                child: Opacity(opacity: 0.8, child: Image.asset('assets/images/icons/building_illustration3.png', width: 300, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const SizedBox())),
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Edit kegiatan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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