import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  // --- Palet Warna ---
  static const Color darkBlue = Color(0xFF1A1F4E);
  static const Color midBlue = Color(0xFF2A2E5E);
  static const Color accentBlue = Color(0xFF1152D4);
  static const Color accentLight = Color(0xFF4F8EF7);
  static const Color bgPage = Color(0xFFF0F4FF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFFB0BFDA);
  static const Color dividerColor = Color(0xFFEEF2FB);
  static const Color successGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    Get.put(EditProfileController());
    return Scaffold(
      backgroundColor: darkBlue,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: bgPage,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoSection(),
                    const SizedBox(height: 28),
                    _buildSectionLabel('INFORMASI PRIBADI'),
                    const SizedBox(height: 10),
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('LOKASI DOMISILI'),
                    const SizedBox(height: 10),
                    _buildLocationCard(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════
  // HEADER
  // ══════════════════════════════
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        child: Row(
          children: [
            _buildIconBtn(Icons.arrow_back_ios_new_rounded, () => Get.back()),
            const Spacer(),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Edit Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Perbarui data dirimu',
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // placeholder to balance the back button
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // ══════════════════════════════
  // PHOTO SECTION
  // ══════════════════════════════
  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Glow ring
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [accentLight, accentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentBlue.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Obx(() {
                    final hasLocal = controller.selectedImageBytes.value != null;
                    final hasNetwork = controller.avatarUrl.value.isNotEmpty;
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bgCard,
                        image: hasLocal
                            ? DecorationImage(
                            image: MemoryImage(controller.selectedImageBytes.value!),
                            fit: BoxFit.cover)
                            : (hasNetwork
                            ? DecorationImage(
                            image: NetworkImage(controller.avatarUrl.value),
                            fit: BoxFit.cover)
                            : null),
                      ),
                      child: (!hasLocal && !hasNetwork)
                          ? const Icon(Icons.person_rounded, size: 52, color: textHint)
                          : null,
                    );
                  }),
                ),
              ),
              // Camera button
              GestureDetector(
                onTap: () => controller.pickFoto(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: accentBlue.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.pickFoto(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentBlue.withOpacity(0.25)),
              ),
              child: const Text(
                'Ganti Foto Profil',
                style: TextStyle(
                  color: accentBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════
  // SECTION LABEL
  // ══════════════════════════════
  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: accentBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: textSecondary,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════
  // INFO CARD
  // ══════════════════════════════
  Widget _buildInfoCard() {
    return _cardWrap([
      _buildField(
        label: 'Nama Lengkap',
        icon: Icons.person_outline_rounded,
        child: _textInput(controller.namaC, hint: 'Masukkan nama lengkap'),
      ),
      _divider(),
      _buildField(
        label: 'NIK (16 Digit)',
        icon: Icons.badge_outlined,
        child: _textInput(
          controller.nikC,
          hint: '1234567890123456',
          keyboardType: TextInputType.number,
          maxLength: 16,
        ),
      ),
      _divider(),
      _buildField(
        label: 'Nomor Telepon',
        icon: Icons.phone_outlined,
        child: _textInput(
          controller.noHpC,
          hint: '08xxxxxxxxxx',
          keyboardType: TextInputType.phone,
        ),
      ),
      _divider(),
      _buildField(
        label: 'Email',
        icon: Icons.email_outlined,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Terverifikasi',
            style: TextStyle(fontSize: 10, color: successGreen, fontWeight: FontWeight.w600),
          ),
        ),
        child: _textInput(controller.emailC, readOnly: true),
      ),
    ]);
  }

  // ══════════════════════════════
  // LOCATION CARD (with searchable dropdown)
  // ══════════════════════════════
  Widget _buildLocationCard() {
    return _cardWrap([
      Obx(() => _buildField(
        label: 'Kabupaten / Kota',
        icon: Icons.location_city_outlined,
        child: _searchableDropdownTile(
          hint: 'Pilih Kabupaten / Kota',
          selectedId: controller.selectedKabupatenId.value,
          items: controller.listKabupaten,
          idKey: 'id_kabupaten',
          isEnabled: true,
          onSelected: (id) {
            controller.selectedKabupatenId.value = id;
            controller.fetchKecamatan(id);
          },
        ),
      )),
      _divider(),
      Obx(() => _buildField(
        label: 'Kecamatan',
        icon: Icons.map_outlined,
        child: _searchableDropdownTile(
          hint: controller.selectedKabupatenId.value == null
              ? 'Pilih kabupaten dahulu'
              : 'Pilih Kecamatan',
          selectedId: controller.selectedKecamatanId.value,
          items: controller.listKecamatan,
          idKey: 'id_kecamatan',
          isEnabled: controller.selectedKabupatenId.value != null,
          onSelected: (id) {
            controller.selectedKecamatanId.value = id;
            controller.fetchKelurahan(id);
          },
        ),
      )),
      _divider(),
      Obx(() => _buildField(
        label: 'Kelurahan / Desa',
        icon: Icons.corporate_fare_outlined,
        child: _searchableDropdownTile(
          hint: controller.selectedKecamatanId.value == null
              ? 'Pilih kecamatan dahulu'
              : 'Pilih Kelurahan / Desa',
          selectedId: controller.selectedKelurahanId.value,
          items: controller.listKelurahan,
          idKey: 'id_kelurahan',
          isEnabled: controller.selectedKecamatanId.value != null,
          onSelected: (id) {
            controller.selectedKelurahanId.value = id;
          },
        ),
      )),
      _divider(),
      _buildField(
        label: 'Alamat Lengkap',
        icon: Icons.home_outlined,
        child: _textInput(
          controller.alamatDetailC,
          hint: 'Jalan, RT/RW, Nomor Rumah',
          maxLines: 2,
        ),
      ),
    ]);
  }

  // ══════════════════════════════
  // SEARCHABLE DROPDOWN TILE
  // ══════════════════════════════
  Widget _searchableDropdownTile({
    required String hint,
    required String? selectedId,
    required List items,
    required String idKey,
    required bool isEnabled,
    required void Function(String) onSelected,
  }) {
    // Find selected item name
    String? selectedName;
    if (selectedId != null) {
      try {
        final found = items.firstWhere((e) => e[idKey].toString() == selectedId);
        selectedName = found['nama'];
      } catch (_) {}
    }

    return GestureDetector(
      onTap: isEnabled
          ? () => _showSearchSheet(
        items: items,
        idKey: idKey,
        onSelected: onSelected,
      )
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedName ?? hint,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selectedName != null
                      ? textPrimary
                      : (isEnabled ? textHint : const Color(0xFFCDD5E0)),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isEnabled ? textSecondary : textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════
  // BOTTOM SHEET SEARCH
  // ══════════════════════════════
  void _showSearchSheet({
    required List items,
    required String idKey,
    required void Function(String) onSelected,
  }) {
    final searchCtrl = TextEditingController();
    final filteredItems = RxList<dynamic>.from(items);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.72,
        decoration: const BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cari & Pilih',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: bgPage,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: TextField(
                  controller: searchCtrl,
                  autofocus: true,
                  onChanged: (q) {
                    filteredItems.value = q.isEmpty
                        ? items
                        : items
                        .where((e) => (e['nama'] as String)
                        .toLowerCase()
                        .contains(q.toLowerCase()))
                        .toList();
                  },
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ketik untuk mencari...',
                    hintStyle: TextStyle(color: textHint, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: textSecondary, size: 22),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // List
            Expanded(
              child: Obx(() => filteredItems.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 48, color: textHint),
                    SizedBox(height: 8),
                    Text(
                      'Tidak ditemukan',
                      style: TextStyle(color: textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: filteredItems.length,
                itemBuilder: (ctx, i) {
                  final item = filteredItems[i];
                  return _sheetItem(
                    label: item['nama'],
                    onTap: () {
                      onSelected(item[idKey].toString());
                      Get.back();
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _sheetItem({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgPage,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dividerColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: textHint, size: 20),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════
  // SAVE BUTTON
  // ══════════════════════════════
  Widget _buildSaveButton() {
    return Obx(() => GestureDetector(
      onTap: controller.isSaving.value ? null : () => controller.simpanProfil(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: controller.isSaving.value
              ? const LinearGradient(colors: [Color(0xFFB0BFDA), Color(0xFFB0BFDA)])
              : const LinearGradient(
            colors: [accentLight, accentBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: controller.isSaving.value
              ? []
              : [
            BoxShadow(
              color: accentBlue.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: controller.isSaving.value
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Simpan Perubahan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  // ══════════════════════════════
  // SHARED HELPERS
  // ══════════════════════════════

  Widget _cardWrap(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentBlue, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing,
                    ]
                  ],
                ),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    thickness: 1,
    color: dividerColor,
    indent: 70,
    endIndent: 16,
  );

  Widget _textInput(
      TextEditingController ctrl, {
        String? hint,
        TextInputType? keyboardType,
        int maxLines = 1,
        bool readOnly = false,
        int? maxLength,
      }) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: readOnly ? textSecondary : textPrimary,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        hintText: hint,
        hintStyle: const TextStyle(color: textHint, fontSize: 14, fontWeight: FontWeight.w400),
        border: InputBorder.none,
        counterText: '',
      ),
    );
  }
}