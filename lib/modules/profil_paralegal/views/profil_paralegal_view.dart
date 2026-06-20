import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_paralegal_controller.dart';
import '../../../app/routes/app_routes.dart';

class ProfilParalegalView extends GetView<ProfilParalegalController> {
  const ProfilParalegalView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfilParalegalController());

    final double paddingTop = MediaQuery.of(context).padding.top;
    final double headerHeight = paddingTop + 140;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2A2E5E)));
        }
        return Stack(
          children: [
            Positioned(
              top: headerHeight - 20, right: 0, width: 100, height: 100,
              child: Container(color: const Color(0xFF2A2E5E)),
            ),
            Positioned(
              top: headerHeight, left: 0, right: 0, bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(40)),
                ),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2E5E),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40)),
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      'assets/images/icons/building_illustration.png',
                      fit: BoxFit.cover, alignment: Alignment.topCenter,
                      errorBuilder: (c, e, s) => const SizedBox(),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSummaryCard(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildDataDiriCard(),
                          const SizedBox(height: 20),
                          _buildRiwayatCard(),
                          const SizedBox(height: 30),
                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: const Color(0xFF4A61A8), borderRadius: BorderRadius.circular(16)),
                    child: Obx(() {
                      bool hasAvatar = controller.avatarUrl.value.isNotEmpty;
                      if (hasAvatar) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(controller.avatarUrl.value, fit: BoxFit.cover),
                        );
                      }
                      String initials = controller.namaLengkap.value.isNotEmpty
                          ? controller.namaLengkap.value[0].toUpperCase() : 'P';
                      return Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)));
                    }),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(controller.namaLengkap.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                    const SizedBox(height: 4),
                    const Text('Paralegal Posbankum', style: TextStyle(color: Color(0xFF4A61A8), fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium_outlined, size: 12, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            'Anggota Sejak ${controller.memberSince.value}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() => _buildStatItem(controller.totalPengaduan.value, 'Pengaduan')),
              Obx(() => _buildStatItem(controller.totalDiproses.value, 'Diproses')),
              Obx(() => _buildStatItem(controller.totalSelesai.value, 'Selesai')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2E5E))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildDataDiriCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Data Diri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.EDIT_PROFILE_PARALEGAL),
                child: const Row(
                  children: [
                    Icon(Icons.edit_document, size: 14, color: Color(0xFF2A2E5E)),
                    SizedBox(width: 4),
                    Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2A2E5E))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => _buildDataItem(Icons.person_outline, 'Nama Lengkap', controller.namaLengkap.value)),
          const Divider(color: Color(0xFFF1F5F9)),
          Obx(() => _buildDataItem(Icons.phone_outlined, 'No. Telepon', controller.noHp.value)),
          const Divider(color: Color(0xFFF1F5F9)),
          Obx(() => _buildDataItem(Icons.email_outlined, 'Email', controller.email.value)),
          const Divider(color: Color(0xFFF1F5F9)),
          Obx(() => _buildDataItem(Icons.business_outlined, 'Posbankum Penugasan', controller.namaPosbankum.value)),
        ],
      ),
    );
  }

  Widget _buildDataItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Pengaduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              InkWell(
                onTap: () => Get.toNamed('/daftar-pengaduan'),
                child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A61A8))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => controller.riwayatPengaduan.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Belum ada riwayat pengaduan.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          )
              : ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.riwayatPengaduan.length,
            separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final item = controller.riwayatPengaduan[index];
              return _buildRiwayatItem(
                  item['judul'] ?? '-',
                  item['sub'] ?? '-',
                  item['status'] ?? '-',
                  item['color'] as Color? ?? Colors.grey
              );
            },
          )),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(String title, String subtitle, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
            child: const Icon(Icons.description_outlined, color: Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => controller.logout(),
          highlightColor: const Color(0xFFFCA5A5).withOpacity(0.2),
          splashColor: const Color(0xFFF87171).withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]
                  ),
                  child: const Icon(Icons.power_settings_new_rounded, size: 20, color: Color(0xFFEF4444)),
                ),
                const SizedBox(width: 14),
                const Text('Keluar dari Akun', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFDC2626), letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}