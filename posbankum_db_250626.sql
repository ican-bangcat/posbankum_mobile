-- phpMyAdmin SQL Dump
-- version 5.2.1deb3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 25, 2026 at 08:34 AM
-- Server version: 8.0.46-0ubuntu0.24.04.3
-- PHP Version: 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `posbankum_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `berita`
--

CREATE TABLE `berita` (
  `id_berita` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_user` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `judul` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `isi` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `gambar` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tgl_publish` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `kategori` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Kegiatan'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `berita`
--
DELIMITER $$
CREATE TRIGGER `berita_before_insert` BEFORE INSERT ON `berita` FOR EACH ROW BEGIN
  IF NEW.id_berita IS NULL OR NEW.id_berita = '' THEN
    SET NEW.id_berita = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chat_pesan`
--

CREATE TABLE `chat_pesan` (
  `id_pesan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_pengaduan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pengirim_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pengirim_nama` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pengirim_role` enum('admin','paralegal','warga') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `isi_pesan` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `lampiran_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `chat_pesan`
--
DELIMITER $$
CREATE TRIGGER `chat_pesan_before_insert` BEFORE INSERT ON `chat_pesan` FOR EACH ROW BEGIN
  IF NEW.id_pesan IS NULL OR NEW.id_pesan = '' THEN
    SET NEW.id_pesan = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `data_posbankum`
--

CREATE TABLE `data_posbankum` (
  `id_data` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_posbankum` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `kategori` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `path_berkas` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tgl_upload` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status_verifikasi` enum('menunggu','disetujui','ditolak') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'menunggu',
  `id_user_verifikator` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tgl_verifikasi` datetime DEFAULT NULL,
  `nama_berkas` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mime_type` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `size_bytes` bigint DEFAULT NULL,
  `catatan_admin` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `data_posbankum`
--
DELIMITER $$
CREATE TRIGGER `data_posbankum_before_insert` BEFORE INSERT ON `data_posbankum` FOR EACH ROW BEGIN
  IF NEW.id_data IS NULL OR NEW.id_data = '' THEN
    SET NEW.id_data = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` smallint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kabupaten`
--

CREATE TABLE `kabupaten` (
  `id_kabupaten` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nama` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `kabupaten`
--
DELIMITER $$
CREATE TRIGGER `kabupaten_before_insert` BEFORE INSERT ON `kabupaten` FOR EACH ROW BEGIN
  IF NEW.id_kabupaten IS NULL OR NEW.id_kabupaten = '' THEN
    SET NEW.id_kabupaten = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `kecamatan`
--

CREATE TABLE `kecamatan` (
  `id_kecamatan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_kabupaten` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `kecamatan`
--
DELIMITER $$
CREATE TRIGGER `kecamatan_before_insert` BEFORE INSERT ON `kecamatan` FOR EACH ROW BEGIN
  IF NEW.id_kecamatan IS NULL OR NEW.id_kecamatan = '' THEN
    SET NEW.id_kecamatan = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `kegiatan`
--

CREATE TABLE `kegiatan` (
  `id_kegiatan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_posbankum` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `judul` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `deskripsi` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `catatan` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('draft','menunggu','disetujui','ditolak') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'menunggu',
  `tgl_upload` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tgl_mulai` date DEFAULT NULL,
  `tgl_selesai` date DEFAULT NULL,
  `thumbnail_path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `lokasi` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `anggota_terlibat` json DEFAULT NULL,
  `kategori` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hasil_kegiatan` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_user_verifikator` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tgl_verifikasi` datetime DEFAULT NULL,
  `catatan_admin` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `kegiatan`
--
DELIMITER $$
CREATE TRIGGER `kegiatan_before_insert` BEFORE INSERT ON `kegiatan` FOR EACH ROW BEGIN
  IF NEW.id_kegiatan IS NULL OR NEW.id_kegiatan = '' THEN
    SET NEW.id_kegiatan = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `kelurahan`
--

CREATE TABLE `kelurahan` (
  `id_kelurahan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_kecamatan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `jenis` enum('kelurahan','desa','desa_adat') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `kode_pos` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `kelurahan`
--
DELIMITER $$
CREATE TRIGGER `kelurahan_before_insert` BEFORE INSERT ON `kelurahan` FOR EACH ROW BEGIN
  IF NEW.id_kelurahan IS NULL OR NEW.id_kelurahan = '' THEN
    SET NEW.id_kelurahan = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `masyarakat`
--

CREATE TABLE `masyarakat` (
  `id_user` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nik` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alamat` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `id_kabupaten` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_kecamatan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_kelurahan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id_notifikasi` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_posbankum` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_user_penerima` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `judul` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pesan` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `kategori` enum('pengaduan','kegiatan','dokumen','sistem') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `prioritas` enum('tinggi','sedang','rendah') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'sedang',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `read_at` datetime DEFAULT NULL,
  `ref_table` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ref_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `notifikasi`
--
DELIMITER $$
CREATE TRIGGER `notifikasi_before_insert` BEFORE INSERT ON `notifikasi` FOR EACH ROW BEGIN
  IF NEW.id_notifikasi IS NULL OR NEW.id_notifikasi = '' THEN
    SET NEW.id_notifikasi = UUID()$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `notifikasi_before_update` BEFORE UPDATE ON `notifikasi` FOR EACH ROW BEGIN
  IF NEW.is_read = 1 AND NEW.read_at IS NULL THEN
    SET NEW.read_at = NOW()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengaduan`
--

CREATE TABLE `pengaduan` (
  `id_pengaduan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nomor_pengaduan` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama_pelapor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nomor_telepon` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nik` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jenis_masalah` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `judul_pengaduan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `kronologi` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tanggal_kejadian` date NOT NULL,
  `waktu_kejadian` time DEFAULT NULL,
  `lokasi_kejadian` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('menunggu','diproses','selesai','dibatalkan') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'menunggu',
  `prioritas` enum('Sangat Tinggi','Tinggi','Menengah','Normal','Rendah') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Normal',
  `catatan_internal` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tgl_selesai` datetime DEFAULT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_paralegal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `pengaduan`
--
DELIMITER $$
CREATE TRIGGER `pengaduan_before_insert` BEFORE INSERT ON `pengaduan` FOR EACH ROW BEGIN
  IF NEW.id_pengaduan IS NULL OR NEW.id_pengaduan = '' THEN
    SET NEW.id_pengaduan = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pengaduan_lampiran`
--

CREATE TABLE `pengaduan_lampiran` (
  `id_lampiran` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_pengaduan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_timeline` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nama_file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `path_file` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `size_bytes` bigint DEFAULT NULL,
  `jenis_lampiran` enum('bukti_awal','progress','chat','lainnya') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'bukti_awal',
  `created_by` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `pengaduan_lampiran`
--
DELIMITER $$
CREATE TRIGGER `pengaduan_lampiran_before_insert` BEFORE INSERT ON `pengaduan_lampiran` FOR EACH ROW BEGIN
  IF NEW.id_lampiran IS NULL OR NEW.id_lampiran = '' THEN
    SET NEW.id_lampiran = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pengaduan_timeline`
--

CREATE TABLE `pengaduan_timeline` (
  `id_timeline` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_pengaduan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipe` enum('status','catatan','lampiran','sistem') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'status',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `deskripsi` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_visible` tinyint(1) NOT NULL DEFAULT '1',
  `tanggal` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `pengaduan_timeline`
--
DELIMITER $$
CREATE TRIGGER `pengaduan_timeline_before_insert` BEFORE INSERT ON `pengaduan_timeline` FOR EACH ROW BEGIN
  IF NEW.id_timeline IS NULL OR NEW.id_timeline = '' THEN
    SET NEW.id_timeline = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `posbankum`
--

CREATE TABLE `posbankum` (
  `id_posbankum` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_kelurahan` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gambar` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `nomor_tlp` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alamat` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `kode_pos` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_akun` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_akun` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `status_verifikasi_tagging_area` enum('menunggu','disetujui','ditolak') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'menunggu',
  `catatan_verifikasi_tagging_area` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tgl_verifikasi_tagging_area` datetime DEFAULT NULL,
  `id_user_verifikator_tagging_area` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `posbankum`
--
DELIMITER $$
CREATE TRIGGER `posbankum_before_insert` BEFORE INSERT ON `posbankum` FOR EACH ROW BEGIN
  IF NEW.id_posbankum IS NULL OR NEW.id_posbankum = '' THEN
    SET NEW.id_posbankum = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `posbankum_paralegal`
--

CREATE TABLE `posbankum_paralegal` (
  `id_relasi` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `id_posbankum` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_user` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `status` enum('aktif','nonaktif') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'aktif',
  `assigned_by` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assigned_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `posbankum_paralegal`
--
DELIMITER $$
CREATE TRIGGER `posbankum_paralegal_before_insert` BEFORE INSERT ON `posbankum_paralegal` FOR EACH ROW BEGIN
  IF NEW.id_relasi IS NULL OR NEW.id_relasi = '' THEN
    SET NEW.id_relasi = UUID()$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `posbankum_paralegal_before_update` BEFORE UPDATE ON `posbankum_paralegal` FOR EACH ROW BEGIN
  IF (
    SELECT COUNT(*)
    FROM users
    WHERE id_user = NEW.id_user
      AND role = 'paralegal'
  ) = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'User yang dimasukkan harus memiliki role paralegal'$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `payload` longtext NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_user` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nama_lengkap` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `google_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `google_token` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','paralegal','warga') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'warga',
  `nip` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_kantor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nomor_telepon` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nomor_kantor` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jabatan` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unit_kerja` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alamat_kantor` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `foto_profile` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('aktif','nonaktif') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'aktif',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `users`
--
DELIMITER $$
CREATE TRIGGER `users_before_insert` BEFORE INSERT ON `users` FOR EACH ROW BEGIN
  IF NEW.id_user IS NULL OR NEW.id_user = '' THEN
    SET NEW.id_user = UUID()$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_paralegal_posbankum`
-- (See below for the actual view)
--
CREATE TABLE `v_paralegal_posbankum` (
`alamat_posbankum` text
,`assigned_at` datetime
,`email` varchar(255)
,`id_kabupaten` char(36)
,`id_kecamatan` char(36)
,`id_kelurahan` char(36)
,`id_posbankum` char(36)
,`id_relasi` char(36)
,`id_user` char(36)
,`is_primary` tinyint(1)
,`nama_kabupaten` varchar(150)
,`nama_kecamatan` varchar(150)
,`nama_kelurahan` varchar(150)
,`nama_lengkap` varchar(255)
,`nama_posbankum` varchar(255)
,`nomor_telepon` varchar(30)
,`status_relasi` enum('aktif','nonaktif')
,`status_user` enum('aktif','nonaktif')
);

-- --------------------------------------------------------

--
-- Structure for view `v_paralegal_posbankum`
--
DROP TABLE IF EXISTS `v_paralegal_posbankum`;

CREATE ALGORITHM=UNDEFINED DEFINER=`ikhsan`@`localhost` SQL SECURITY DEFINER VIEW `v_paralegal_posbankum`  AS SELECT `u`.`id_user` AS `id_user`, `u`.`nama_lengkap` AS `nama_lengkap`, `u`.`email` AS `email`, `u`.`nomor_telepon` AS `nomor_telepon`, `u`.`status` AS `status_user`, `pp`.`id_relasi` AS `id_relasi`, `pp`.`id_posbankum` AS `id_posbankum`, `pp`.`is_primary` AS `is_primary`, `pp`.`status` AS `status_relasi`, `pp`.`assigned_at` AS `assigned_at`, `p`.`nama` AS `nama_posbankum`, `p`.`alamat` AS `alamat_posbankum`, `kel`.`id_kelurahan` AS `id_kelurahan`, `kel`.`nama` AS `nama_kelurahan`, `kec`.`id_kecamatan` AS `id_kecamatan`, `kec`.`nama` AS `nama_kecamatan`, `kab`.`id_kabupaten` AS `id_kabupaten`, `kab`.`nama` AS `nama_kabupaten` FROM (((((`users` `u` join `posbankum_paralegal` `pp` on((`pp`.`id_user` = `u`.`id_user`))) join `posbankum` `p` on((`p`.`id_posbankum` = `pp`.`id_posbankum`))) join `kelurahan` `kel` on((`kel`.`id_kelurahan` = `p`.`id_kelurahan`))) join `kecamatan` `kec` on((`kec`.`id_kecamatan` = `kel`.`id_kecamatan`))) join `kabupaten` `kab` on((`kab`.`id_kabupaten` = `kec`.`id_kabupaten`))) WHERE (`u`.`role` = 'paralegal') ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `berita`
--
ALTER TABLE `berita`
  ADD PRIMARY KEY (`id_berita`),
  ADD KEY `fk_berita_user` (`id_user`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `chat_pesan`
--
ALTER TABLE `chat_pesan`
  ADD PRIMARY KEY (`id_pesan`),
  ADD KEY `fk_chat_pesan_pengaduan` (`id_pengaduan`),
  ADD KEY `fk_chat_pesan_pengirim` (`pengirim_id`);

--
-- Indexes for table `data_posbankum`
--
ALTER TABLE `data_posbankum`
  ADD PRIMARY KEY (`id_data`),
  ADD KEY `fk_data_posbankum_posbankum` (`id_posbankum`),
  ADD KEY `fk_data_posbankum_verifikator` (`id_user_verifikator`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `kabupaten`
--
ALTER TABLE `kabupaten`
  ADD PRIMARY KEY (`id_kabupaten`);

--
-- Indexes for table `kecamatan`
--
ALTER TABLE `kecamatan`
  ADD PRIMARY KEY (`id_kecamatan`),
  ADD KEY `fk_kecamatan_kabupaten` (`id_kabupaten`);

--
-- Indexes for table `kegiatan`
--
ALTER TABLE `kegiatan`
  ADD PRIMARY KEY (`id_kegiatan`),
  ADD KEY `fk_kegiatan_posbankum` (`id_posbankum`),
  ADD KEY `fk_kegiatan_created_by` (`created_by`),
  ADD KEY `fk_kegiatan_verifikator` (`id_user_verifikator`),
  ADD KEY `kegiatan_status_index` (`status`);

--
-- Indexes for table `kelurahan`
--
ALTER TABLE `kelurahan`
  ADD PRIMARY KEY (`id_kelurahan`),
  ADD KEY `fk_kelurahan_kecamatan` (`id_kecamatan`);

--
-- Indexes for table `masyarakat`
--
ALTER TABLE `masyarakat`
  ADD PRIMARY KEY (`id_user`),
  ADD KEY `fk_masyarakat_kabupaten` (`id_kabupaten`),
  ADD KEY `fk_masyarakat_kecamatan` (`id_kecamatan`),
  ADD KEY `fk_masyarakat_kelurahan` (`id_kelurahan`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id_notifikasi`),
  ADD KEY `notifikasi_ref_index` (`ref_table`,`ref_id`),
  ADD KEY `fk_notifikasi_user_penerima` (`id_user_penerima`),
  ADD KEY `fk_notifikasi_posbankum` (`id_posbankum`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `pengaduan`
--
ALTER TABLE `pengaduan`
  ADD PRIMARY KEY (`id_pengaduan`),
  ADD UNIQUE KEY `pengaduan_nomor_unique` (`nomor_pengaduan`),
  ADD KEY `pengaduan_created_by_index` (`user_id`);

--
-- Indexes for table `pengaduan_lampiran`
--
ALTER TABLE `pengaduan_lampiran`
  ADD PRIMARY KEY (`id_lampiran`),
  ADD KEY `fk_lampiran_pengaduan` (`id_pengaduan`),
  ADD KEY `fk_lampiran_timeline` (`id_timeline`),
  ADD KEY `fk_lampiran_created_by` (`created_by`);

--
-- Indexes for table `pengaduan_timeline`
--
ALTER TABLE `pengaduan_timeline`
  ADD PRIMARY KEY (`id_timeline`),
  ADD KEY `fk_timeline_pengaduan` (`id_pengaduan`),
  ADD KEY `fk_timeline_created_by` (`created_by`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `posbankum`
--
ALTER TABLE `posbankum`
  ADD PRIMARY KEY (`id_posbankum`),
  ADD UNIQUE KEY `posbankum_id_kelurahan_unique` (`id_kelurahan`),
  ADD KEY `fk_posbankum_verifikator` (`id_user_verifikator_tagging_area`);

--
-- Indexes for table `posbankum_paralegal`
--
ALTER TABLE `posbankum_paralegal`
  ADD PRIMARY KEY (`id_relasi`),
  ADD UNIQUE KEY `posbankum_paralegal_posbankum_user_unique` (`id_posbankum`,`id_user`),
  ADD KEY `fk_paralegal_user` (`id_user`),
  ADD KEY `fk_paralegal_assigned_by` (`assigned_by`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `berita`
--
ALTER TABLE `berita`
  ADD CONSTRAINT `fk_berita_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE RESTRICT;

--
-- Constraints for table `chat_pesan`
--
ALTER TABLE `chat_pesan`
  ADD CONSTRAINT `fk_chat_pesan_pengaduan` FOREIGN KEY (`id_pengaduan`) REFERENCES `pengaduan` (`id_pengaduan`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_chat_pesan_pengirim` FOREIGN KEY (`pengirim_id`) REFERENCES `users` (`id_user`) ON DELETE RESTRICT;

--
-- Constraints for table `data_posbankum`
--
ALTER TABLE `data_posbankum`
  ADD CONSTRAINT `fk_data_posbankum_posbankum` FOREIGN KEY (`id_posbankum`) REFERENCES `posbankum` (`id_posbankum`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_data_posbankum_verifikator` FOREIGN KEY (`id_user_verifikator`) REFERENCES `users` (`id_user`) ON DELETE SET NULL;

--
-- Constraints for table `kecamatan`
--
ALTER TABLE `kecamatan`
  ADD CONSTRAINT `fk_kecamatan_kabupaten` FOREIGN KEY (`id_kabupaten`) REFERENCES `kabupaten` (`id_kabupaten`) ON DELETE CASCADE;

--
-- Constraints for table `kegiatan`
--
ALTER TABLE `kegiatan`
  ADD CONSTRAINT `fk_kegiatan_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id_user`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_kegiatan_posbankum` FOREIGN KEY (`id_posbankum`) REFERENCES `posbankum` (`id_posbankum`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_kegiatan_verifikator` FOREIGN KEY (`id_user_verifikator`) REFERENCES `users` (`id_user`) ON DELETE SET NULL;

--
-- Constraints for table `kelurahan`
--
ALTER TABLE `kelurahan`
  ADD CONSTRAINT `fk_kelurahan_kecamatan` FOREIGN KEY (`id_kecamatan`) REFERENCES `kecamatan` (`id_kecamatan`) ON DELETE CASCADE;

--
-- Constraints for table `masyarakat`
--
ALTER TABLE `masyarakat`
  ADD CONSTRAINT `fk_masyarakat_kabupaten` FOREIGN KEY (`id_kabupaten`) REFERENCES `kabupaten` (`id_kabupaten`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_masyarakat_kecamatan` FOREIGN KEY (`id_kecamatan`) REFERENCES `kecamatan` (`id_kecamatan`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_masyarakat_kelurahan` FOREIGN KEY (`id_kelurahan`) REFERENCES `kelurahan` (`id_kelurahan`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_masyarakat_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD CONSTRAINT `fk_notifikasi_posbankum` FOREIGN KEY (`id_posbankum`) REFERENCES `posbankum` (`id_posbankum`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_notifikasi_user_penerima` FOREIGN KEY (`id_user_penerima`) REFERENCES `users` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `pengaduan`
--
ALTER TABLE `pengaduan`
  ADD CONSTRAINT `pengaduan_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id_user`) ON UPDATE CASCADE;

--
-- Constraints for table `pengaduan_lampiran`
--
ALTER TABLE `pengaduan_lampiran`
  ADD CONSTRAINT `fk_lampiran_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id_user`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_lampiran_pengaduan` FOREIGN KEY (`id_pengaduan`) REFERENCES `pengaduan` (`id_pengaduan`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_lampiran_timeline` FOREIGN KEY (`id_timeline`) REFERENCES `pengaduan_timeline` (`id_timeline`) ON DELETE SET NULL;

--
-- Constraints for table `pengaduan_timeline`
--
ALTER TABLE `pengaduan_timeline`
  ADD CONSTRAINT `fk_timeline_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id_user`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_timeline_pengaduan` FOREIGN KEY (`id_pengaduan`) REFERENCES `pengaduan` (`id_pengaduan`) ON DELETE CASCADE;

--
-- Constraints for table `posbankum`
--
ALTER TABLE `posbankum`
  ADD CONSTRAINT `fk_posbankum_kelurahan` FOREIGN KEY (`id_kelurahan`) REFERENCES `kelurahan` (`id_kelurahan`) ON DELETE RESTRICT,
  ADD CONSTRAINT `fk_posbankum_verifikator` FOREIGN KEY (`id_user_verifikator_tagging_area`) REFERENCES `users` (`id_user`) ON DELETE SET NULL;

--
-- Constraints for table `posbankum_paralegal`
--
ALTER TABLE `posbankum_paralegal`
  ADD CONSTRAINT `fk_paralegal_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id_user`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_paralegal_posbankum` FOREIGN KEY (`id_posbankum`) REFERENCES `posbankum` (`id_posbankum`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_paralegal_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
