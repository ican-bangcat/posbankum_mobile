import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/detail_kasus_paralegal_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../models/detail_kasus_paralegal_model.dart';

class DetailKasusParalegalView extends GetView<DetailKasusParalegalController> {
  const DetailKasusParalegalView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);
  final Color textPrimary = const Color(0xFF0F172A);
  final Color textSecondary = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    Get.put(DetailKasusParalegalController());
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

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

                if (kasus.status == 'menunggu') {
                  statusText = 'BELUM DIPROSES';
                  statusColor = const Color(0xFFF59E0B);
                  statusBg = const Color(0xFFFEF3C7);
                } else if (kasus.status == 'diproses') {
                  statusText = 'SEDANG DIPROSES';
                  statusColor = const Color(0xFF3B82F6);
                  statusBg = const Color(0xFFEFF6FF);
                } else if (kasus.status == 'selesai') {
                  statusText = 'KASUS SELESAI';
                  statusColor = const Color(0xFF10B981);
                  statusBg = const Color(0xFFECFDF5);
                } else if (kasus.status == 'dibatalkan') {
                  statusText = 'KASUS DITOLAK';
                  statusColor = const Color(0xFFEF4444);
                  statusBg = const Color(0xFFFEE2E2);
                }

                return Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 100 + bottomPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           _buildTitleCard(kasus, statusText, statusColor, statusBg),
                           const SizedBox(height: 16),
 
                           if ((kasus.status == 'dibatalkan' || kasus.status == 'selesai') && kasus.catatanAdmin != null) ...[
                             _buildCatatanInternalAlert(kasus.status, kasus.catatanAdmin!),
                             const SizedBox(height: 16),
                           ],
 
                           _buildDataPelaporCard(kasus),
                           const SizedBox(height: 16),
                           _buildDetailKejadianCard(kasus, tglKejadian),
                           const SizedBox(height: 16),
                           _buildKronologiCard(kasus),
                           const SizedBox(height: 16),
                           _buildLampiranSection(kasus), // ✅ UI Lampiran
                           const SizedBox(height: 16),
                           _buildRiwayatUpdateCard(),
                         ],
                       ),
                     ),
 
                     // BUTTONS DI BAGIAN BAWAH
                     if (kasus.status == 'menunggu')
                       Positioned(
                         bottom: 20 + bottomPadding, left: 20, right: 20,
                         child: Row(
                           children: [
                             Expanded(
                               flex: 1,
                               child: _buildButtonAction(
                                 text: 'Tolak',
                                 icon: Icons.cancel_outlined,
                                 onPressed: () => _showTolakDialog(context, kasus.id),
                                 color: Colors.white,
                                 textColor: const Color(0xFFEF4444),
                                 isOutline: true,
                               ),
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                               flex: 2,
                               child: _buildButtonAction(
                                 text: 'Ambil Kasus',
                                 icon: Icons.assignment_turned_in,
                                 onPressed: () => controller.ambilKasus(kasus.id),
                                 color: const Color(0xFF3B4A8D),
                                 isLoading: controller.isUpdating.value,
                               ),
                             ),
                           ],
                         ),
                       ),
 
                     if (kasus.status == 'diproses')
                       Positioned(
                         bottom: 20 + bottomPadding, left: 20, right: 20,
                         child: Row(
                           children: [
                             Expanded(
                               flex: 1,
                               child: _buildButtonAction(
                                 text: 'Tutup Kasus',
                                 icon: Icons.lock_outline,
                                 onPressed: () => _showTutupKasusDialog(context, kasus.id),
                                 color: Colors.white,
                                 textColor: const Color(0xFFEF4444),
                                 isOutline: true,
                               ),
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                               flex: 2,
                               child: _buildButtonAction(
                                 text: 'Update Progres',
                                 icon: Icons.assignment_outlined,
                                 onPressed: () => Get.toNamed(AppRoutes.UPDATE_PROGRES, arguments: {'id': kasus.id, 'judul': kasus.judul}),
                                 color: const Color(0xFF3B4A8D),
                               ),
                             ),
                           ],
                         ),
                       ),

                    if (kasus.status == 'selesai' || kasus.status == 'dibatalkan')
                      Positioned(
                        bottom: 20 + bottomPadding, left: 20, right: 20,
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

  void _showTolakDialog(BuildContext context, String idPengaduan) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_rounded, color: Color(0xFFEF4444)),
                  SizedBox(width: 8),
                  Text('Tolak Kasus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2452))),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                  'Berikan alasan mengapa kasus ini ditolak. Alasan ini akan dapat dilihat oleh pelapor.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5)
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.alasanTolakC,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Contoh: Kasus ini berada di luar wilayah yurisdiksi kami...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isUpdating.value ? null : () => controller.tolakKasus(idPengaduan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: controller.isUpdating.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Tolak Kasus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildCatatanInternalAlert(String status, String catatan) {
    if (catatan.trim().isEmpty) return const SizedBox.shrink();
    
    final bool isDibatalkan = status == 'dibatalkan';
    final Color bgColor = isDibatalkan ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
    final Color borderColor = isDibatalkan ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0);
    final Color titleColor = isDibatalkan ? const Color(0xFF991B1B) : const Color(0xFF065F46);
    final Color textColor = isDibatalkan ? const Color(0xFFB91C1C) : const Color(0xFF047857);
    final IconData icon = isDibatalkan ? Icons.info_outline : Icons.check_circle_outline;
    final String titleStr = isDibatalkan ? 'Alasan Penolakan/Pembatalan:' : 'Catatan Akhir Penyelesaian:';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleStr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: titleColor)),
                const SizedBox(height: 4),
                Text(catatan, style: TextStyle(fontSize: 13, color: textColor, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showTutupKasusDialog(BuildContext context, String idPengaduan) {
    final RxString selectedStatus = 'selesai'.obs;
    final textController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock_clock_outlined, color: Color(0xFF3B4A8D)),
                  SizedBox(width: 8),
                  Text('Tutup Kasus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2452))),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                  'Pilih status akhir penutupan kasus ini dan berikan catatan atau alasan penutupan.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5)
              ),
              const SizedBox(height: 16),
              
              // Opsi Status: Selesai atau Batalkan
              Obx(() => Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Text(
                          'Selesaikan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      selected: selectedStatus.value == 'selesai',
                      selectedColor: const Color(0xFFD1FAE5),
                      disabledColor: Colors.grey.shade100,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: selectedStatus.value == 'selesai' ? const Color(0xFF047857) : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (selected) {
                        if (selected) selectedStatus.value = 'selesai';
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Text(
                          'Batalkan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      selected: selectedStatus.value == 'dibatalkan',
                      selectedColor: const Color(0xFFFEE2E2),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: selectedStatus.value == 'dibatalkan' ? const Color(0xFFB91C1C) : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (selected) {
                        if (selected) selectedStatus.value = 'dibatalkan';
                      },
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 16),
              
              // Input Catatan
              Obx(() => TextField(
                controller: textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: selectedStatus.value == 'selesai'
                      ? 'Tuliskan catatan penyelesaian akhir kasus ini...'
                      : 'Tuliskan alasan lengkap mengapa kasus dibatalkan...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isUpdating.value ? null : () {
                        controller.tutupKasus(
                          id: idPengaduan,
                          status: selectedStatus.value,
                          catatan: textController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedStatus.value == 'selesai' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: controller.isUpdating.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Tutup Kasus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildPriorityBadge(String prioritas) {
    Color color = Colors.grey;
    Color bg = Colors.grey.shade100;
    
    switch (prioritas) {
      case 'Sangat Tinggi':
        color = const Color(0xFFEF4444);
        bg = const Color(0xFFFEE2E2);
        break;
      case 'Tinggi':
        color = const Color(0xFFF97316);
        bg = const Color(0xFFFFEDD5);
        break;
      case 'Menengah':
        color = const Color(0xFF3B82F6);
        bg = const Color(0xFFEFF6FF);
        break;
      case 'Normal':
        color = const Color(0xFF10B981);
        bg = const Color(0xFFECFDF5);
        break;
      case 'Rendah':
        color = const Color(0xFF64748B);
        bg = const Color(0xFFF1F5F9);
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        'PRIORITAS: ${prioritas.toUpperCase()}',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }

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
    String idStr = kasus.id.toString();
    String displayId = idStr.length >= 8 ? idStr.substring(0, 8).toUpperCase() : idStr.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
            child: Text(
              'ID KASUS: #$displayId',
              style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'Monospace'),
            ),
          ),
          const SizedBox(height: 12),
          Text(kasus.judul, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
          const SizedBox(height: 4),
          Text(kasus.namaKlien ?? '-', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
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
              _buildPriorityBadge(kasus.prioritas),
            ],
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
          _buildInfoBoxItem(icon: Icons.assignment_outlined, label: 'JENIS MASALAH', value: kasus.kategori),
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
                Text('Riwayat Penanganan Kasus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
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
                      const Text('Belum ada riwayat penanganan\nuntuk kasus ini.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94A3B8))),
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
                        if (!isLast) Container(width: 2, height: 80, color: const Color(0xFFE2E8F0)),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(progres.title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E2452), fontSize: 14))),
                                  Text(tglStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                                ],
                              ),
                              if (progres.deskripsi.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(progres.deskripsi, style: TextStyle(color: textSecondary, height: 1.5, fontSize: 13)),
                              ]
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

  // ✅ UI LIST LAMPIRAN
  Widget _buildLampiranSection(dynamic kasus) {
    List<LampiranItem> lampiranList = kasus.lampiranList;
    if (lampiranList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_file, color: Color(0xFF1E2452), size: 20),
            const SizedBox(width: 8),
            const Expanded(child: Text('Lampiran Dikirim', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E2452)))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
              child: Text('${lampiranList.length} File', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...lampiranList.map((file) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLampiranCard(file),
          );
        }).toList(),
      ],
    );
  }

  // ✅ KARTU LAMPIRAN & FUNGSI KLIK
  Widget _buildLampiranCard(LampiranItem file) {
    bool isImage = file.mimeType?.toLowerCase().contains('image') ?? false;
    final token = GetStorage().read('token');
    final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

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
                child: Row(
                  children: [
                    Icon(isImage ? Icons.image : Icons.description, color: Colors.white, size: 10),
                    const SizedBox(width: 4),
                    Text(isImage ? 'GAMBAR' : 'DOKUMEN', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
              child: isImage
                  ? Image.network(
                      file.pathFile,
                      headers: headers, // 👈 Kirim token auth
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 32),
                      ),
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 32),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(file.namaFile, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E2452)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),

          // ✅ TOMBOL KLIK BUKA LAMPIRAN
          InkWell(
            onTap: () => controller.bukaLampiran(file.pathFile, file.mimeType, namaFile: file.namaFile),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined, color: Color(0xFF3B82F6), size: 16),
                  SizedBox(width: 6),
                  Text('Lihat Lampiran', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonAction({required String text, required VoidCallback onPressed, required Color color, Color? textColor, IconData? icon, bool isLoading = false, bool isOutline = false}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        boxShadow: isOutline ? null : [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutline ? BorderSide(color: textColor ?? Colors.red.shade400, width: 1.5) : BorderSide.none,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8), // Memberi sedikit padding agar tulisan tidak nempel ke pinggir
        ),
        child: isLoading
            ? CircularProgressIndicator(color: textColor ?? Colors.white, strokeWidth: 2)
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor ?? Colors.white, size: 16),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor ?? Colors.white,
                      ),
                    ),
                  ],
                ),
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