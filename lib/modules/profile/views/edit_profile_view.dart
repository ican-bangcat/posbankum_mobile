import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

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
    if (!Get.isRegistered<EditProfileController>()) {
      Get.put(EditProfileController());
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
                                  'Edit Profil',
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
                              
                              _buildLabelWithStar('Nama Lengkap', Icons.person_outline_rounded),
                              const SizedBox(height: 12),
                              _buildInputField(controller.namaC, hint: 'Masukkan nama lengkap'),
                              
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildLabelWithStar('NIK', Icons.badge_outlined),
                                  ValueListenableBuilder(
                                    valueListenable: controller.nikC,
                                    builder: (context, value, child) {
                                      return Text(
                                        '${value.text.length}/16',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller.nikC, 
                                hint: '1234567890123456', 
                                keyboardType: TextInputType.number,
                                maxLength: 16,
                              ),

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
                              _buildLabelWithStar('Email Aktif', Icons.email_outlined),
                              const SizedBox(height: 12),
                              _buildInputField(controller.emailC, readOnly: true),

                              const SizedBox(height: 32),
                              _buildSectionLabel('LOKASI'),
                              const SizedBox(height: 20),
                              
                              _buildLabelWithStar('Kabupaten / Kota', Icons.location_city_outlined, isRequired: false),
                              const SizedBox(height: 12),
                              Obx(() => _buildDropdownField(
                                context,
                                hint: 'Pilih Kabupaten / Kota',
                                selectedId: controller.selectedKabupatenId.value,
                                items: controller.listKabupaten,
                                idKey: 'id_kabupaten',
                                isEnabled: true,
                                onTap: () => _showCascadingLocationSheet(context, initialStep: 0),
                              )),

                              const SizedBox(height: 20),
                              _buildLabelWithStar('Kecamatan', Icons.map_outlined, isRequired: false),
                              const SizedBox(height: 12),
                              Obx(() => _buildDropdownField(
                                context,
                                hint: controller.selectedKabupatenId.value == null ? 'Pilih kabupaten dahulu' : 'Pilih Kecamatan',
                                selectedId: controller.selectedKecamatanId.value,
                                items: controller.listKecamatan,
                                idKey: 'id_kecamatan',
                                isEnabled: controller.selectedKabupatenId.value != null,
                                onTap: () => _showCascadingLocationSheet(context, initialStep: 1),
                              )),

                              const SizedBox(height: 20),
                              _buildLabelWithStar('Kelurahan / Desa', Icons.corporate_fare_outlined, isRequired: false),
                              const SizedBox(height: 12),
                              Obx(() => _buildDropdownField(
                                context,
                                hint: controller.selectedKecamatanId.value == null ? 'Pilih kecamatan dahulu' : 'Pilih Kelurahan / Desa',
                                selectedId: controller.selectedKelurahanId.value,
                                items: controller.listKelurahan,
                                idKey: 'id_kelurahan',
                                isEnabled: controller.selectedKecamatanId.value != null,
                                onTap: () => _showCascadingLocationSheet(context, initialStep: 2),
                              )),

                              const SizedBox(height: 20),
                              _buildLabelWithStar('Alamat Lengkap', Icons.home_outlined, isRequired: false),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller.alamatDetailC,
                                hint: 'Jalan, nomor rumah, RT/RW...',
                                maxLines: 3,
                              ),

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

  Widget _buildDropdownField(
    BuildContext context, {
    required String hint,
    required String? selectedId,
    required List items,
    required String idKey,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    String? selectedName;
    if (selectedId != null) {
      try {
        final found = items.firstWhere((e) => e[idKey].toString() == selectedId);
        selectedName = found['nama'];
      } catch (_) {}
    }

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF2A2E5E).withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedName ?? hint,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedName != null
                      ? textDark
                      : (isEnabled ? Colors.grey[400] : const Color(0xFF94A3B8)),
                  fontWeight: selectedName != null ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isEnabled ? textGray : const Color(0xFF94A3B8),
              size: 20,
            ),
          ],
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
              // Header Gradient dengan Dekorasilingkaran & Badge Edit
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
                              'Perubahan akan langsung berlaku dan terlihat oleh paralegal.',
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

  void _showCascadingLocationSheet(BuildContext context, {int initialStep = 0}) {
    final activeStep = initialStep.obs;
    final searchCtrl = TextEditingController();
    final searchQuery = ''.obs;

    List getItemsForStep(int step) {
      if (step == 0) return controller.listKabupaten;
      if (step == 1) return controller.listKecamatan;
      return controller.listKelurahan;
    }

    String getIdKeyForStep(int step) {
      if (step == 0) return 'id_kabupaten';
      if (step == 1) return 'id_kecamatan';
      return 'id_kelurahan';
    }

    Get.bottomSheet(
      Builder(
        builder: (sheetContext) {
          final double sheetBottomPadding = MediaQuery.of(sheetContext).padding.bottom;
          return Container(
            height: Get.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: borderLight, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 8),

                // Breadcrumbs / Stepper Header
                Obx(() {
                  final kabId = controller.selectedKabupatenId.value;
                  final kecId = controller.selectedKecamatanId.value;
                  final kelId = controller.selectedKelurahanId.value;

                  String kabName = 'Kabupaten';
                  if (kabId != null) {
                    final found = controller.listKabupaten.firstWhereOrNull((e) => e['id_kabupaten'].toString() == kabId);
                    if (found != null) kabName = found['nama'];
                  }

                  String kecName = 'Kecamatan';
                  if (kecId != null) {
                    final found = controller.listKecamatan.firstWhereOrNull((e) => e['id_kecamatan'].toString() == kecId);
                    if (found != null) kecName = found['nama'];
                  }

                  String kelName = 'Kelurahan';
                  if (kelId != null) {
                    final found = controller.listKelurahan.firstWhereOrNull((e) => e['id_kelurahan'].toString() == kelId);
                    if (found != null) kelName = found['nama'];
                  }

                  final currentStep = activeStep.value;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepIndicator(
                            title: kabName,
                            isActive: currentStep == 0,
                            isCompleted: kabId != null,
                            onTap: () {
                              searchCtrl.clear();
                              searchQuery.value = '';
                              activeStep.value = 0;
                            },
                          ),
                          _buildStepSeparator(),
                          _buildStepIndicator(
                            title: kecName,
                            isActive: currentStep == 1,
                            isCompleted: kecId != null,
                            isEnabled: kabId != null,
                            onTap: () {
                              searchCtrl.clear();
                              searchQuery.value = '';
                              activeStep.value = 1;
                            },
                          ),
                          _buildStepSeparator(),
                          _buildStepIndicator(
                            title: kelName,
                            isActive: currentStep == 2,
                            isCompleted: kelId != null,
                            isEnabled: kecId != null,
                            onTap: () {
                              searchCtrl.clear();
                              searchQuery.value = '';
                              activeStep.value = 2;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const Divider(height: 1, color: borderLight),
                const SizedBox(height: 8),

                // Search Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderLight),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (q) => searchQuery.value = q,
                      decoration: InputDecoration(
                        hintText: 'Cari...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  searchCtrl.clear();
                                  searchQuery.value = '';
                                },
                              )
                            : const SizedBox.shrink()),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // List Items
                Expanded(
                  child: Obx(() {
                    final step = activeStep.value;
                    final items = getItemsForStep(step);
                    final idKey = getIdKeyForStep(step);
                    final query = searchQuery.value.toLowerCase().trim();

                    final filtered = query.isEmpty
                        ? items
                        : items.where((e) => (e['nama'] as String).toLowerCase().contains(query)).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada data ditemukan',
                          style: TextStyle(color: textGray, fontSize: 14),
                        ),
                      );
                    }

                    final selectedId = step == 0
                        ? controller.selectedKabupatenId.value
                        : (step == 1 ? controller.selectedKecamatanId.value : controller.selectedKelurahanId.value);

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + sheetBottomPadding),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        final itemId = item[idKey].toString();
                        final isSelected = itemId == selectedId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? accentBlue.withOpacity(0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              item['nama'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? accentBlue : textDark,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: accentBlue, size: 20)
                                : const Icon(Icons.chevron_right, size: 18, color: textGray),
                            onTap: () async {
                              if (step == 0) {
                                controller.selectedKabupatenId.value = itemId;
                                searchCtrl.clear();
                                searchQuery.value = '';
                                await controller.fetchKecamatan(itemId);
                                activeStep.value = 1;
                              } else if (step == 1) {
                                controller.selectedKecamatanId.value = itemId;
                                searchCtrl.clear();
                                searchQuery.value = '';
                                await controller.fetchKelurahan(itemId);
                                activeStep.value = 2;
                              } else {
                                controller.selectedKelurahanId.value = itemId;
                                Get.back();
                              }
                            },
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStepIndicator({
    required String title,
    required bool isActive,
    required bool isCompleted,
    bool isEnabled = true,
    required VoidCallback onTap,
  }) {
    Color textColor = textGray;
    FontWeight fontWeight = FontWeight.normal;

    if (isActive) {
      textColor = accentBlue;
      fontWeight = FontWeight.bold;
    } else if (isCompleted) {
      textColor = textDark;
      fontWeight = FontWeight.w600;
    }

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? accentBlue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompleted && !isActive)
                const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 16)
              else
                Icon(
                  isActive ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isActive ? accentBlue : textGray,
                  size: 16,
                ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: fontWeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.chevron_right_rounded, color: textGray, size: 16),
    );
  }
}
