import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  // --- Palet Warna ---
  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color bgLight = Color(0xFFF8FAFC); // Warna background abu-abu terang
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF64748B);
  static const Color primaryBlue = Color(0xFF1152D4);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller jika belum ter-bind
    Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: darkBlueColor, // Latar belakang utama jadi biru tua
      body: Column(
        children: [
          // --- HEADER MELENGKUNG (Sama dengan Edit Kegiatan) ---
          _buildHeader(),

          // --- BADAN UTAMA ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: bgLight,
                // Lengkungan di sudut kanan atas
                borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- FOTO PROFIL DENGAN PENCIL ICON ---
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Obx(() {
                          if (controller.isLoadingData.value) {
                            return const CircleAvatar(
                              radius: 56,
                              backgroundColor: Color(0xFFF1F5F9),
                              child: CircularProgressIndicator(color: primaryBlue),
                            );
                          }

                          // Cek apakah ada foto baru yang dipilih, kalau ada tampilkan itu dulu
                          final hasLocalImage = controller.selectedImageBytes.value != null;
                          final hasNetworkImage = controller.avatarUrl.value.isNotEmpty;

                          return CircleAvatar(
                            radius: 56,
                            backgroundColor: const Color(0xFFF1F5F9),
                            // Pakai "as ImageProvider" agar Dart tidak bingung
                            backgroundImage: hasLocalImage
                                ? MemoryImage(controller.selectedImageBytes.value!) as ImageProvider
                                : (hasNetworkImage ? NetworkImage(controller.avatarUrl.value) as ImageProvider : null),
                            child: (!hasLocalImage && !hasNetworkImage)
                                ? const Icon(Icons.person, size: 50, color: textLight)
                                : null,
                          );
                        }),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: bgLight, width: 3),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // NAMA REAKTIF DARI DATABASE
                    Obx(() => Text(
                      controller.displayNama.value,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
                    )),
                    const SizedBox(height: 4),

                    // TOMBOL BUKA GALERI
                    GestureDetector(
                      onTap: () => controller.pickFoto(),
                      child: const Text(
                        'Change Profile Photo',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryBlue),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- FORM INPUT TEKS ---
                    _buildInputLabel('Nama Lengkap'),
                    _buildTextField(
                      controller: controller.namaC,
                      hintText: 'Nama Lengkap',
                      icon: Icons.person_outline,
                    ),

                    _buildInputLabel('Alamat email'),
                    _buildTextField(
                      controller: controller.emailC,
                      hintText: 'Alamat email lengkap',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true, // Email dikunci
                    ),

                    _buildInputLabel('No Telpon'),
                    _buildTextField(
                      controller: controller.noHpC,
                      hintText: 'cth: 081266054809',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    // --- BAGIAN ALAMAT ---
                    _buildInputLabel('Alamat Lengkap (Jalan, RT/RW)'),
                    _buildTextField(
                      controller: controller.alamatDetailC,
                      hintText: 'Cth: Jl. Umban Sari No. 1, RT 01 / RW 02',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // 1. DROPDOWN KABUPATEN
                    _buildInputLabel('Kabupaten / Kota'),
                    Obx(() => _buildDropdown(
                      hint: 'Pilih Kabupaten',
                      value: controller.selectedKabupatenId.value,
                      items: controller.listKabupaten,
                      onChanged: (newValue) {
                        controller.selectedKabupatenId.value = newValue as int;
                        controller.fetchKecamatan(newValue);
                      },
                    )),

                    // 2. DROPDOWN KECAMATAN
                    _buildInputLabel('Kecamatan'),
                    Obx(() => _buildDropdown(
                      hint: controller.selectedKabupatenId.value == null
                          ? 'Pilih Kabupaten dulu'
                          : 'Pilih Kecamatan',
                      value: controller.selectedKecamatanId.value,
                      items: controller.listKecamatan,
                      onChanged: controller.listKecamatan.isEmpty ? null : (newValue) {
                        controller.selectedKecamatanId.value = newValue as int;
                        controller.fetchKelurahan(newValue);
                      },
                    )),

                    // 3. DROPDOWN KELURAHAN
                    _buildInputLabel('Kelurahan / Desa'),
                    Obx(() => _buildDropdown(
                      hint: controller.selectedKecamatanId.value == null
                          ? 'Pilih Kecamatan dulu'
                          : 'Pilih Kelurahan',
                      value: controller.selectedKelurahanId.value,
                      items: controller.listKelurahan,
                      onChanged: controller.listKelurahan.isEmpty ? null : (newValue) {
                        controller.selectedKelurahanId.value = newValue as int;
                      },
                    )),

                    const SizedBox(height: 40),

                    // --- TOMBOL SIMPAN ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.simpanProfil(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Obx(() => controller.isSaving.value
                            ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                            : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        )
                        ),
                      ),
                    ),
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

  // ════════════════════════════════════════════════════
  // WIDGET HELPER
  // ════════════════════════════════════════════════════

  // Header melengkung
  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(bottom: 0, left: 0, child: Container(width: 50, height: 50, color: bgLight)),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
              color: darkBlueColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28))
          ),
          child: Stack(
            children: [
              Positioned(
                top: -10, right: -5,
                child: Opacity(
                    opacity: 0.8,
                    child: Image.asset(
                        'assets/images/icons/building_illustration3.png',
                        width: 300,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox()
                    )
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Edit profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textDark),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(fontSize: 14, color: readOnly ? textLight : textDark),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: const Color(0xFF94A3B8), size: 22)
            : Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
        ),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required int? value,
    required List items,
    required void Function(dynamic)? onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
      decoration: InputDecoration(
        filled: true,
        fillColor: onChanged == null ? const Color(0xFFF1F5F9) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
      ),
      hint: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
      items: items.map<DropdownMenuItem<int>>((item) {
        return DropdownMenuItem<int>(
          value: item['id'],
          child: Text(item['nama'], style: const TextStyle(fontSize: 14, color: textDark)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}