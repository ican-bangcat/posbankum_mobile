import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfPath,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int totalPages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  PDFViewController? pdfViewController;

  final Color primaryColor = const Color(0xFF2A2E5E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isReady && totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.WIDTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                totalPages = pages ?? 0;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = 'Halaman $page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController controller) {
              pdfViewController = controller;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page ?? 0;
              });
            },
          ),
          if (!isReady && errorMessage.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal Membuka PDF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: isReady && totalPages > 1
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.navigate_before_rounded,
                          color: currentPage > 0 ? primaryColor : Colors.grey,
                          size: 32,
                        ),
                        onPressed: currentPage > 0
                            ? () {
                                pdfViewController?.setPage(currentPage - 1);
                              }
                            : null,
                      ),
                      Text(
                        'Halaman ${currentPage + 1} dari $totalPages',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.navigate_next_rounded,
                          color: currentPage < totalPages - 1 ? primaryColor : Colors.grey,
                          size: 32,
                        ),
                        onPressed: currentPage < totalPages - 1
                            ? () {
                                pdfViewController?.setPage(currentPage + 1);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
