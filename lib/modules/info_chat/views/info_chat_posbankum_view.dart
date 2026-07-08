import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../controllers/info_chat_posbankum_controller.dart';
import '../../../widgets/pdf_viewer_screen.dart';
import '../../../app/data/services/api_service.dart';

class InfoChatPosbankumView extends GetView<InfoChatPosbankumController> {
  const InfoChatPosbankumView({super.key});

  final Color darkBlue = const Color(0xFF2B3163);
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color bgColor = const Color(0xFFF4F4F5);

  String _resolveFileUrl(String url) {
    if (url.isEmpty) return '';
    
    // Ganti localhost / 127.0.0.1 dengan domain server asli
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      url = url
          .replaceAll('http://localhost', 'http://sibapak.pocari.id')
          .replaceAll('https://localhost', 'http://sibapak.pocari.id')
          .replaceAll('http://127.0.0.1:8000', 'http://sibapak.pocari.id')
          .replaceAll('http://127.0.0.1', 'http://sibapak.pocari.id')
          .replaceAll('https://127.0.0.1', 'http://sibapak.pocari.id');
    }

    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    const serverBase = 'http://sibapak.pocari.id';
    return '$serverBase${url.startsWith('/') ? '' : '/'}$url';
  }

  @override
  Widget build(BuildContext context) {
    Get.put(InfoChatPosbankumController());
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: darkBlue,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        return Column(
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
                      _buildMainDataCard(),
                      _buildDetailKejadianCard(),
                      _buildKasusTerkait(),
                      _buildMediaSection(context),
                      _buildSettingsSection(),
                      _buildClearChat(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String displayName = controller.namaParalegal.value;
    final String displayRole = 'Paralegal Posbankum';
    
    // Foto profil url
    final String rawPhotoUrl = controller.fotoParalegal.value;
    final String photoUrl = _resolveFileUrl(rawPhotoUrl);

    final token = GetStorage().read('token');
    final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Info Chat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                        border: Border.all(color: Colors.orange.shade300, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: photoUrl.isNotEmpty
                            ? Image.network(
                                photoUrl,
                                headers: headers,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                              )
                            : _buildAvatarFallback(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle),
                      child: const Icon(
                        Icons.gavel_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
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
                      Text(
                        displayRole.toUpperCase(),
                        style: const TextStyle(color: Color(0xFFFDE047), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                    const Flexible(
                      child: Text(
                        'Pos Bantuan Hukum',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

  Widget _buildAvatarFallback() {
    return Container(
      color: const Color(0xFF1E3A8A),
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

  Widget _buildMainDataCard() {
    return _buildCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Detail Paralegal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Aktif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDataTile(Icons.person_outline, Colors.blue, 'Nama Paralegal', controller.namaParalegal.value),
        const SizedBox(height: 12),
        _buildDataTile(Icons.phone_outlined, Colors.green, 'No. Telepon', controller.noHpParalegal.value),
      ],
    );
  }

  Widget _buildDetailKejadianCard() {
    return _buildCard(
      children: [
        const Text('Detail Kejadian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 16),
        _buildDataTile(Icons.location_on_outlined, Colors.red, 'Lokasi Kejadian', controller.lokasiKejadian.value),
        const SizedBox(height: 12),
        _buildDataTile(Icons.calendar_month_outlined, Colors.orange, 'Tanggal Kejadian', controller.tanggalKejadian.value),
        const SizedBox(height: 12),
        _buildDataTile(Icons.access_time_rounded, Colors.teal, 'Waktu Kejadian', controller.waktuKejadian.value.isNotEmpty ? "${controller.waktuKejadian.value} WIB" : '-'),
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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kasus Terkait', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
                    child: Obx(() => Text(controller.statusKasus.value, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFD97706), letterSpacing: 0.5))),
                  ),
                  const SizedBox(height: 6),
                  Obx(() => Text(controller.judulKasus.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                  const SizedBox(height: 2),
                  Obx(() => Text('#${controller.nomorTiket.value}', style: const TextStyle(fontSize: 10, color: Colors.grey))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaSection(BuildContext context) {
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
              child: Obx(() => Text('${controller.listLampiran.length} File', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            double itemWidth = (constraints.maxWidth - 24) / 3;
            final files = controller.listLampiran;

            return Obx(() {
              if (files.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Belum ada berkas terunggah', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: files.map((file) {
                  final name = file['nama_file'] ?? 'File';
                  final path = file['path_file'] ?? '';
                  final mime = file['mime_type'] ?? '';
                  return _buildMediaItem(context, itemWidth, name, path, mime);
                }).toList(),
              );
            });
          }
        ),
      ],
    );
  }

  Widget _buildMediaItem(BuildContext context, double width, String filename, String fileUrl, String mimeType) {
    final cleanUrl = _resolveFileUrl(fileUrl);
    final lowerName = filename.toLowerCase();
    final isImage = lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg') || lowerName.endsWith('.png') || mimeType.contains('image');

    if (isImage) {
      return GestureDetector(
        onTap: () => _showImagePreview(context, cleanUrl),
        child: Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              cleanUrl,
              headers: {
                'Authorization': 'Bearer ${GetStorage().read('token')}',
              },
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _openPdfFile(filename, cleanUrl),
        child: Container(
          width: width,
          height: width,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
              const SizedBox(height: 8),
              Text(
                filename,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showImagePreview(BuildContext context, String fileUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(
                fileUrl,
                headers: {
                  'Authorization': 'Bearer ${GetStorage().read('token')}',
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Text('Gagal menampilkan berkas', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            Positioned(
              top: 0, right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPdfFile(String fileName, String fileUrl) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final directory = await getTemporaryDirectory();
      final savePath = "${directory.path}/$fileName";

      await ApiService().dio.download(
        fileUrl,
        savePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GetStorage().read('token')}',
          },
        ),
      );

      Get.back();

      Get.to(() => PdfViewerScreen(
        pdfPath: savePath,
        title: fileName,
      ));
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Gagal mengunduh berkas: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildSettingsSection() {
    return _buildCard(
      children: [
        const Text('Pengaturan Chat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Obx(() => _buildSettingTile(
          icon: Icons.notifications_off_outlined,
          iconColor: Colors.orange.shade700,
          iconBgColor: Colors.orange.shade50,
          title: 'Bisukan Notifikasi',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: controller.isMuted.value,
              onChanged: (v) => controller.toggleMute(v),
              activeColor: Colors.white,
              activeTrackColor: Colors.grey.shade300,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        )),
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
