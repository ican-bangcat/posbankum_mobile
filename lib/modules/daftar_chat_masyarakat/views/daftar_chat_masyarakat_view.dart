import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/daftar_chat_masyarakat_controller.dart';
import '../../../app/routes/app_routes.dart';

class DaftarChatMasyarakatView extends GetView<DaftarChatMasyarakatController> {
  const DaftarChatMasyarakatView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    Get.put(DaftarChatMasyarakatController());

    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          // HEADER (Sama seperti Admin)
          Stack(
            children: [
              Positioned(bottom: 0, left: 0, child: Container(width: 50, height: 50, color: bgColor)),
              Container(
                width: double.infinity, clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(color: darkBlue, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28))),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                        const SizedBox(width: 16),
                        const Text('Pesan Saya', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // BODY LIST CHAT
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topRight: Radius.circular(28))),
              child: Obx(() {
                final chats = controller.filteredChat;
                if (chats.isEmpty) return const Center(child: Text("Belum ada pesan", style: TextStyle(color: Colors.grey)));

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    bool hasUnread = chat.unreadCount > 0;

                    return GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.DETAIL_CHAT_MASYARAKAT), // Arahkan ke Detail Chat Masyarakat
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                          border: Border(left: BorderSide(color: hasUnread ? const Color(0xFF2563EB) : Colors.transparent, width: 4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                              child: const Icon(Icons.account_balance_rounded, color: Color(0xFF94A3B8), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(chat.judulKasus, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      Text(chat.waktu, style: TextStyle(fontSize: 11, color: hasUnread ? const Color(0xFF2563EB) : Colors.grey, fontWeight: hasUnread ? FontWeight.w700 : FontWeight.normal)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(chat.namaPosbankum, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(height: 8),
                                  Text(chat.pesanTerakhir, style: TextStyle(fontSize: 13, color: hasUnread ? Colors.black : Colors.grey, fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
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
}