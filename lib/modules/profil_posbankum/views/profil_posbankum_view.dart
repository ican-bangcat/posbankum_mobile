import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/profil_posbankum_controller.dart';

class ProfilPosbankumView extends GetView<ProfilPosbankumController> {
  const ProfilPosbankumView({super.key});

  // --- PALET WARNA ---
  static const Color navy = Color(0xFF2A2E5E);
  static const Color primaryBlue = Color(0xFF1152D4);
  static const Color orangeAction = Color(0xFFEA580C);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    Get.put(ProfilPosbankumController());

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Obx(() {
          // Tampilkan loading spinner kalau data masih ditarik dari Web
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // 1. SUMMARY CARD
                _buildSummaryCard(),
                const SizedBox(height: 20),

                // 2. INFORMASI POSBANKUM
                _buildInformasiSection(),
                const SizedBox(height: 20),

                // 3. DAFTAR PARALEGAL
                _buildParalegalSection(),
                const SizedBox(height: 30),

                // 4. TOMBOL LOGOUT
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // WIDGET HELPER (MURNI READ-ONLY)
  // ════════════════════════════════════════════════════

  // 1. Summary Card
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primaryBlue, navy]),
              boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.business, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            controller.namaPosbankum.value.isEmpty ? 'Belum ada nama' : controller.namaPosbankum.value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
          ),
          const SizedBox(height: 4),
          Text(
            '${controller.kecamatan.value.isEmpty ? '-' : controller.kecamatan.value}, ${controller.kabupaten.value.isEmpty ? '-' : controller.kabupaten.value}',
            style: const TextStyle(fontSize: 13, color: textLight),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.mail_outline, color: primaryBlue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(controller.email.value.isEmpty ? '-' : controller.email.value, style: const TextStyle(fontSize: 13, color: textDark))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people_outline, color: primaryBlue, size: 16),
                    const SizedBox(width: 8),
                    Text('${controller.jmlParalegal.value} Paralegal', style: const TextStyle(fontSize: 13, color: textDark)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.key, size: 16, color: Colors.white),
              label: const Text('Ubah Password', style: TextStyle(color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeAction,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Informasi Posbankum
  Widget _buildInformasiSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Informasi Posbankum'),
          const SizedBox(height: 16),
          _buildStaticField('Nama Posbankum', controller.namaPosbankum.value, icon: Icons.business),
          _buildStaticField('Email', controller.email.value, icon: Icons.mail_outline),
          Row(
            children: [
              Expanded(child: _buildStaticField('Kabupaten', controller.kabupaten.value)),
              const SizedBox(width: 12),
              Expanded(child: _buildStaticField('Kecamatan', controller.kecamatan.value)),
            ],
          ),
          _buildStaticField('Kelurahan', controller.kelurahan.value, icon: Icons.location_on_outlined),
          _buildStaticField('Alamat', controller.alamat.value),
          _buildStaticField('Kode Pos', controller.kodePos.value),
        ],
      ),
    );
  }

  // 3. Daftar Paralegal (Otomatis Looping semua Paralegal)
  Widget _buildParalegalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Daftar Paralegal'),
          const SizedBox(height: 16),

          if (controller.paralegalList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Belum ada data paralegal', style: TextStyle(color: textLight, fontStyle: FontStyle.italic)),
              ),
            )
          else
          // Looping membuat kartu paralegal sebanyak data yang ada
            Column(
              children: controller.paralegalList.map((paralegal) {
                bool isUtama = paralegal['is_primary'] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUtama ? Colors.blue.shade50.withOpacity(0.3) : bgLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isUtama ? Colors.blue.shade100 : Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Hanya muncul untuk Paralegal Utama
                      if (isUtama) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(20)),
                              child: const Row(
                                children: [
                                  Icon(Icons.shield_outlined, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('Paralegal Utama', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Info Nama & Telp Paralegal
                      _buildStaticField('Nama Paralegal', paralegal['nama_paralegal']?.toString() ?? '-', icon: Icons.person_outline),
                      _buildStaticField('Nomor Telepon', paralegal['nomor_telepon']?.toString() ?? '-', icon: Icons.phone_outlined),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // --- KOMPONEN MICRO HELPER ---

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
      ],
    );
  }

  // Desain Modern List untuk data yang di-fetch dari Supabase
  Widget _buildStaticField(String label, String value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: primaryBlue.withOpacity(0.8)),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textLight)),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: value.isEmpty ? textLight.withOpacity(0.5) : textDark,
                    fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Tombol Logout
  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _showCustomLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 22),
            SizedBox(width: 10),
            Text('Keluar Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  void _showCustomLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.power_settings_new_rounded, color: Colors.red.shade600, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Keluar Akun?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textDark),
              ),
              const SizedBox(height: 12),
              const Text(
                'Anda harus login kembali untuk mengakses data Posbankum. Lanjutkan?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textLight, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal', style: TextStyle(color: textLight, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Tutup dialog konfirmasi
                        
                        // Tampilkan loading
                        Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.white)), barrierDismissible: false);
                        
                        try {
                          await Supabase.instance.client.auth.signOut();
                          await GetStorage().erase();
                          
                          Get.back(); // Tutup loading
                          Get.offAllNamed(AppRoutes.LOGIN); // Arahkan ke halaman login
                          
                          // Tampilkan notifikasi premium
                          _showPremiumSnackbar();
                        } catch (e) {
                          Get.back(); // Tutup loading
                          Get.snackbar('Error', 'Gagal keluar: $e', backgroundColor: Colors.red.shade600, colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red.shade600,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: navy.withOpacity(0.7),
      barrierDismissible: true,
    );
  }

  void _showPremiumSnackbar() {
    Get.snackbar(
      '',
      '',
      titleText: const Text('Sampai Jumpa!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      messageText: const Text('Anda telah berhasil keluar dengan aman.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 36),
      shouldIconPulse: false,
      backgroundColor: const Color(0xFF10B981), // Emerald green
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      boxShadows: [
        BoxShadow(
          color: const Color(0xFF10B981).withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}