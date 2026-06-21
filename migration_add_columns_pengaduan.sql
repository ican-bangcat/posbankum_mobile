-- =========================================================================
-- MIGRASI: Tambah kolom id_paralegal ke tabel `pengaduan`
-- Jalankan SQL ini di phpMyAdmin / MySQL CLI di server sibapak.pocari.id
--
-- CATATAN: Sesuai requirement dosen, tabel `pengaduan` TIDAK menyimpan
-- id_posbankum, id_kabupaten, id_kecamatan, id_kelurahan.
-- Relasi ke posbankum diperoleh secara dinamis via JOIN:
--   pengaduan.user_id → masyarakat.id_kelurahan → posbankum.id_kelurahan
-- =========================================================================

-- Tambah kolom id_paralegal (FK ke tabel users — paralegal yang klaim/ambil kasus)
-- Nullable: NULL artinya belum ada paralegal yang mengambil kasus ini
ALTER TABLE `pengaduan`
  ADD COLUMN `id_paralegal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `user_id`;

-- =========================================================================
-- VERIFIKASI: Cek kolom sudah ada
-- =========================================================================
-- DESCRIBE `pengaduan`;
