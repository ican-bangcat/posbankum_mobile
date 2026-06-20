import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profil_paralegal_controller.dart';
import '../../../app/routes/app_routes.dart';

class EditProfilParalegalView extends GetView<EditProfilParalegalController> {
  const EditProfilParalegalView({super.key});

  static const Color primaryBlue = Color(0xFF1A1F4E);
  static const Color accentBlue = Color(0xFF4A61AD);
  static const Color bgLight = Color(0xFFF8FAFF);
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
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(24, 32, 24, 40 + bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoSection(),
                    const SizedBox(height: 32),
                    _buildSectionLabel('INFORMASI PRIBADI'),
                    const SizedBox(height: 20),
                    _buildLabelWithStar('Nama Lengkap', Icons.person_outline_rounded, isRequired: false),
                    const SizedBox(height: 8),
                    _buildInputField(controller.namaC, readOnly: true),
                    
                    const SizedBox(height: 20),
                    _buildLabelWithStar('Nomor Telepon', Icons.phone_outlined),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller.noHpC, 
                      hint: '08xxxxxxxxxx', 
                      keyboardType: TextInputType.phone,
                      maxLength: 15,
                    ),

                    const SizedBox(height: 20),
                    _buildLabelWithStar('Email Aktif', Icons.email_outlined, isRequired: false),
                    const SizedBox(height: 8),
                    _buildInputField(controller.emailC, readOnly: true),

                    const SizedBox(height: 20),
                    _buildLabelWithStar('Posbankum Penugasan', Icons.business_outlined, isRequired: false),
                    const SizedBox(height: 8),
                    Obx(() => _buildInputField(
                      TextEditingController(text: controller.posbankumName.value),
                      readOnly: true,
                    )),

                    const SizedBox(height: 32),
                    _buildSectionLabel('KEAMANAN'),
                    const SizedBox(height: 16),
                    _buildSecurityCard(),
                    const SizedBox(height: 40),
                    
                    _buildBigSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            const Text(
              'Edit Profil Paralegal',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Obx(() => GestureDetector(
              onTap: controller.isSaving.value ? null : () => controller.simpanProfil(),
              child: Text(
                controller.isSaving.value ? '...' : 'Simpan',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
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
                    color: const Color(0xFFD1D5DB),
                    border: Border.all(color: Colors.white, width: 2),
                    image: hasLocal
                        ? DecorationImage(image: MemoryImage(controller.selectedImageBytes.value!), fit: BoxFit.cover)
                        : (hasNetwork ? DecorationImage(image: NetworkImage(controller.avatarUrl.value), fit: BoxFit.cover) : null),
                  ),
                  child: (!hasLocal && !hasNetwork)
                      ? const Center(child: Text('P', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)))
                      : null,
                );
              }),
              GestureDetector(
                onTap: () => controller.pickFoto(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: const Icon(Icons.camera_alt_rounded, size: 18, color: primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Ganti Foto', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
        Icon(icon, size: 16, color: accentBlue),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textGray)),
        if (isRequired) const Text(' *', style: TextStyle(color: errorRed, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInputField(TextEditingController ctrl, {String? hint, TextInputType? keyboardType, int maxLines = 1, bool readOnly = false, int? maxLength}) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF1F5F9) : bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
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
          color: readOnly ? textGray : textDark,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.toNamed(AppRoutes.UPDATE_PASSWORD),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.key_rounded, color: accentBlue, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                      Text('Ganti kata sandi akun Anda', style: TextStyle(color: textGray, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: textGray),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBigSaveButton() {
    return Obx(() => GestureDetector(
      onTap: controller.isSaving.value ? null : () => controller.simpanProfil(),
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
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
}
