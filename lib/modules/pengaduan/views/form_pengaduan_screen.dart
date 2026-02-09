import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../app/themes/app_colors.dart';
import 'pengaduan_success_screen.dart';

/// Form Pengaduan Screen
class FormPengaduanScreen extends StatefulWidget {
  const FormPengaduanScreen({super.key});

  @override
  State<FormPengaduanScreen> createState() => _FormPengaduanScreenState();
}

class _FormPengaduanScreenState extends State<FormPengaduanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jenisMasalahController = TextEditingController();
  final _kronologiController = TextEditingController();
  final _lokasiController = TextEditingController();
  
  String? _selectedJenisMasalah;
  String? _selectedFileName;
  String? _selectedFilePath;
  bool _isSubmitting = false;

  // Kategori jenis masalah
  final List<String> _kategoriMasalah = [
    'Hukum Pidana',
    'Hukum Perdata',
    'Hukum Keluarga',
    'Hukum Tanah',
    'Hukum Konsumen',
    'Hukum Ketenagakerjaan',
    'Lainnya',
  ];

  @override
  void dispose() {
    _jenisMasalahController.dispose();
    _kronologiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        
        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'Ukuran file maksimal 5 MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        setState(() {
          _selectedFileName = file.name;
          _selectedFilePath = file.path;
        });

        Get.snackbar(
          'Berhasil',
          'File berhasil dipilih: ${file.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFileName = null;
      _selectedFilePath = null;
    });
  }

  Future<void> _submitPengaduan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Generate ID Pengaduan
    final currentYear = DateTime.now().year;
    final randomNumber = DateTime.now().millisecondsSinceEpoch % 100000;
    final pengaduanId = 'PGN-$currentYear-${randomNumber.toString().padLeft(5, '0')}';

    setState(() {
      _isSubmitting = false;
    });

    // Navigate ke success screen
    Get.off(
      () => PengaduanSuccessScreen(pengaduanId: pengaduanId),
      transition: Transition.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Buat Pengaduan'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon
              _buildHeaderIcon(),
              
              const SizedBox(height: 24),
              
              // Jenis Masalah
              _buildJenisMasalahField(),
              
              const SizedBox(height: 20),
              
              // Kronologi Singkat
              _buildKronologiField(),
              
              const SizedBox(height: 20),
              
              // Lokasi Kejadian
              _buildLokasiField(),
              
              const SizedBox(height: 20),
              
              // Lampiran
              _buildLampiranField(),
              
              const SizedBox(height: 32),
              
              // Submit Button
              _buildSubmitButton(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_document,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat Pengaduan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Isi form di bawah untuk membuat pengaduan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJenisMasalahField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Masalah',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedJenisMasalah,
          decoration: InputDecoration(
            hintText: 'Pilih jenis masalah',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: _kategoriMasalah.map((kategori) {
            return DropdownMenuItem(
              value: kategori,
              child: Text(kategori),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedJenisMasalah = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jenis masalah harus dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKronologiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kronologi Singkat',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _kronologiController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Jelaskan kronologi permasalahan Anda...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Kronologi harus diisi';
            }
            if (value.length < 20) {
              return 'Kronologi minimal 20 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLokasiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi Kejadian',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _lokasiController,
          decoration: InputDecoration(
            hintText: 'Masukkan lokasi kejadian',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lokasi kejadian harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLampiranField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lampiran (Opsional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        // File picker button
        if (_selectedFileName == null)
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.upload_file,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unggah Lampiran',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'File: PDF, JPG, PNG (maks 5 MB)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        
        // Selected file display
        if (_selectedFileName != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color: Colors.green[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFileName!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'File berhasil dipilih',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _removeFile,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitPengaduan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Kirim Pengaduan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
