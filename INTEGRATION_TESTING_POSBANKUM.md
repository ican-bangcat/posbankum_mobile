# DOKUMEN PENGUJIANKELAS DAN SKENARIO UJI INTEGRASI (INTEGRATION TESTING)
## SISTEM APLIKASI POSBANKUM BERDAMPAK (SIBAPAK)
### INTEGRASI TERHUBUNG WEBSITE ADMIN LARAVEL ↔ BACKEND REST API ↔ MOBILE APP FLUTTER

---

## 📋 DAFTAR ISI

*   **1. PENDAHULUAN & ARSITEKTUR INTEGRASI**
*   **2. LINGKUNGAN PENGUJIAN INTEGRASI (WEB ↔ BACKEND ↔ MOBILE)**
*   **3. SKENARIO DAN HASIL PENGUJIAN INTEGRASI WEB-MOBILE**
    *   **3.1 INT_01:** Integrasi Pengajuan Pengaduan Warga (Mobile) ➔ Panel Monitoring Admin (Web)
    *   **3.2 INT_02:** Integrasi Pengklaiman & Status Kasus Paralegal (Mobile) ➔ Dashboard Statistik (Web)
    *   **3.3 INT_03:** Integrasi Laporan Kegiatan Lapangan (Mobile) ➔ Verifikasi & Approval Admin (Web) ➔ Notifikasi Status (Mobile)
    *   **3.4 INT_04:** Integrasi Pendaftaran Akun Paralegal (Web Admin) ➔ Login Google OAuth (Mobile)
    *   **3.5 INT_05:** Integrasi Manajemen Posbankum & Wilayah Riau (Web Admin) ➔ Dynamic Dropdown (Mobile)
    *   **3.6 INT_06:** Integrasi Ruang Obrolan Chat & Lampiran Media (Mobile Warga ↔ Mobile Paralegal ↔ Server DB)
    *   **3.7 INT_07:** Integrasi Penutupan Kasus & Audit Catatan Internal (Mobile Paralegal ➔ Web Admin Audit)
    *   **3.8 INT_08:** Integrasi Trigger Notifikasi Sistem & Push FCM (Action Trigger ➔ MySQL DB ➔ FCM Status Bar)
*   **4. REKAPITULASI HASIL PENGUJIAN INTEGRASI WEB-MOBILE**

---

## 1. PENDAHULUAN & ARSITEKTUR INTEGRASI

Dokumen ini berisi catatan pengujian **Integration Testing (Pengujian Integrasi)** untuk Sistem Aplikasi Posbankum Berdampak (SIBAPAK). Tujuan utama dari pengujian ini adalah **memverifikasi dan membuktikan secara empiris bahwa Website Admin (Laravel Web) dan Aplikasi Mobile (Flutter Warga & Paralegal) saling terhubung 100% secara real-time** melalui Backend REST API dan Database Server MySQL yang terpusat.

```
┌────────────────────────────────┐                 ┌────────────────────────────────┐
│   APLIKASI MOBILE (FLUTTER)    │                 │    WEBSITE ADMIN (LARAVEL)     │
│   • POV Warga (Pelapor)        │                 │    • Admin Kemenkumham Riau    │
│   • POV Paralegal (Pendamping) │                 │    • Verifikasi & Pengawasan    │
└───────────────┬────────────────┘                 └───────────────┬────────────────┘
                │                                                  │
                │        HTTP REST API / Bearer Token / Multipart  │
                └────────────────────────┬─────────────────────────┘
                                         ▼
                        ┌─────────────────────────────────┐
                        │    BACKEND SERVER & DATABASE    │
                        │    • Laravel REST API Server    │
                        │    • Database MySQL (posbankum) │
                        │    • Storage Directory (Files)  │
                        │    • FCM Push Notification      │
                        └─────────────────────────────────┘
```

 Melalui pengujian integrasi ini, dipastikan tidak ada isolasi data antar-platform. Setiap aksi yang dilakukan pengguna pada aplikasi Mobile akan langsung terefleksi pada portal Website Admin, dan sebaliknya.

---

## 2. LINGKUNGAN PENGUJIAN INTEGRASI (WEB ↔ BACKEND ↔ MOBILE)

*   **Aplikasi Mobile (Client):** SIBAPAK Mobile App (Flutter v3.x, Android / iOS)
*   **Aplikasi Web (Admin):** Portal SIBAPAK Web Admin (Laravel 10.x, Blade & Livewire/Bootstrap)
*   **Backend Server & Database:** RESTful API Laravel, Database MySQL (`posbankum_db`), Public File Storage
*   **Layanan Layar Depan / Push:** Firebase Cloud Messaging (FCM) SDK Service
*   **Metode Komunikasi:** HTTP/HTTPS REST API, JSON Payload, Multipart/form-data Upload File, Bearer Token Authentication

---

## 3. SKENARIO DAN HASIL PENGUJIAN INTEGRASI WEB-MOBILE

### 3.1 INT_01: Integrasi Pengajuan Pengaduan Warga (Mobile) ➔ Panel Monitoring Admin (Web)
Menguji integrasi saat Warga mengirimkan pengaduan baru dari HP Mobile, dan dampaknya pada portal Website Admin Kemenkumham.

| No | Komponen Terintegrasi | Skenario Pengujian Integrasi | Hasil yang Diharapkan | Hasil Uji |
| :-: | :--- | :--- | :--- | :---: |
| 1 | Mobile Warga ➔ API Laravel ➔ MySQL DB ➔ Web Admin | Warga mengajukan pengaduan baru dari HP Mobile (mengisi kronologi, lokasi kejadian Riau, & mengunggah bukti awal JPG/PDF). | 1. API `POST /pengaduan` sukses (201 Created).<br>2. Data tersimpan di tabel `pengaduan` & `pengaduan_lampiran`.<br>3. Admin Web membuka menu **Data Pengaduan** di Website, dan pengaduan Warga **langsung muncul di tabel web secara real-time**. | [*] Berhasil<br>[ ] Gagal |
| 2 | Mobile Warga ➔ Storage Laravel ➔ Web Admin | Admin Web mengeklik tombol **Detail / Lihat Bukti** pada pengaduan Warga di Website Admin. | File foto/PDF bukti awal yang diunggah dari HP Warga dapat dibuka & diunduh dengan sempurna dari server storage oleh Admin Web. | [*] Berhasil<br>[ ] Gagal |

---

### 3.2 INT_02: Integrasi Pengklaiman & Status Kasus Paralegal (Mobile) ➔ Dashboard Statistik (Web)
Menguji integrasi perubahan status kasus oleh Paralegal dari HP Mobile terhadap grafik statistik & tabel pengaduan di Website Admin.

| No | Komponen Terintegrasi | Skenario Pengujian Integrasi | Hasil yang Diharapkan | Hasil Uji |
| :-: | :--- | :--- | :--- | :---: |
| 3 | Mobile Paralegal ➔ API Laravel ➔ Web Admin Dashboard | Paralegal mengeklik tombol **Ambil Kasus** pada aplikasi Mobile untuk memproses aduan Warga. | 1. API `PATCH /pengaduan/{id}/status` mengubah status menjadi `diproses`.<br>2. Pada Website Admin, status aduan di tabel **otomatis berubah menjadi "SEDANG DIPROSES"**.<br>3. Widget grafik statistik beranda Web Admin meng-update jumlah kasus diproses. | [*] Berhasil<br>[ ] Gagal |
| 4 | Mobile Paralegal ➔ MySQL DB ➔ Web Admin | Admin Web membuka detail aduan di Website setelah kasus diambil Paralegal. | Website Admin menampilkan identitas Paralegal yang mendampingi kasus tersebut secara tepat. | [*] Berhasil<br>[ ] Gagal |

---

### 3.3 INT_03: Integrasi Laporan Kegiatan Lapangan (Mobile) ➔ Verifikasi & Approval Admin (Web) ➔ Notifikasi Status (Mobile)
Menguji alur dua arah: Paralegal melapor via Mobile ➔ Admin Web melakukan approval di Website ➔ Status & catatan admin ter-update di Mobile.

| No | Komponen Terintegrasi | Skenario Pengujian Integrasi | Hasil yang Diharapkan | Hasil Uji |
| :-: | :--- | :--- | :--- | :---: |
| 5 | Mobile Paralegal ➔ MySQL DB ➔ Web Admin Verification | Paralegal membuat Laporan Kegiatan Lapangan (penyuluhan) disertai foto dari HP Mobile. | Laporan masuk ke halaman **Verifikasi Kegiatan** pada Website Admin dengan status `Menunggu`. | [*] Berhasil<br>[ ] Gagal |
| 6 | Web Admin Approval ➔ MySQL DB ➔ Mobile Paralegal | Admin Web mengeklik **Setujui** (atau **Tolak + Catatan Admin**) pada laporan kegiatan tersebut di Website. | 1. Status kegiatan di database ter-update menjadi `Disetujui` / `Ditolak`.<br>2. Pada HP Mobile Paralegal, badge status kegiatan berubah dan **catatan admin dari Web langsung muncul di detail kegiatan**. | [*] Berhasil<br>[ ] Gagal |

---

### 3.4 INT_04: Integrasi Pendaftaran Akun Paralegal (Web Admin) ➔ Login Google OAuth (Mobile)
Menguji integrasi hak akses akun Paralegal yang didaftarkan oleh Admin di Website terhadap autentikasi Google OAuth di Mobile App.

| No | Komponen Terintegrasi | Skenario Pengujian Integrasi | Hasil yang Diharapkan | Hasil Uji |
| :-: | :--- | :--- | :--- | :---: |
| 7 | Web Admin Management ➔ MySQL DB `users` | Admin Web menginput data & email Paralegal baru pada menu **Kelola Paralegal** di Website Admin. | Data Paralegal tersimpan di database dengan `role = paralegal` dan wilayah kelurahan tugasnya. | [*] Berhasil<br>[ ] Gagal |
| 8 | Mobile App Auth ➔ API Laravel ➔ Mobile Session | Paralegal baru melakukan login menggunakan Google OAuth di Mobile App menggunakan email yang didaftarkan Admin. | Backend merespon registrasi role `paralegal`, dan Mobile App langsung mengarahkan ke **Dashboard Paralegal** (bukan Warga). | [*] Berhasil<br>[ ] Gagal |

---

### 3.5 INT_05: Integrasi Manajemen Posbankum & Wilayah Riau (Web Admin) ➔ Dynamic Dropdown (Mobile)
Menguji integrasi data master Posbankum & Wilayah Riau di Website Admin terhadap pilihan dropdown di Mobile App Warga.

| No | Komponen Terintegrasi | Skenario Pengujian Integrasi | Hasil yang Diharapkan | Hasil Uji |
| :-: | :--- | :--- | :--- | :---: |
| 9 | Web Admin Master ➔ MySQL DB `posbankum` | Admin Web menambah / memperbarui data titik kantor Posbankum atau wilayah kerja di Website Admin. | Data master Posbankum terbaru tersimpan di database server. | [*] Berhasil<br>[ ] Gagal |
| 10 | Mobile App Profile ➔ API Laravel ➔ Mobile UI | Warga membuka form kelengkapan profil / wilayah kejadian di Mobile App. | Mobile App menarik data via API (`GET /wilayah` & `GET /posbankum`) dan menampilkan daftar wilayah Riau secara dinamis. | [*] Berhasil<br>[ ] Gagal |

---

### 3.6 INT_06: Integrasi Ruang Obrolan Chat & Lampiran Media (Mobile Warga ↔ Mobile Paralegal ↔ Server DB)
Menguji integrasi pertukaran pesan teks dan lampiran foto/PDF antar-aktor Mobile yang terhubung via Backend API server.

| No | Komponen Terintegrasi | Skenario Pengujian Integrasi | Hasil yang Diharapkan | Hasil Uji |
| :-: | :--- | :--- | :--- | :---: |
| 11 | Mobile Warga ➔ API Chat Laravel ➔ Mobile Paralegal | Warga mengirim pesan chat teks dari HP Mobile ke Paralegal pendamping kasusnya. | Pesan tersimpan di database `chat` dan langsung diterima/tampil pada gelembung percakapan HP Paralegal. | [*] Berhasil<br>[ ] Gagal |
| 12 | Mobile Paralegal ➔ Storage Server ➔ Mobile Warga | Paralegal mengunggah lampiran dokumen PDF/foto di ruang chat dari HP-nya. | File terunggah ke *storage* server, dan Warga dapat membuka/mempratinjau dokumen tersebut dari HP-nya. | [*] Berhasil<br>[ ] Gagal |

---

### 3.7 INT_07: Integrasi Penutupan Kasus & Audit Catatan Internal (Mobile Paralegal ➔ Web Admin Audit)
Menguji integrasi data penutupan kasus dan catatan penyelesaian dari Mobile App ke modul rekapitulasi laporan Web Admin.

| No | Komponen Terintegrasi | Skenario Pengujian Integrasi | Hasil yang Diharapkan | Hasil Uji |
| :-: | :--- | :--- | :--- | :---: |
| 13 | Mobile Paralegal ➔ API Status ➔ Web Admin Report | Paralegal menutup kasus dengan status **Selesai** disertai catatan hasil penyelesaian dari HP Mobile. | 1. Status kasus berubah menjadi `selesai`.<br>2. Admin Web dapat mencetak / melihat laporan rekapitulasi kasus selesai beserta **catatan penyelesaiannya pada Website Admin**. | [*] Berhasil<br>[ ] Gagal |

---

### 3.8 INT_08: Integrasi Trigger Notifikasi Sistem & Push FCM (Action Trigger ➔ MySQL DB ➔ FCM Status Bar)
Menguji integrasi pemicuan notifikasi dari aksi di backend/web/mobile hingga muncul pada bilah pemberitahuan (*status bar*) HP pengguna.

| No | Komponen Terintegrasi | Skenario Pengujian Integrasi | Hasil yang Diharapkan | Hasil Uji |
| :-: | :--- | :--- | :--- | :---: |
| 14 | Backend Trigger ➔ Database `notifikasi` ➔ FCM Service | Ada aksi perubahan status kasus / persetujuan kegiatan / progres baru. | 1. Baris notifikasi baru otomatis ter-insert di tabel `notifikasi`.<br>2. Service FCM mengirimkan *push notification* ke token HP penerima.<br>3. Banner notifikasi melayang muncul di status bar HP pengguna. | [*] Berhasil<br>[ ] Gagal |
| 15 | Mobile App Post Frame ➔ API Notifikasi ➔ Mobile Center | Pengguna membuka layar Pusat Notifikasi di Mobile App. | Mobile App otomatis melakukan sinkronisasi (*post frame refresh*) dan menampilkan daftar notifikasi terbaru dari server. | [*] Berhasil<br>[ ] Gagal |

---

## 4. REKAPITULASI HASIL PENGUJIAN INTEGRASI WEB-MOBILE

Berikut adalah rekapitulasi hasil pengujian integrasi antara Website Admin (Laravel), Backend REST API, dan Mobile App (Flutter):

| Kode Integrasi | Area Integrasi Teruji | Jumlah Skenario | Berhasil | Gagal | Persentase Keberhasilan | Status Integrasi |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **INT_01** | Pengaduan Warga (Mobile) ➔ Monitoring (Web) | 2 | 2 | 0 | **100%** | **Terhubung Sempurna** |
| **INT_02** | Status Kasus Paralegal (Mobile) ➔ Dashboard (Web) | 2 | 2 | 0 | **100%** | **Terhubung Sempurna** |
| **INT_03** | Laporan Kegiatan (Mobile) ➔ Approval Admin (Web) | 2 | 2 | 0 | **100%** | **Terhubung Sempurna** |
| **INT_04** | Registrasi Paralegal (Web) ➔ Login OAuth (Mobile) | 2 | 2 | 0 | **100%** | **Terhubung Sempurna** |
| **INT_05** | Master Posbankum (Web) ➔ Dropdown Wilayah (Mobile) | 2 | 2 | 0 | **100%** | **Terhubung Sempurna** |
| **INT_06** | Chat & Lampiran (Mobile Warga ↔ Mobile Paralegal) | 2 | 2 | 0 | **100%** | **Terhubung Sempurna** |
| **INT_07** | Penutupan Kasus (Mobile) ➔ Audit Laporan (Web) | 1 | 1 | 0 | **100%** | **Terhubung Sempurna** |
| **INT_08** | Trigger Notifikasi System ➔ FCM Status Bar (Device) | 2 | 2 | 0 | **100%** | **Terhubung Sempurna** |
| **TOTAL** | **INTEGRASI SISTEM SIBAPAK (WEB ↔ MOBILE)** | **15 Skenario** | **15** | **0** | **100%** | **SISTEM TERINTEGRASI 100%** |

---
*Dokumen ini disusun sebagai bukti formal pengujian integrasi antarsistem (Web Admin Laravel & Mobile App Flutter) dalam Laporan Proyek Akhir.*
