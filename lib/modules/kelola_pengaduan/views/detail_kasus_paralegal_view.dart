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

                String tglKejadian = _formatDate(kasus.tanggalKejadian);

                String statusText = '';
                Color statusColor = Colors.grey;
                Color statusBg = Colors.grey.shade100;

                if (kasus.status == 'pending') {
                  statusText = 'BELUM DIPROSES';
                  statusColor = const Color(0xFFF59E0B);
                  statusBg = const Color(0xFFFEF3C7);
                } else if (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses') {
                  statusText = 'SEDANG DIPROSES';
                  statusColor = const Color(0xFF3B82F6);
                  statusBg = const Color(0xFFEFF6FF);
                } else if (kasus.status == 'selesai') {
                  statusText = 'KASUS SELESAI';
                  statusColor = const Color(0xFF10B981);
                  statusBg = const Color(0xFFECFDF5);
                }

                return Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleCard(kasus, statusText, statusColor, statusBg),
                          const SizedBox(height: 16),
                          _buildDataPelaporCard(kasus),
                          const SizedBox(height: 16),
                          _buildDetailKejadianCard(kasus, tglKejadian),
                          const SizedBox(height: 16),
                          _buildKronologiCard(kasus),
                          const SizedBox(height: 16),
                          _buildLampiranSection(kasus),
                          const SizedBox(height: 16),
                          _buildRiwayatUpdateCard(),
                        ],
                      ),
                    ),

                    // BUTTONS
                    if (kasus.status == 'pending')
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: _buildButtonAction(
                          text: 'Ambil Kasus',
                          icon: Icons.assignment_turned_in,
                          onPressed: () => controller.ambilKasus(kasus.id),
                          color: const Color(0xFF3B4A8D),
                          isLoading: controller.isUpdating.value,
                        ),
                      ),

                    if (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses')
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: _buildButtonAction(
                          text: 'Update Kasus',
                          icon: Icons.assignment_outlined,
                          onPressed: () => Get.toNamed(AppRoutes.UPDATE_PROGRES, arguments: {'id': kasus.id, 'judul': kasus.judul}),
                          color: const Color(0xFF3B4A8D),
                        ),
                      ),

                    if (kasus.status == 'selesai')
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: _buildButtonAction(
                          text: 'Kembali ke Beranda',
                          icon: Icons.home_outlined,
                          onPressed: () => Get.back(),
                          color: const Color(0xFF3B4A8D),
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

  // ─── KOMPONEN UI ───

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

  Widget _buildTitleCard(dynamic kasus, String statusText, Color statusColor, Color statusBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
            child: Text(
              'ID KASUS: #${kasus.id.toString().toUpperCase()}',
              style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'Monospace'),
            ),
          ),
          const SizedBox(height: 12),
          Text(kasus.judul, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
          const SizedBox(height: 4),
          Text(kasus.namaKlien ?? 'Bpk. Suryanto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPelaporCard(dynamic kasus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFF1E2452), size: 20),
              SizedBox(width: 8),
              Text('DATA PELAPOR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoBoxItem(icon: Icons.badge_outlined, label: 'NIK PELAPOR', value: kasus.nikPelapor ?? '-'),
          const SizedBox(height: 12),
          _buildInfoBoxItem(icon: Icons.person_outline, label: 'NAMA PELAPOR', value: kasus.namaKlien ?? '-'),
          const SizedBox(height: 12),
          _buildInfoBoxItem(icon: Icons.location_city_outlined, label: 'LURAH/KELURAHAN', value: kasus.namaLurah ?? '-'),
          const SizedBox(height: 12),
          _buildInfoBoxItem(icon: Icons.phone_outlined, label: 'NO. TELEPON', value: kasus.noHpKlien ?? '-'),
        ],
      ),
    );
  }

  Widget _buildDetailKejadianCard(dynamic kasus, String tglKejadian) {
    String tglLapor = _formatDate(kasus.tanggalPengajuan);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insert_drive_file_outlined, color: Color(0xFF1E2452), size: 20),
              SizedBox(width: 8),
              Text('DETAIL KEJADIAN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoBoxItem(icon: Icons.calendar_today, label: 'TANGGAL LAPOR', value: tglLapor),
          const SizedBox(height: 12),
          _buildInfoBoxItem(icon: Icons.calendar_today_outlined, label: 'TANGGAL KEJADIAN', value: tglKejadian, isHighlighted: true),
          const SizedBox(height: 12),
          _buildInfoBoxItem(icon: Icons.access_time, label: 'WAKTU KEJADIAN', value: kasus.waktuKejadian ?? '-'),
          const SizedBox(height: 12),
          _buildInfoBoxItem(icon: Icons.location_on_outlined, label: 'LOKASI KEJADIAN', value: kasus.lokasi),
        ],
      ),
    );
  }

  Widget _buildInfoBoxItem({required IconData icon, required String label, required String value, bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted ? const Border(left: BorderSide(color: Color(0xFF3B82F6), width: 4)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E2452))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKronologiCard(dynamic kasus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_outlined, color: Color(0xFF1E2452), size: 20),
              SizedBox(width: 8),
              Text('Kronologi Singkat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
            child: Text(
              kasus.deskripsi,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.6),
            ),
          ),
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

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 14, height: 14, 
                          decoration: BoxDecoration(color: index == 0 ? const Color(0xFF1E2452) : const Color(0xFFCBD5E1), shape: BoxShape.circle)
                        ),
                        if (!isLast) Container(width: 2, height: 60, color: const Color(0xFFE2E8F0)),
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
                );
              }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildLampiranSection(dynamic kasus) {
    List<String> lampiranUrls = kasus.lampiranUrls;
    if (lampiranUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF1E2452), size: 20),
            const SizedBox(width: 8),
            const Expanded(child: Text('Lampiran Dikirim Masyarakat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E2452)))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
              child: Text('${lampiranUrls.length} File', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...lampiranUrls.map((url) {
          String fileName = url.split('/').last;
          if (fileName.contains('?')) fileName = fileName.split('?').first;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLampiranCard(fileName, 'Dokumen Terlampir'),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLampiranCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF1E2452), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.description, color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Text('FILE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.description, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.remove_red_eye_outlined, color: Color(0xFF3B82F6), size: 14),
              SizedBox(width: 4),
              Text('Lihat', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonAction({required String text, required VoidCallback onPressed, required Color color, IconData? icon, bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
                  Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}