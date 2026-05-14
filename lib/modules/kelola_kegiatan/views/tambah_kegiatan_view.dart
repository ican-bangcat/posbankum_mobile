import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/tambah_kegiatan_controller.dart';

class TambahKegiatanView extends GetView<TambahKegiatanController> {
  const TambahKegiatanView({super.key});

  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color bgLight = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    Get.put(TambahKegiatanController());

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Foto Sampul (Opsional)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    Obx(() => GestureDetector(
                      onTap: controller.pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                        ),
                        child: controller.selectedImage.value != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover),
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text("Ketuk untuk unggah foto", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                          ],
                        ),
                      ),
                    )),

                    const SizedBox(height: 24),
                    _buildInputCard(),
                    const SizedBox(height: 32),

                    Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.simpanKegiatan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Simpan Kegiatan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    )),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Judul Kegiatan"),
          _buildTextField(controller.judulCtrl, "Contoh: Penyuluhan Hukum Desa"),

          const SizedBox(height: 20),
          _buildFieldLabel("Tanggal Kegiatan"),
          Obx(() => _buildClickableField(
            onTap: () => controller.pickDate(Get.context!),
            text: controller.selectedDate.value == null
                ? "Pilih Tanggal"
                : DateFormat('dd MMMM yyyy').format(controller.selectedDate.value!),
            icon: Icons.calendar_today_outlined,
          )),

          const SizedBox(height: 20),
          _buildFieldLabel("Lokasi Kegiatan"),
          _buildTextField(controller.lokasiCtrl, "Cari lokasi atau masukkan alamat", icon: Icons.location_on_outlined),

          const SizedBox(height: 20),
          _buildFieldLabel("Jumlah Peserta (Opsional)"),
          _buildTextField(controller.jmlPesertaCtrl, "Contoh: 50", icon: Icons.people_outline, keyboardType: TextInputType.number),

          // ✅ TAMBAHAN FIELD: ANGGOTA TERLIBAT (MULTI-SELECT)
          const SizedBox(height: 20),
          _buildFieldLabel("Anggota Terlibat (Opsional)"),
          _buildMultiSelectParalegal(),

          const SizedBox(height: 20),
          _buildFieldLabel("Deskripsi Kegiatan"),
          _buildTextField(controller.deskripsiCtrl, "Jelaskan detail agenda kegiatan...", isMultiLine: true),
        ],
      ),
    );
  }

  // ✅ FUNGSI UI BARU: FIELD MULTI-SELECT
  Widget _buildMultiSelectParalegal() {
    return Obx(() {
      return GestureDetector(
        onTap: () => _showParalegalBottomSheet(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: controller.selectedParalegals.isEmpty
              ? const Text("Pilih anggota yang terlibat...", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14))
              : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.selectedParalegals.map((nama) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: darkBlueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: darkBlueColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(nama, style: const TextStyle(fontSize: 12, color: darkBlueColor, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => controller.toggleParalegal(nama), // Bisa hapus dari luar juga
                      child: const Icon(Icons.close, size: 14, color: darkBlueColor),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  // ✅ FUNGSI UI BARU: BOTTOM SHEET UNTUK PILIH PARALEGAL
  void _showParalegalBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            const Text("Pilih Anggota Terlibat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),

            // List Checkbox Paralegal
            Flexible(
              child: Obx(() {
                if (controller.paralegalList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Belum ada data paralegal di posbankum ini.", style: TextStyle(fontStyle: FontStyle.italic)),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.paralegalList.length,
                  itemBuilder: (context, index) {
                    final nama = controller.paralegalList[index];
                    return Obx(() {
                      final isSelected = controller.selectedParalegals.contains(nama);
                      return CheckboxListTile(
                        title: Text(nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                        value: isSelected,
                        activeColor: darkBlueColor,
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (bool? value) {
                          controller.toggleParalegal(nama);
                        },
                      );
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(backgroundColor: darkBlueColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {IconData? icon, bool isMultiLine = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      maxLines: isMultiLine ? 5 : 1,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        suffixIcon: icon != null ? Icon(icon, color: const Color(0xFF94A3B8), size: 20) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildClickableField({required VoidCallback onTap, required String text, required IconData icon}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(color: text.contains("Pilih") ? const Color(0xFF94A3B8) : Colors.black, fontSize: 14)),
            Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: darkBlueColor),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Tambah Kegiatan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}