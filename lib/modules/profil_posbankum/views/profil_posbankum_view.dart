import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
}