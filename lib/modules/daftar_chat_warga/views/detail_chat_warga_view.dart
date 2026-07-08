import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../controllers/detail_chat_warga_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../widgets/pdf_viewer_screen.dart';
import '../../../app/data/services/api_service.dart';

class DetailChatWargaView extends GetView<DetailChatWargaController> {
  const DetailChatWargaView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);

  @override
  Widget build(BuildContext context) {
    Get.put(DetailChatWargaController());
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          // HEADER
          Stack(
            children: [
              Positioned(
                bottom: 0, left: 0,
                child: Container(width: 50, height: 50, color: const Color(0xFFF4F6F9)),
              ),
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, left: 20, right: 20),
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.INFO_CHAT_POSBANKUM, arguments: controller.idPengaduan),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Obx(() {
                              final String rawUrl = controller.fotoLawanBicara.value;
                              final String cleanUrl = _resolveFileUrl(rawUrl);
                              final token = GetStorage().read('token');
                              final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

                              return CircleAvatar(
                                backgroundColor: Colors.white24,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: cleanUrl.isNotEmpty
                                      ? Image.network(
                                          cleanUrl,
                                          headers: headers,
                                          fit: BoxFit.cover,
                                          width: 40,
                                          height: 40,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 20),
                                        )
                                      : const Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                              );
                            }),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                    controller.namaLawanBicaraHeader.value,
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  const Text('Online', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
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

          // CHAT AREA & INPUT AREA (Body)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6F9),
                borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.messages.isEmpty) {
                        return Center(
                          child: Text(
                            "Belum ada obrolan. Mulai kirim pesan hukum Anda.",
                            style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final msg = controller.messages[index];
                          final maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: msg.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Avatar Paralegal (Muncul kalau pesannya dari Paralegal/Kiri)
                                if (!msg.isSender) ...[
                                  Obx(() {
                                    final String rawUrl = controller.fotoLawanBicara.value;
                                    final String cleanUrl = _resolveFileUrl(rawUrl);
                                    final token = GetStorage().read('token');
                                    final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

                                    return Container(
                                      width: 32, height: 32,
                                      decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: cleanUrl.isNotEmpty
                                            ? Image.network(
                                                cleanUrl,
                                                headers: headers,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 18),
                                              )
                                            : const Icon(Icons.person, color: Colors.white, size: 18),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                ],

                                // Bubble Pesan
                                Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: msg.isSender ? const Color(0xFF0F172A) : Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(msg.isSender ? 16 : 4),
                                        bottomRight: Radius.circular(msg.isSender ? 4 : 16),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Teks atau Media Chat
                                        _buildMessageContent(context, msg.text, msg.isSender),
                                        const SizedBox(height: 4),
                                        // Jam & Status Centang di dalam bubble
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              msg.time,
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: msg.isSender ? Colors.white60 : Colors.black45,
                                              ),
                                            ),
                                            if (msg.isSender) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                msg.isRead ? Icons.done_all : Icons.check,
                                                size: 12,
                                                color: msg.isRead ? const Color(0xFF3B82F6) : Colors.white60,
                                              ),
                                            ]
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),

                  // INPUT AREA
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showAttachmentOptions(context),
                          child: const CircleAvatar(
                            backgroundColor: Color(0xFFF1F5F9),
                            child: Icon(Icons.add, color: Color(0xFF64748B), size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller.chatInputC,
                            maxLines: 5,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: 'Ketik pesan...',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => controller.kirimPesan(),
                          child: const CircleAvatar(backgroundColor: Color(0xFF2563EB), child: Icon(Icons.send_rounded, color: Colors.white, size: 20)),
                        )
                      ],
                    ),
                  )
                ],
              ),
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
        color: isSender ? Colors.white : Colors.black,
        fontSize: 14,
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
