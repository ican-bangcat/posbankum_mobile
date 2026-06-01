import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class WilayahSeeder {
  static final supabase = Supabase.instance.client;

  static Future<void> sinkronisasiWilayahRiau() async {
    const String kodeRiau = '14'; // Kode Riau
    debugPrint('🚀 MULAI MENYEDOT DATA WILAYAH RIAU...');

    try {
      // 1. AMBIL KABUPATEN
      final kabUrl = Uri.parse('https://wilayah.id/api/regencies/$kodeRiau.json');
      final kabRes = await http.get(kabUrl);
      if (kabRes.statusCode != 200) throw 'Gagal ambil Kabupaten';

      final List<dynamic> daftarKabupaten = json.decode(kabRes.body)['data'];

      for (var kab in daftarKabupaten) {
        String namaKab = kab['name'];
        String kodeKab = kab['code'];

        debugPrint('Memproses Kabupaten: $namaKab');

        // Cek apakah kabupaten sudah ada di Supabase
        var cekKab = await supabase.from('kabupaten').select('id_kabupaten').eq('nama', namaKab).maybeSingle();
        String idKabDb = '';

        if (cekKab == null) {
          var insertKab = await supabase.from('kabupaten').insert({'nama': namaKab}).select('id_kabupaten').single();
          idKabDb = insertKab['id_kabupaten'];
        } else {
          idKabDb = cekKab['id_kabupaten'];
        }

        // 2. AMBIL KECAMATAN
        final kecUrl = Uri.parse('https://wilayah.id/api/districts/$kodeKab.json');
        final kecRes = await http.get(kecUrl);

        if (kecRes.statusCode == 200) {
          final List<dynamic> daftarKecamatan = json.decode(kecRes.body)['data'];

          for (var kec in daftarKecamatan) {
            String namaKec = kec['name'];
            String kodeKec = kec['code'];

            // Cek apakah kecamatan sudah ada
            var cekKec = await supabase.from('kecamatan')
                .select('id_kecamatan')
                .eq('id_kabupaten', idKabDb)
                .eq('nama', namaKec)
                .maybeSingle();

            String idKecDb = '';

            if (cekKec == null) {
              var insertKec = await supabase.from('kecamatan').insert({
                'id_kabupaten': idKabDb,
                'nama': namaKec
              }).select('id_kecamatan').single();
              idKecDb = insertKec['id_kecamatan'];
            } else {
              idKecDb = cekKec['id_kecamatan'];
            }

            // 3. AMBIL KELURAHAN
            final kelUrl = Uri.parse('https://wilayah.id/api/villages/$kodeKec.json');
            final kelRes = await http.get(kelUrl);

            if (kelRes.statusCode == 200) {
              final List<dynamic> daftarKelurahan = json.decode(kelRes.body)['data'];
              List<Map<String, dynamic>> batchKelurahan = [];

              for (var kel in daftarKelurahan) {
                batchKelurahan.add({
                  'id_kecamatan': idKecDb,
                  'nama': kel['name'],
                });
              }

              // Masukkan semua kelurahan untuk kecamatan ini ke Supabase
              if (batchKelurahan.isNotEmpty) {
                // Hapus data lama di kecamatan ini biar nggak ganda, lalu insert baru
                await supabase.from('kelurahan').delete().eq('id_kecamatan', idKecDb);
                await supabase.from('kelurahan').insert(batchKelurahan);
              }
            }
          }
        }
      }
      debugPrint('✅ SINKRONISASI SELESAI! SILAKAN CEK DATABASE SUPABASE!');
    } catch (e) {
      debugPrint('❌ ERROR: $e');
    }
  }
}