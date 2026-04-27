import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../controllers/detail_kegiatan_controller.dart';
import '../../../app/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';

class DetailKegiatanView extends GetView<DetailKegiatanController> {
  DetailKegiatanView({super.key});

  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // ✅ Kunci ajaib untuk "memfoto" layar
  final GlobalKey _printKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = controller.kegiatanData;
                if (data.isEmpty) {
                  return const Center(child: Text("Data tidak ditemukan"));
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ═════════════════════════════════════════════════════════════════
                      // AREA YANG AKAN DI-SCREENSHOT (Dibungkus RepaintBoundary)
                      // ═════════════════════════════════════════════════════════════════
                      RepaintBoundary(
                        key: _printKey,
                        child: Container(
                          color: Colors.white, // Penting biar background PDF gak item
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. GAMBAR COVER
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  data['foto_url'] ?? '',
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 250,
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 2. Judul
                              Text(
                                data['judul'] ?? 'Tanpa Judul',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3),
                              ),
                              const SizedBox(height: 24),

                              // 3. Info Tanggal & Waktu
                              _buildInfoRow(
                                icon: Icons.calendar_today_outlined,
                                label: "TANGGAL & WAKTU",
                                value: controller.getFormattedDate(data['tanggal_mulai']),
                              ),
                              const SizedBox(height: 20),

                              // 4. Info Lokasi
                              _buildInfoRow(
                                icon: Icons.location_on_outlined,
                                label: "LOKASI KEGIATAN",
                                value: data['lokasi'] ?? '-',
                              ),
                              const SizedBox(height: 24),
                              const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                              const SizedBox(height: 24),

                              // 5. Deskripsi
                              const Text('Deskripsi Kegiatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary)),
                              const SizedBox(height: 12),
                              Text(
                                data['deskripsi'] ?? 'Tidak ada deskripsi untuk kegiatan ini.',
                                style: const TextStyle(fontSize: 14, color: textSecondary, height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ═════════════════════════════════════════════════════════════════
                      // AREA TOMBOL (Di luar Screenshot biar tombolnya gak ikut ke-PDF)
                      // ═════════════════════════════════════════════════════════════════
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                        child: _buildActionButtons(),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Get.toNamed(AppRoutes.EDIT_KEGIATAN, arguments: controller.kegiatanData['id']);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit_outlined, color: Colors.white, size: 20), SizedBox(width: 10), Text('Edit Kegiatan', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))]),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            _showShareBottomSheet(controller.kegiatanData);
          },
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.share_outlined, color: textPrimary, size: 20), SizedBox(width: 10), Text('Bagikan Detail', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700))]),
        ),
      ],
    );
  }

  void _showShareBottomSheet(Map data) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            const Text("Bagikan Kegiatan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const SizedBox(height: 24),

            // Opsi 1: Share Teks (Native)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.message_rounded, color: Color(0xFF10B981)),
              ),
              title: const Text("Bagikan Teks (WhatsApp dll)", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              subtitle: const Text("Kirim rangkuman singkat kegiatan", style: TextStyle(fontSize: 12, color: textSecondary)),
              onTap: () {
                Get.back();
                final textToShare = '*${data['judul']}*\n📍 ${data['lokasi']}\n🗓️ ${controller.getFormattedDate(data['tanggal_mulai'])}\n\n${data['deskripsi']}\n\n🔗 Link: https://posbankum.app/kegiatan/${data['id']}';
                Share.share(textToShare);
              },
            ),
            const Divider(height: 15, color: Color(0xFFF1F5F9)),

            // Opsi 2: Share PDF Gambar
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444)),
              ),
              title: const Text("Bagikan Gambar PDF", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              subtitle: const Text("Cetak tampilan detail ini jadi PDF", style: TextStyle(fontSize: 12, color: textSecondary)),
              onTap: () {
                Get.back();
                _generateAndSharePDF(data);
              },
            ),
            const Divider(height: 15, color: Color(0xFFF1F5F9)),

            // Opsi 3: Copy Link
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.link_rounded, color: Color(0xFF3B82F6)),
              ),
              title: const Text("Salin Tautan", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              subtitle: const Text("Salin link untuk dibuka di aplikasi", style: TextStyle(fontSize: 12, color: textSecondary)),
              onTap: () {
                Get.back();
                final dummyLink = "https://posbankum.app/kegiatan/${data['id']}";
                Clipboard.setData(ClipboardData(text: dummyLink));
                Get.snackbar("Berhasil", "Tautan disalin: $dummyLink", backgroundColor: const Color(0xFF10B981), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ✅ LOGIKA BARU: MEMFOTO LAYAR JADI PDF
  Future<void> _generateAndSharePDF(Map data) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      // 1. Ambil foto dari widget yang dibungkus RepaintBoundary
      RenderRepaintBoundary boundary = _printKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Resolusi tinggi (3x)
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Tempel foto tersebut ke dalam 1 halaman PDF penuh
      final pdf = pw.Document();
      final imagePdf = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20), // Kasih pinggiran dikit biar rapi
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(imagePdf, fit: pw.BoxFit.contain), // Gambar akan menyesuaikan proporsi A4
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      Get.back(); // Tutup loading

      await Printing.sharePdf(bytes: pdfBytes, filename: 'Kegiatan_${data['judul'] ?? 'Posbankum'}.pdf');
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Gagal memproses PDF: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(bottom: 0, left: 0, child: Container(width: 50, height: 50, color: Colors.white)),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: darkBlueColor,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28)),
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
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Detail Kegiatan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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
}