import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/info_chat_posbankum_controller.dart';

class InfoChatPosbankumView extends GetView<InfoChatPosbankumController> {
  const InfoChatPosbankumView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color bgColor = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    Get.put(InfoChatPosbankumController());
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ─── HEADER BIRU (TETAP) ───
          _buildHeader(context),

          // ─── BODY SCROLLABLE ───
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding + 30),
              child: Column(
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 32),
                  _buildKasusTerkait(),
                  const SizedBox(height: 32),
                  _buildMediaSection(),
                  const SizedBox(height: 32),
                  _buildSettingsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Header Area
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10, right: -10,
            child: Opacity(opacity: 0.1, child: Image.asset('assets/images/icons/building_illustration3.png', width: 200)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Info Chat', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Online', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Profile Section (Avatar & Nama)
  Widget _buildProfileSection() {
    return Transform.translate(
      offset: const Offset(0, -40), // Menaikkan avatar agar overlap dengan header
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset('assets/images/icons/lawyer_profile.png', width: 120, height: 120, fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(width: 120, height: 120, color: Colors.grey[300], child: const Icon(Icons.person, size: 60))),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Posbakum Tuah Madani', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text('VERIFIED PROVIDER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: primaryBlue, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          const Text('Sertifikasi Akreditasi A • Aktif', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 24),
          // Search Button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.search, color: primaryBlue, size: 28),
          ),
          const SizedBox(height: 8),
          const Text('SEARCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  // 3. Kasus Terkait Section
  Widget _buildKasusTerkait() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kasus Terkait', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text('LIHAT SEMUA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PERDATA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryBlue, letterSpacing: 1.1)),
                      const SizedBox(height: 4),
                      const Text('Sengketa Tanah Waris', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const Text('Case ID: #LAW-2023-089', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEFF6FF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text('Detail >', style: TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Media & Dokumen Section
  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Media & Dokumen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('12 File', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildMediaItem(img: 'assets/images/icons/doc_sample1.png'),
              _buildMediaItem(img: 'assets/images/icons/doc_sample2.png'),
              _buildMediaItem(isPdf: true, fileName: 'SURAT_K...PDF'),
              _buildMediaItem(isMore: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaItem({String? img, bool isPdf = false, bool isMore = false, String? fileName}) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDBEAFE))),
      child: isMore
          ? const Center(child: Text('LIHA...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)))
          : isPdf
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description, color: Colors.blue, size: 30),
          const SizedBox(height: 4),
          Text(fileName!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      )
          : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(img!, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image))),
    );
  }

  // 5. Settings List Section
  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _buildListTile(Icons.notifications_none_rounded, 'Bisukan Notifikasi', hasSwitch: true),
          _buildListTile(Icons.star_outline_rounded, 'Pesan Berbintang'),
          _buildListTile(Icons.lock_outline_rounded, 'Enkripsi End-to-End'),
          _buildListTile(Icons.delete_outline_rounded, 'Bersihkan Chat', isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {bool hasSwitch = false, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF64748B)),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDestructive ? Colors.red : const Color(0xFF0F172A))),
      trailing: hasSwitch
          ? Obx(() => Switch(
        value: controller.isMuted.value,
        onChanged: (v) => controller.toggleMute(v),
        activeColor: primaryBlue,
      ))
          : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}