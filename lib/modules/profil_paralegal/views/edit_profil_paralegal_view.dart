import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profil_paralegal_controller.dart';

class EditProfilParalegalView extends GetView<EditProfilParalegalController> {
  const EditProfilParalegalView({super.key});

  // --- Palette Warna ---
  static const Color primaryBlue = Color(0xFF2A2E5E);
  static const Color accentBlue = Color(0xFF464E97);
  static const Color bgLight = Color(0xFFF2F4FB);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color errorRed = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<EditProfilParalegalController>()) {
      Get.put(EditProfilParalegalController());
    }

    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: primaryBlue,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650.0),
          child: Column(
            children: [
              // ── HEADER AREA ──
              Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(width: 50, height: 50, color: bgLight),
                  ),
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.zero,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 10,
                          child: Opacity(
                            opacity: 0.25,
                            child: Image.asset(
                              'assets/images/icons/icon_halaman_editProfil.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(),
                            ),
                          ),
                        ),
                        SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                                  ),
                                ),
                                const Text(
                                  'Edit Profil Paralegal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Obx(() => GestureDetector(
                                  onTap: controller.isSaving.value ? null : () => _showSimpanKonfirmasiDialog(context),
                                  child: Text(
                                    controller.isSaving.value ? '...' : 'Simpan',
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                )),
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
                  decoration: const BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(28),
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 40 + bottomPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPhotoSection(),
                              const SizedBox(height: 32),
                              _buildSectionLabel('INFORMASI PRIBADI'),
                              const SizedBox(height: 20),
                              
                              _buildLabelWithStar('Nama Lengkap', Icons.person_outline_rounded, isRequired: false),
                              const SizedBox(height: 12),
                              _buildInputField(controller.namaC, readOnly: true),
                              
                              const SizedBox(height: 20),
                              _buildLabelWithStar('Nomor Telepon', Icons.phone_outlined),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller.noHpC, 
                                hint: '08xxxxxxxxxx', 
                                keyboardType: TextInputType.phone,
                                maxLength: 15,
                              ),

                              const SizedBox(height: 20),
                              _buildLabelWithStar('Email Aktif', Icons.email_outlined, isRequired: false),
                              const SizedBox(height: 12),
                              _buildInputField(controller.emailC, readOnly: true),

                              const SizedBox(height: 20),
                              _buildLabelWithStar('Posbankum Penugasan', Icons.business_outlined, isRequired: false),
                              const SizedBox(height: 12),
                              Obx(() => _buildInputField(
                                TextEditingController(text: controller.posbankumName.value),
                                readOnly: true,
                              )),

                              const SizedBox(height: 40),
                              _buildBigSaveButton(context),
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

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => controller.pickFoto(),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Obx(() {
                  final hasLocal = controller.selectedImageBytes.value != null;
                  final hasNetwork = controller.avatarUrl.value.isNotEmpty;
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE2E8F0),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2A2E5E).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: hasLocal
                          ? DecorationImage(image: MemoryImage(controller.selectedImageBytes.value!), fit: BoxFit.cover)
                          : (hasNetwork ? DecorationImage(image: NetworkImage(controller.avatarUrl.value), fit: BoxFit.cover) : null),
                    ),
                    child: (!hasLocal && !hasNetwork)
                        ? const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  );
                }),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: accentBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.pickFoto(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.edit_rounded, size: 14, color: accentBlue),
                SizedBox(width: 4),
                Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    color: accentBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: accentBlue, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textGray, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildLabelWithStar(String label, IconData icon, {bool isRequired = true}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFE4E6F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: accentBlue),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              color: errorRed,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildInputField(
    TextEditingController ctrl, {
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: readOnly
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF2A2E5E).withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: ctrl,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: readOnly ? const Color(0xFF64748B) : textDark,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          counterText: '',
          filled: true,
          fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: readOnly ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: readOnly ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: readOnly ? const Color(0xFFCBD5E1) : accentBlue,
              width: readOnly ? 1.0 : 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBigSaveButton(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: controller.isSaving.value ? null : () => _showSimpanKonfirmasiDialog(context),
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: accentBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: accentBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: controller.isSaving.value
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
        ),
      ),
    ));
  }

  void _showSimpanKonfirmasiDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.hardEdge,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Gradient dengan Dekorasi lingkaran & Badge Edit
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2B3A67), Color(0xFF4A61A8)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge Ikon Dokumen / Edit
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title Header
                    const Text(
                      'Simpan Perubahan?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Body Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Apakah Anda yakin ingin menyimpan perubahan data profil? Data lama akan digantikan dengan data baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info Warning Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFF475569), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Perubahan akan langsung berlaku dan terlihat oleh sistem.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: controller.isSaving.value
                            ? null
                            : () {
                                Get.back();
                                controller.simpanProfil();
                              },
                        icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                        label: controller.isSaving.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text(
                                'Ya, Simpan Sekarang',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A61A8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    )),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
