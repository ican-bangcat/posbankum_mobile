import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/daftar_chat_paralegal_controller.dart';

class DaftarChatParalegalView extends GetView<DaftarChatParalegalController> {
  const DaftarChatParalegalView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    Get.put(DaftarChatParalegalController());

    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          // ─── 1. HEADER ───
          Stack(
            children: [
              Positioned(bottom: 0, left: 0, child: Container(width: 50, height: 50, color: bgColor)),
              Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(color: darkBlue, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28))),
                child: Stack(
                  children: [
                    Positioned(
                      top: -10, right: -5,
                      child: Opacity(
                        opacity: 0.8,
                        child: Image.asset('assets/images/icons/building_illustration3.png', width: 300, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.account_balance, size: 150, color: Colors.white10)),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                        child: Row(
                          children: [
                            // Tombol Back (Opsional, karena ini tab navbar bisa dihilangkan kalau mau)
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 16),
                            const Text('Daftar Chat Kasus', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── 2. BODY ───
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topRight: Radius.circular(28))),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        decoration: const InputDecoration(
                          hintText: 'Cari kasus atau klien...', hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                          border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // List Chat
                  Expanded(
                    child: Obx(() {
                      final chats = controller.filteredChat;
                      if (chats.isEmpty) return const Center(child: Text("Tidak ada chat ditemukan", style: TextStyle(color: Colors.grey)));

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        itemCount: chats.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildChatCard(chats[index]);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── KOMPONEN KARTU CHAT ───
  Widget _buildChatCard(ChatRoomItem chat) {
    bool hasUnread = chat.unreadCount > 0;

    // ✅ BUNGKUS DENGAN GESTURE DETECTOR DI SINI
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail chat
        Get.toNamed('/detail-chat-paralegal'); // Pastikan route ini sesuai sama yang di app_routes.dart kamu
      },
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
            // Garis biru di kiri kalau ada pesan yang belum dibaca
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
                // Icon Bulat Kiri
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: Color(0xFF94A3B8), size: 24),
                ),
                const SizedBox(width: 14),

                // Bagian Tengah (Teks)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              chat.judulKasus,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            chat.waktuwaktu,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                              color: hasUnread ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              chat.namaLawanBicara,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.pesanTerakhir,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                color: hasUnread ? const Color(0xFF0F172A) : const Color(0xFF64748B),
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
                                '${chat.unreadCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            _buildStatusBadge(chat.status),
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
  }

  Widget _buildStatusBadge(String status) {
    Color bg; Color text; IconData? icon;

    if (status.toLowerCase() == 'aktif') {
      bg = const Color(0xFFEFF6FF); text = const Color(0xFF2563EB); icon = Icons.chat_bubble_outline;
    } else if (status.toLowerCase() == 'selesai') {
      bg = const Color(0xFFF1F5F9); text = const Color(0xFF64748B); icon = Icons.check_circle_outline;
    } else {
      bg = const Color(0xFFFFF7ED); text = const Color(0xFFEA580C); icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 10, color: text), const SizedBox(width: 4)],
          Text(status, style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}