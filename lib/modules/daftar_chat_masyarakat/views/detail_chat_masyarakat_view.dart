import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_chat_masyarakat_controller.dart';
import '../../../app/routes/app_routes.dart';

class DetailChatMasyarakatView extends GetView<DetailChatMasyarakatController> {
  const DetailChatMasyarakatView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);

  @override
  Widget build(BuildContext context) {
    Get.put(DetailChatMasyarakatController());
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(color: darkBlue, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28))),
            child: Row(
              children: [
                GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    // ✅ ARAHKAN KE INFO CHAT POSBANKUM YANG UDAH DIBUAT SEBELUMNYA
                    onTap: () => Get.toNamed(AppRoutes.INFO_CHAT_POSBANKUM),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.account_balance, color: Colors.white, size: 20)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.namaPosbankum, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const Text('Online', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CHAT AREA
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: msg.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: msg.isSender ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(msg.text, style: TextStyle(color: msg.isSender ? Colors.white : Colors.black, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )),
          ),

          // INPUT AREA
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.chatInputC,
                    decoration: InputDecoration(hintText: 'Ketik pesan...', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => controller.kirimPesan(),
                  child: const CircleAvatar(backgroundColor: Color(0xFF2563EB), child: Icon(Icons.send, color: Colors.white, size: 20)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}