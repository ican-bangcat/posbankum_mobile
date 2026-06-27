import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/info_chat_posbankum_controller.dart';

class InfoChatPosbankumView extends GetView<InfoChatPosbankumController> {
  const InfoChatPosbankumView({super.key});

  final Color darkBlue = const Color(0xFF2B3163);
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color bgColor = const Color(0xFFF4F4F5);

  @override
  Widget build(BuildContext context) {
    Get.put(InfoChatPosbankumController());
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(0, 24, 0, bottomPadding + 30),
                child: Column(
                  children: [
                    _buildActionButtons(),
                    _buildDataKlien(),
                    _buildKasusTerkait(),
                    _buildMediaSection(),
                    _buildSettingsSection(),
                    _buildClearChat(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: darkBlue,
      child: Stack(
        children: [
          Positioned(
            bottom: -20,
            right: -20,
            left: -20,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/icons/building_illustration3.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white38),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Info Chat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Online', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange.shade300, width: 2), // Orange border
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          color: const Color(0xFF1E3A8A), // Inner blue
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 20,
                                child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFFFDE047), shape: BoxShape.circle)),
                              ),
                              Positioned(
                                bottom: -10,
                                child: Container(width: 70, height: 50, decoration: BoxDecoration(color: const Color(0xFFB45309), borderRadius: BorderRadius.circular(30))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle),
                      child: const Icon(Icons.person_outline, color: Colors.white, size: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Ibu Siti Rahayu', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.orange.shade700),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: Color(0xFFFDE047), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PELAPOR AKTIF',
                        style: TextStyle(color: Color(0xFFFDE047), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Kelurahan Sukamaju • Bandung Selatan', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionItem(Icons.search, 'Cari'),
          _actionItem(Icons.notifications_off_outlined, 'Bisukan'),
          _actionItem(Icons.star_border, 'Bintang'),
          _actionItem(Icons.lock_outline, 'Enkripsi'),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF2D3360), size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDataKlien() {
    return _buildCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Data Klien', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Terverifikasi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDataTile(Icons.shield_outlined, Colors.blue, 'NIK', '3271012505900003'),
        const SizedBox(height: 12),
        _buildDataTile(Icons.phone_outlined, Colors.green, 'No. Telepon', '081234567890'),
        const SizedBox(height: 12),
        _buildDataTile(Icons.business_outlined, Colors.purple, 'Nama Lurah', 'Budi Santoso, S.Sos'),
        const SizedBox(height: 12),
        _buildDataTile(Icons.location_on_outlined, Colors.orange, 'Alamat', 'Jl. Merdeka No. 45, RT 03/RW 05, Sukan...'),
      ],
    );
  }

  Widget _buildDataTile(IconData icon, Color color, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKasusTerkait() {
    return _buildCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Kasus Terkait', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const Text('LIHAT SEMUA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3B5998))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF3B5998),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('SEDANG DIPROSES', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFD97706), letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 6),
                  const Text('Masalah Warisan\nKeluarga', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  const Text('#K-2023-0345', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text('Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return _buildCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Media & Dokumen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('2 File', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Lebar total dibagi 3, dikurangi spacing
            double itemWidth = (constraints.maxWidth - 24) / 3;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMediaDocItem(width: itemWidth, color: Colors.blue, filename: 'SALINAN_PUTUSAN.PDF'),
                _buildMediaDocItem(width: itemWidth, color: Colors.red, filename: 'BERITA_ACARA.PDF', isRed: true),
                _buildMediaImageItem(width: itemWidth, color: const Color(0xFF2D3360), icon: Icons.menu),
                _buildMediaImageItem(width: itemWidth, color: const Color(0xFFF97316), icon: Icons.circle),
                _buildMediaImageItem(width: itemWidth, color: const Color(0xFF059669)),
                _buildMediaMoreItem(width: itemWidth),
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _buildMediaImageItem({required double width, required Color color, IconData? icon}) {
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: icon != null
          ? Center(child: Icon(icon, color: Colors.white.withOpacity(0.3), size: 30))
          : null,
    );
  }

  Widget _buildMediaDocItem({required double width, required Color color, required String filename, bool isRed = false}) {
    return Container(
      width: width,
      height: width,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isRed ? Colors.red.shade50 : Colors.white,
        border: Border.all(color: isRed ? Colors.red.shade100 : Colors.blue.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, color: isRed ? Colors.red : Colors.blue, size: 24),
          const SizedBox(height: 8),
          Text(filename, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: isRed ? Colors.red : Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildMediaMoreItem({required double width}) {
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('+10', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          Text('lainnya', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return _buildCard(
      children: [
        const Text('Pengaturan Chat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        _buildSettingTile(
          icon: Icons.notifications_off_outlined,
          iconColor: Colors.orange.shade700,
          iconBgColor: Colors.orange.shade50,
          title: 'Bisukan Notifikasi',
          trailing: Transform.scale(
            scale: 0.8,
            child: Obx(() => Switch(
              value: controller.isMuted.value,
              onChanged: (v) => controller.toggleMute(v),
              activeColor: Colors.white,
              activeTrackColor: Colors.grey.shade300,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
            )),
          ),
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          icon: Icons.star_border,
          iconColor: Colors.amber.shade600,
          iconBgColor: Colors.amber.shade50,
          title: 'Pesan Berbintang',
          trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          icon: Icons.lock_outline,
          iconColor: Colors.green.shade600,
          iconBgColor: Colors.green.shade50,
          title: 'Enkripsi End-to-End',
          subtitle: 'Pesan dilindungi',
          subtitleColor: Colors.green.shade600,
          trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: subtitleColor ?? Colors.grey)),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildClearChat() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          const Text('Bersihkan Chat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

}