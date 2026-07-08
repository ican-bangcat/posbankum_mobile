import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../controllers/detail_chat_paralegal_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../widgets/pdf_viewer_screen.dart';
import '../../../app/data/services/api_service.dart';

class DetailChatParalegalView extends GetView<DetailChatParalegalController> {
  const DetailChatParalegalView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    Get.put(DetailChatParalegalController());
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildChatArea()),
          _buildBottomInput(context, bottomPadding),
        ],
      ),
    );
  }

  // ─── 1. HEADER ───
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: -20, right: -10,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/icons/building_illustration3.png',
                width: 250, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, size: 120, color: Colors.white10),
              ),
            ),
          ),
          // Konten Header
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24, left: 20, right: 20,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
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

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.INFO_CHAT_POSBANKUM, arguments: controller.idPengaduan);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        // Avatar Klien
                        Obx(() {
                          final String rawUrl = controller.fotoLawanBicara.value;
                          final String cleanUrl = _resolveFileUrl(rawUrl);
                          final token = GetStorage().read('token');
                          final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

                          return Stack(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: cleanUrl.isNotEmpty
                                      ? Image.network(
                                          cleanUrl,
                                          headers: headers,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 24),
                                        )
                                      : const Icon(Icons.person, color: Colors.white, size: 24),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 12, height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: darkBlue, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(width: 12),
                        // Nama & Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.namaKlien,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                controller.statusKlien,
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. AREA CHAT ───
  Widget _buildChatArea() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.messages.isEmpty) {
              return Center(
                child: Text(
                  "Belum ada obrolan. Kirim pesan untuk menyapa klien.",
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              );
            }

            return ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                return _buildMessageBubble(context, msg);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: msg.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar Klien (Muncul kalau pesannya dari Klien/Kiri)
          if (!msg.isSender) ...[
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble Pesan
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: msg.isSender ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isSender ? 16 : 4),
                      bottomRight: Radius.circular(msg.isSender ? 4 : 16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
                  ),
                  child: _buildMessageContent(context, msg.text, msg.isSender),
                ),
                const SizedBox(height: 4),
                // Waktu & Read Receipt
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(msg.time, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    if (msg.isSender) ...[
                      const SizedBox(width: 4),
                      Icon(
                        msg.isRead ? Icons.done_all : Icons.check,
                        size: 14,
                        color: msg.isRead ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _resolveFileUrl(String url) {
    if (url.isEmpty) return '';

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

  Widget _buildMessageContent(BuildContext context, String text, bool isSender) {
    if (text.startsWith('[FILE]')) {
      try {
        final clean = text.substring(6);
        final parts = clean.split('|');
        if (parts.length >= 2) {
          final fileName = parts[0];
          final fileUrl = _resolveFileUrl(parts[1]);

          final lowerName = fileName.toLowerCase();
          final isImage = lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg') || lowerName.endsWith('.png');

          if (isImage) {
            return GestureDetector(
              onTap: () => _showImagePreview(context, fileUrl),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fileUrl,
                    headers: {
                      'Authorization': 'Bearer ${GetStorage().read('token')}',
                    },
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.all(12),
                      child: const Row(
                        children: [
                          Icon(Icons.broken_image, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(child: Text('Gagal memuat gambar', style: TextStyle(fontSize: 12))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return InkWell(
              onTap: () => _openPdfFile(fileName, fileUrl),
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSender ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSender ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Klik untuk membuka',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSender ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      } catch (_) {}
    }
    return Text(
      text,
      style: TextStyle(
        color: isSender ? Colors.white : const Color(0xFF0F172A),
        fontSize: 14, height: 1.4,
      ),
    );
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

      Get.back(); // Tutup loading

      Get.to(() => PdfViewerScreen(
        pdfPath: savePath,
        title: fileName,
      ));
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Gagal mengunduh berkas: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ─── 3. BOTTOM INPUT ───
  Widget _buildBottomInput(BuildContext context, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // Tombol Plus (+)
          GestureDetector(
            onTap: () => _showAttachmentOptions(context),
            child: const Icon(Icons.add, color: Color(0xFF64748B), size: 28),
          ),
          const SizedBox(width: 12),

          // Field Ketik Pesan
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.chatInputC,
                      maxLines: 5,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF94A3B8), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tombol Kirim
          GestureDetector(
            onTap: () => controller.kirimPesan(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Ambil Foto Kamera'),
                onTap: () {
                  Get.back();
                  controller.pilihDanKirimMedia(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Galeri Gambar'),
                onTap: () {
                  Get.back();
                  controller.pilihDanKirimMedia(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.document_scanner, color: Colors.red),
                title: const Text('Pilih Dokumen (PDF)'),
                onTap: () {
                  Get.back();
                  controller.pilihDanKirimMedia(false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}