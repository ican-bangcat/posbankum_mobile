import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_chat_paralegal_controller.dart';

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
      // SafeArea top = false agar header bisa menabrak status bar
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildChatArea()),
          _buildBottomInput(bottomPadding),
        ],
      ),
    );
  }

  // ─── 1. HEADER ───
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

                // ✅ BUNGKUS AVATAR DAN NAMA DENGAN GESTURE DETECTOR
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigasi ke halaman Info Chat
                      Get.toNamed('/info-chat-posbankum'); // Sesuaikan dengan route-mu
                    },
                    behavior: HitTestBehavior.opaque, // Biar seluruh area bisa diklik, ga cuma teksnya
                    child: Row(
                      children: [
                        // Avatar Klien
                        Stack(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle),
                              child: const Icon(Icons.person, color: Colors.white, size: 24),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981), // Dot hijau online
                                  shape: BoxShape.circle,
                                  border: Border.all(color: darkBlue, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
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
        const SizedBox(height: 20),
        // Badge "Hari Ini"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(20)),
          child: const Text('Hari Ini', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 20),
        // Daftar Chat
        Expanded(
          child: Obx(() {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              reverse: false, // Ubah jadi true kalau mau data terbaru di bawah otomatis (butuh reverse list data juga)
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                return _buildMessageBubble(msg);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
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
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isSender ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 14, height: 1.4,
                    ),
                  ),
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

          // Jarak kanan kalau pesannya dari sender biar gak mepet layar (bisa ditambah avatar admin kalau mau)
          if (msg.isSender) const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ─── 3. BOTTOM INPUT ───
  Widget _buildBottomInput(double bottomPadding) {
    return Container(
      // ✅ PADDING BAWAH DIAMBIL DARI MEDIAQUERY + 12px BIAR GA KETUTUP GESTURE BAR
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // Tombol Plus (+)
          GestureDetector(
            onTap: () {}, // TODO: Fitur lampiran dokumen
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
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        border: InputBorder.none,
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
}