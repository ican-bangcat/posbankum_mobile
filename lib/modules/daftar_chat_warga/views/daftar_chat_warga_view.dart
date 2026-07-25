import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/daftar_chat_warga_controller.dart';
import '../models/chat_room_warga_model.dart';
import '../../../core/constants/image_constants.dart';

class DaftarChatWargaView extends GetView<DaftarChatWargaController> {
  const DaftarChatWargaView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    Get.put(DaftarChatWargaController());

    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          // HEADER SCREEN
          _buildHeader(),

          // BODY AREA
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

                if (controller.acceptedComplaints.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  itemCount: controller.acceptedComplaints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final kasus = controller.acceptedComplaints[index];

                    final idPengaduan = kasus.id;
                    final judulLaporan = kasus.judulLaporan;
                    final namaParalegal = kasus.namaParalegalDitugaskan;
                    final lastMessage = kasus.lastMessage;
                    final lastTime = kasus.lastTime;
                    final int unreadCount = kasus.unreadCount;
                    final bool hasUnread = unreadCount > 0;
                    final String fotoLawanBicara = kasus.fotoLawanBicara;

                    return GestureDetector(
                      onTap: () => controller.pindahKeDetailChat(idPengaduan, judulLaporan, namaParalegal),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: hasUnread ? const Color(0xFF2563EB) : Colors.transparent,
                                  width: 4,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon Avatar Room
                                Container(
                                  width: 48, height: 48,
                                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: fotoLawanBicara.isNotEmpty
                                        ? Image.network(
                                            _resolveFileUrl(fotoLawanBicara),
                                            headers: {
                                              'Authorization': 'Bearer ${GetStorage().read('token')}',
                                            },
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_rounded, color: Color(0xFF94A3B8), size: 22),
                                          )
                                        : const Icon(Icons.account_balance_rounded, color: Color(0xFF94A3B8), size: 22),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Konten Informasi Ruang Chat
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              judulLaporan,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (lastTime.isNotEmpty)
                                            Text(
                                              lastTime,
                                              style: TextStyle(
                                                fontSize: 11, 
                                                color: hasUnread ? const Color(0xFF2563EB) : const Color(0xFF94A3B8), 
                                                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Paralegal: $namaParalegal",
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lastMessage,
                                              style: TextStyle(
                                                fontSize: 12, 
                                                color: hasUnread ? const Color(0xFF0F172A) : Colors.grey, 
                                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                                fontStyle: hasUnread ? FontStyle.normal : FontStyle.italic
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (hasUnread)
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                                              child: Text(
                                                '$unreadCount',
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                                              child: const Text('Aktif', style: TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                                            )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(width: 50, height: 50, color: bgColor),
        ),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.zero,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -5,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    ImageConstants.headerBgWarga,
                    width: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.location_city,
                            size: 200, color: Colors.white10),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Row(
                    children: [
                      const Text(
                        'Chat Paralegal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Fitur Chat Belum Terbuka',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ruang obrolan otomatis aktif setelah laporan pengaduan Anda divalidasi dan "Diterima" oleh Paralegal Posbankum.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveFileUrl(String url) {
    if (url.isEmpty) return '';

    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      url = url
          .replaceAll('http://localhost', 'https://sibapak.pocari.id')
          .replaceAll('https://localhost', 'https://sibapak.pocari.id')
          .replaceAll('http://127.0.0.1:8000', 'https://sibapak.pocari.id')
          .replaceAll('http://127.0.0.1', 'https://sibapak.pocari.id')
          .replaceAll('https://127.0.0.1', 'https://sibapak.pocari.id');
    }

    if (url.startsWith('http://sibapak.pocari.id')) {
      url = url.replaceFirst('http://sibapak.pocari.id', 'https://sibapak.pocari.id');
    }

    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    const serverBase = 'https://sibapak.pocari.id';
    return '$serverBase${url.startsWith('/') ? '' : '/'}$url';
  }
}
