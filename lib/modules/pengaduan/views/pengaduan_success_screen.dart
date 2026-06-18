import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/routes/app_routes.dart';
import '../../warga_dashboard/controllers/warga_dashboard_controller.dart';

class PengaduanSuccessScreen extends StatelessWidget {
  final String pengaduanId;
  final String uuidDb; // 🚀 BUG FIX: Tambahan variabel untuk menyimpan UUID asli

  const PengaduanSuccessScreen({
    super.key,
    required this.pengaduanId,
    required this.uuidDb, // 🚀 Wajib diisi dari Controller
  });

  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -size.height * 0.1, right: -size.width * 0.2,
            child: Opacity(opacity: 0.3, child: SvgPicture.asset('assets/images/backgrounds/bokeh_overlay.svg', width: size.width * 0.8 > 400 ? 400 : size.width * 0.8, fit: BoxFit.contain)),
          ),
          Positioned(
            bottom: -size.height * 0.1, left: -size.width * 0.2,
            child: Opacity(opacity: 0.3, child: SvgPicture.asset('assets/images/backgrounds/bokeh_overlay.svg', width: size.width * 0.8 > 400 ? 400 : size.width * 0.8, fit: BoxFit.contain)),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Image.asset(
                          'assets/images/icons/success_icon_check.png',
                          width: 140, fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(color: darkBlueColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: darkBlueColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)]),
                              child: const Icon(Icons.check, size: 50, color: Colors.white),
                            );
                          }
                      ),
                      const SizedBox(height: 32),
                      const Text('Pengaduan Berhasil Dikirim', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary, height: 1.2)),
                      const SizedBox(height: 16),
                      const Text('Pengaduan Anda telah berhasil\ndikirim dan akan segera ditinjau oleh\ntim paralegal kami', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: textSecondary, height: 1.6)),
                      const SizedBox(height: 32),

                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: pengaduanId));
                          Get.snackbar('Berhasil', 'ID Pengaduan disalin', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
                        },
                        child: Container(
                          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)),
                          child: Column(
                            children: [
                              const Text('ID Pengaduan', style: TextStyle(fontSize: 12, color: textSecondary)),
                              const SizedBox(height: 8),
                              Text(pengaduanId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Get.offAllNamed(AppRoutes.WARGA_DASHBOARD);
            Future.delayed(const Duration(milliseconds: 100), () {
              if (Get.isRegistered<WargaDashboardController>()) {
                Get.find<WargaDashboardController>().changeTab(2);
              }
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: darkBlueColor, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            Get.offAllNamed(AppRoutes.WARGA_DASHBOARD);
            Future.delayed(const Duration(milliseconds: 100), () {
              // 🚀 BUG FIX: Gunakan variabel uuidDb untuk masuk ke Detail Kasus, bukan PGN-xxx
              Get.toNamed(AppRoutes.DETAIL_KASUS, arguments: uuidDb);
            });
          },
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Lihat Detail Pengaduan', style: TextStyle(color: darkBlueColor, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}