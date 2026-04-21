import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_kasus_paralegal_controller.dart';
import '../../../app/routes/app_routes.dart';

class DetailKasusParalegalView extends GetView<DetailKasusParalegalController> {
  const DetailKasusParalegalView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);
  final Color textPrimary = const Color(0xFF0F172A);
  final Color textSecondary = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    Get.put(DetailKasusParalegalController());

    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                  );
                }

                final kasus = controller.kasus;
                if (kasus == null) return const SizedBox();

                String tglLapor = "${kasus.tanggalPengajuan.day.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.month.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.year}";
                String tglKejadian = "-";
                if (kasus.tanggalKejadian != null) {
                  final tk = kasus.tanggalKejadian!;
                  tglKejadian = "${tk.day.toString().padLeft(2, '0')}/${tk.month.toString().padLeft(2, '0')}/${tk.year}";
                }

                String statusText = '';
                Color statusColor = Colors.grey;
                Color statusBg = Colors.grey.shade100;

                if (kasus.status == 'pending') {
                  statusText = 'PENDING';
                  statusColor = const Color(0xFFF59E0B);
                  statusBg = const Color(0xFFFEF3C7);
                } else if (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses') {
                  statusText = 'SEDANG PROSES';
                  statusColor = const Color(0xFF3B82F6);
                  statusBg = const Color(0xFFEFF6FF);
                } else if (kasus.status == 'selesai') {
                  statusText = 'SELESAI';
                  statusColor = const Color(0xFF10B981);
                  statusBg = const Color(0xFFECFDF5);
                }

                return Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120), // Tambah padding bawah biar gak ketutup tombol
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (controller.isUrgent(kasus.kategori))
                                _buildStatusBadge('URGENT', const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
                              _buildStatusBadge(kasus.kategori.toUpperCase(), textSecondary, Colors.grey.shade200),
                              _buildStatusBadge(statusText, statusColor, statusBg),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            kasus.judul,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ID Kasus: #${kasus.id.toUpperCase()}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), fontFamily: 'Monospace'),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoCard(
                            tglLapor: tglLapor,
                            tglKejadian: tglKejadian,
                            lokasi: kasus.lokasi,
                            namaKlien: kasus.namaKlien ?? '-',
                            noHp: kasus.noHpKlien ?? '-',
                          ),
                          const SizedBox(height: 20),
                          _buildChronologyCard(kasus.deskripsi),
                          const SizedBox(height: 20),

                          // ✅ RIWAYAT TIMELINE
                          _buildRiwayatUpdateCard(),
                        ],
                      ),
                    ),

                    // ✅ TOMBOL AMBIL KASUS
                    if (kasus.status == 'pending')
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: _buildButtonAction(
                          text: 'Ambil Kasus',
                          onPressed: () => controller.ambilKasus(kasus.id),
                          color: const Color(0xFF0F172A),
                          isLoading: controller.isUpdating.value,
                        ),
                      ),

                    // ✅ TOMBOL UPDATE PROGRES
                    if (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses')
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: _buildButtonAction(
                          text: 'Update Progres ✎',
                          onPressed: () => Get.toNamed(AppRoutes.UPDATE_PROGRES, arguments: {'id': kasus.id, 'judul': kasus.judul}),
                          color: const Color(0xFF1E2452),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─── KOMPONEN UI (METHODS) ───

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(bottom: 0, left: 0, child: Container(width: 50, height: 50, color: bgColor)),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -10, right: -5,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/images/icons/building_illustration3.png',
                    width: 300, fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, size: 150, color: Colors.white10),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(result: true),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Detail Kasus', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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

  Widget _buildStatusBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildInfoCard({required String tglLapor, required String tglKejadian, required String lokasi, required String namaKlien, required String noHp}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Kasus', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E2452))),
          const SizedBox(height: 16),
          _buildInfoRow('Tanggal Lapor', tglLapor),
          _buildInfoRow('Tanggal Kejadian', tglKejadian, isAdded: true),
          _buildInfoRow('Lokasi Kejadian', lokasi, icon: Icons.location_on_outlined),
          _buildInfoRow('Nama Masyarakat', namaKlien),
          _buildInfoRow('No. HP Klien', noHp, color: const Color(0xFF2563EB)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon, Color? color, bool isAdded = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(fontSize: 13, color: textSecondary))),
          const Text(':', style: TextStyle(color: Color(0xFFCBD5E1))),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                if (icon != null) ...[Icon(icon, size: 14, color: textSecondary), const SizedBox(width: 6)],
                Flexible(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? textPrimary))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChronologyCard(String kronologi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kronologi Kasus', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E2452))),
          const SizedBox(height: 16),
          Text(kronologi, style: TextStyle(fontSize: 13, color: textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildRiwayatUpdateCard() {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF1E2452)),
                SizedBox(width: 8),
                Text('Riwayat Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
              ],
            ),
            const SizedBox(height: 24),
            if (controller.listProgres.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_empty_rounded, size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text('Belum ada update progres\nuntuk kasus ini.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              )
            else
              ...controller.listProgres.asMap().entries.map((entry) {
                int index = entry.key;
                var progres = entry.value;
                bool isLast = index == controller.listProgres.length - 1;
                String tglStr = "${progres.tanggal.day.toString().padLeft(2, '0')} ${_getMonth(progres.tanggal.month)} ${progres.tanggal.year}";

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(color: index == 0 ? const Color(0xFF1E2452) : const Color(0xFFCBD5E1), shape: BoxShape.circle)),
                          if (!isLast) Expanded(child: Container(width: 2, color: const Color(0xFFE2E8F0))),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tglStr, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
                                const SizedBox(height: 8),
                                Text(progres.deskripsi, style: TextStyle(color: textSecondary, height: 1.5)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildButtonAction({required String text, required VoidCallback onPressed, required Color color, bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}