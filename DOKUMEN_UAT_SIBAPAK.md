# DOKUMEN FORMAL SKENARIO USER ACCEPTANCE TESTING (UAT)
## SISTEM APLIKASI POSBANKUM BERDAMPAK (SIBAPAK) - MODUL MOBILE

**Dokumen Kontrol:**
*   **Nama Aplikasi:** SIBAPAK (Sistem Aplikasi Posbankum Berdampak) - Versi Mobile (Android/iOS)
*   **Peran Penguji (Aktor):** Warga (Masyarakat Pelapor) & Paralegal (Pendamping Hukum)
*   **Metode Pengujian:** User Acceptance Testing (UAT) - Blackbox Testing
*   **Konteks Wilayah Utama:** Kota Pekanbaru, Provinsi Riau
*   **Tanggal Uji Coba:** 15 Juli 2026

---

## 1. STRUKTUR HIERARKI SKENARIO PENGUJIAN

### 1.1 Pengujian Aktor Warga (Masyarakat Pelapor)
Aktor Warga menggunakan aplikasi untuk melakukan pendaftaran, melengkapi profil wilayah Pekanbaru, mengajukan kasus hukum, berkonsultasi via chat real-time dengan Paralegal pendamping, serta menerima notifikasi pembaruan status pengaduan.

#### 1.1.1 Fitur Onboarding (Layar Pengenalan)
Langkah pengujian untuk memverifikasi alur navigasi pertama kali saat aplikasi dibuka oleh pengguna baru.

##### UAT_WR_01: Navigasi Layar Pengenalan (Onboarding Swiping)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_01** | Memastikan pengguna baru dapat menggeser layar intro aplikasi untuk membaca informasi dasar Posbankum. | 1. Buka aplikasi SIBAPAK Mobile pertama kali.<br>2. Lakukan geser layar (swipe) ke arah kiri pada halaman onboarding pertama dan kedua. | *Gesture* geser kiri (Swipe Left) | Layar bergeser secara halus menampilkan slide informasi kedua, kemudian slide ketiga yang berisi visualisasi pendukung. | Layar onboarding bergeser dengan transisi halus dan menampilkan konten slide berikutnya dengan tepat. | Ya |

##### UAT_WR_02: Aksi Tombol Mulai Aplikasi
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_02** | Memverifikasi tombol "Mulai" pada halaman onboarding terakhir dapat mengarahkan pengguna ke halaman Welcome. | 1. Geser slide onboarding hingga halaman terakhir (slide ketiga).<br>2. Ketuk tombol **Mulai**. | Klik tombol **Mulai** | Aplikasi menutup halaman onboarding dan secara instan mengarahkan pengguna ke halaman Welcome/Masuk. | Halaman onboarding ditutup dan pengguna langsung diarahkan masuk ke halaman Welcome. | Ya |

#### 1.1.2 Fitur Registrasi dan Login Warga
Langkah pengujian untuk memverifikasi fungsionalitas pendaftaran dan login warga menggunakan metode Google OAuth secara eksklusif.

##### UAT_WR_03: Registrasi Warga Baru via Google Sign-In
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_03** | Memverifikasi pendaftaran akun Warga baru menggunakan Single Sign-On (SSO) Google. | 1. Pada halaman masuk/daftar, ketuk tombol **Daftar dengan Google**.<br>2. Pilih akun Google baru yang belum terdaftar di database. | Akun Google:<br>`budi.pekanbaru@gmail.com` | Sistem berhasil melakukan autentikasi via Google, mendaftarkan akun baru dengan peran `warga` ke database Laravel, dan masuk ke Dashboard Warga. | Pengguna berhasil terdaftar dengan email yang dimasukkan, role diset sebagai `warga`, dan masuk ke Dashboard Warga. | Ya |

##### UAT_WR_04: Login Warga via Google Sign-In (Sesi Aktif)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_04** | Memverifikasi bahwa Warga yang telah terdaftar dapat masuk kembali secara otomatis melalui token sesi tersimpan. | 1. Tutup aplikasi SIBAPAK sepenuhnya.<br>2. Buka kembali aplikasi.<br>3. Amati apakah sistem langsung mengarahkan ke beranda tanpa login ulang. | Pembukaan kembali aplikasi | Aplikasi mendeteksi token Bearer yang valid di penyimpanan lokal (`GetStorage`) dan langsung menampilkan Dashboard Warga tanpa meminta login kembali. | Sesi login tetap aktif melalui token `GetStorage`, pengguna langsung masuk ke halaman utama Dashboard Warga. | Ya |

#### 1.1.3 Fitur Manajemen Profil Warga (Wilayah Pekanbaru)
Langkah pengujian untuk memvalidasi kelengkapan profil, pemilihan wilayah administratif Pekanbaru secara dinamis, dan pembatasan NIK 16 digit.

##### UAT_WR_05: Deteksi Kelengkapan Profil (Warning Card)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_05** | Memverifikasi adanya deteksi visual berupa kartu peringatan jika data profil warga belum lengkap. | 1. Login menggunakan akun Warga baru yang baru saja didaftarkan.<br>2. Masuk ke halaman beranda/dashboard utama. | Akun Warga Baru:<br>`budi.pekanbaru@gmail.com` | Muncul kartu peringatan (Warning Card) berwarna biru gelap bertuliskan **"Profil Belum Lengkap"** disertai tombol tindakan **"Lengkapi Sekarang"**. | Kartu peringatan "Profil Belum Lengkap" muncul di bagian atas halaman beranda dengan tombol tindakan berwarna kontras. | Ya |

##### UAT_WR_06: Pengisian Data Profil Warga (Wilayah Pekanbaru)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_06** | Memverifikasi pengisian wilayah domisili Pekanbaru menggunakan Cascading Dropdown yang dinamis. | 1. Ketuk tombol **Lengkapi Sekarang** pada kartu peringatan.<br>2. Pilih Kabupaten/Kota.<br>3. Pilih Kecamatan.<br>4. Pilih Kelurahan.<br>5. Isi alamat tempat tinggal, lalu ketuk **Simpan Perubahan**. | - Kabupaten: `Kota Pekanbaru`<br>- Kecamatan: `Marpoyan Damai`<br>- Kelurahan: `Tangkerang Barat`<br>- Alamat: `Jl. Arifin Ahmad No. 12, RT 01/RW 04` | Pilihan kecamatan menyaring otomatis daerah di bawah Pekanbaru. Pilihan kelurahan menyaring otomatis wilayah di bawah Marpoyan Damai. Data tersimpan di server Laravel dan kartu peringatan di beranda hilang. | Dropdown wilayah berjalan secara berurutan dan dinamis, data tersimpan di database, dan kartu peringatan otomatis hilang. | Ya |

##### UAT_WR_07: Validasi Keamanan Kolom NIK (Tepat 16 Digit)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_07** | Memvalidasi input NIK warga harus berupa angka dan wajib tepat berjumlah 16 digit. | 1. Ketik huruf atau spasi pada kolom NIK.<br>2. Masukkan NIK kurang dari 16 digit.<br>3. Ketuk tombol **Simpan**. | NIK:<br>`147101120395A` (kurang dari 16 digit & mengandung huruf) | Karakter huruf `A` tertolak otomatis (hanya menerima angka). Saat disimpan, muncul snackbar error: **"NIK wajib 16 digit angka!"** dan data ditolak oleh sistem. | Karakter non-angka tidak dapat diketik, dan muncul snackbar kesalahan yang membatalkan penyimpanan data. | Ya |

##### UAT_WR_08: Perbaruan Foto Profil & Nomor Telepon Warga
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_08** | Memverifikasi pembaruan foto profil melalui unggahan berkas galeri dan nomor telepon warga. | 1. Buka halaman Edit Profil.<br>2. Ketuk ikon kamera, pilih foto dari galeri.<br>3. Ubah nomor telepon.<br>4. Ketuk **Simpan**. | - Foto: `avatar_budi.png` (1.2 MB)<br>- No HP: `081266778899` | Menampilkan indikator loading saat proses kirim berkas, foto profil berubah secara instan pada halaman profil utama pasca-penyimpanan berhasil. | Berkas foto terunggah via Multipart, nomor HP ter-update di database, dan visual profil langsung diperbarui. | Ya |

##### UAT_WR_09: Validasi Peniadaan Ubah Password Lokal & Logout Aman
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_09** | Memverifikasi tidak adanya form ubah password lokal (karena SSO Google) serta fungsi logout yang membersihkan sesi. | 1. Periksa seluruh bagian halaman Edit Profil.<br>2. Kembali ke halaman profil utama, ketuk tombol **Logout**. | Klik tombol **Logout** | Form ubah password ditiadakan di halaman edit profil. Setelah logout, token sesi terhapus dari `GetStorage` dan masuk ke halaman Welcome. | Tidak ditemukan kolom password pada form profil. Sesi terhapus bersih dan aplikasi kembali ke halaman Welcome. | Ya |

#### 1.1.4 Fitur Pengajuan Pengaduan Baru
Langkah pengujian untuk memvalidasi proses pengajuan laporan hukum warga, validasi berkas, penomoran tiket aduan, filter daftar, dan pembatalan kasus.

##### UAT_WR_10: Akses & Responsivitas Formulir Pengaduan (Tablet vs Mobile Layout)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_10** | Memastikan tata letak formulir pengaduan responsif dan nyaman digunakan di HP maupun tablet. | 1. Buka menu **Buat Pengaduan**.<br>2. Perhatikan tata letak elemen input pada layar HP dan tablet. | Akses menu Buat Pengaduan | Tampilan form ter-constraint dengan lebar maksimal `650.0` dan rata tengah di tablet, input tidak menjadi terlalu melar atau gepeng. | Tampilan form adaptif dengan lebar maksimal 650.0 di tablet dan terstruktur rapi pada ponsel. | Ya |

##### UAT_WR_11: Indikator Progress Pengisian Form (Progress Bar)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_11** | Memastikan bilah indikator kemajuan (progress bar) bertambah secara reaktif saat kolom diisi. | 1. Masuk ke formulir pengaduan.<br>2. Isi kolom input satu per satu secara berurutan. | Mengisi data kronologi, wilayah, dll | Progress bar di bagian atas layar bertambah secara dinamis (contoh visual: `1/9 Lengkap` berubah bertahap hingga `9/9 Lengkap`). | Progress bar bertambah reaktif seiring bertambahnya jumlah input yang terisi dengan benar. | Ya |

##### UAT_WR_12: Input Tanggal & Waktu Kejadian (Date & Time Picker)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_12** | Memverifikasi pengisian tanggal dan waktu kejadian perkara hukum menggunakan dialog pemilih bawaan. | 1. Ketuk kolom input **Tanggal Kejadian**.<br>2. Ketuk kolom input **Waktu Kejadian**. | - Tanggal: `12 Juli 2026`<br>- Waktu: `10:30 WIB` | Sistem menampilkan dialog kalender dan jam bawaan Flutter. Nilai yang dipilih terformat secara rapi ke dalam kolom input. | Dialog kalender dan jam tampil responsif, data terformat dengan format tanggal/waktu Indonesia. | Ya |

##### UAT_WR_13: Input Jenis Masalah (Bottom Sheet Modal)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_13** | Memverifikasi pemilihan jenis masalah hukum melalui modal bottom sheet. | 1. Ketuk kolom input **Jenis Masalah**. | Memilih opsi:<br>`"Sengketa Tanah / Waris"` | Terbuka bottom sheet modal yang menampilkan daftar kategori hukum. Pilihan radio button berfungsi reaktif dan memindahkan data ke input form. | Bottom sheet terbuka di bagian bawah, radio button berfungsi normal, jenis masalah terpilih tampil di form. | Ya |

##### UAT_WR_14: Pemuatan Berkas Bukti Awal (File Picker Dokumen PDF & Gambar)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_14** | Memvalidasi pemilihan berkas lampiran bukti awal dan pembatasan ukuran berkas maksimal 5 MB. | 1. Ketuk **Pilih Berkas**.<br>2. Pilih berkas pertama (< 5 MB).<br>3. Pilih berkas kedua (> 5 MB). | - Berkas 1: `sertifikat.pdf` (2.4 MB)<br>- Berkas 2: `video_kejadian.mp4` (12 MB) | Berkas 1 berhasil dilampirkan ke daftar. Berkas 2 ditolak otomatis dan memicu snackbar peringatan ukuran berkas maksimal 5 MB. | Berkas berukuran kecil dilampirkan, berkas di atas 5 MB memicu pesan error snackbar dan otomatis diabaikan. | Ya |

##### UAT_WR_15: Pengiriman Formulir Pengaduan & Halaman Sukses
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_15** | Memverifikasi pengiriman formulir pengaduan (Multipart Request) dan penampilan halaman sukses beserta ID pengaduan. | 1. Pastikan progress pengisian `9/9 Lengkap`.<br>2. Ketuk tombol **Kirim Pengaduan**. | Data teks input & berkas bukti awal | Indikator loading aktif. Setelah pengiriman selesai, pengguna diarahkan ke Halaman Sukses dengan ID pengaduan terformat (contoh: `PGN-2026-00045`). | Formulir sukses dikirim via Multipart, masuk ke halaman sukses, dan menampilkan kode tiket pengaduan yang valid. | Ya |

##### UAT_WR_16: Fitur Salin ID Tiket & Navigasi ke Detail Kasus
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_16** | Memverifikasi penyalinan ID tiket pengaduan ke clipboard dan navigasi langsung ke halaman detail. | 1. Ketuk area teks ID Pengaduan pada halaman sukses.<br>2. Ketuk tombol **Lihat Detail Pengaduan**. | Klik salin ID & Klik lihat detail | Muncul notifikasi pop-up *"ID Pengaduan disalin"*. Aplikasi berpindah ke halaman Detail Kasus warga menggunakan UUID. | Teks tersalin ke clipboard sistem, navigasi berhasil masuk ke detail pengaduan yang bersangkutan. | Ya |

##### UAT_WR_17: Filter, Pencarian, & Pull-to-Refresh pada Daftar Kasus Warga
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_17** | Memverifikasi fitur pencarian, filter kategori tab status, dan penarikan layar untuk menyegarkan data. | 1. Masuk ke halaman **Pengaduan Saya**.<br>2. Ketik kata kunci di kolom pencarian.<br>3. Pilih tab "Proses" atau "Selesai".<br>4. Lakukan tarik layar ke bawah. | - Kata Kunci: `Sengketa`<br>- Tab: `Proses`<br>- Aksi: Pull-to-refresh | Daftar terfilter instan sesuai kata kunci dan tab status. Pull-to-refresh memicu animasi putar loading dan memuat data terupdate dari database. | Pencarian dan filter bekerja reaktif, pull-to-refresh berhasil mengambil data kasus terbaru dari backend Laravel. | Ya |

##### UAT_WR_18: Fitur Pembatalan Pengaduan Mandiri oleh Warga
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_18** | Memverifikasi pembatalan pengaduan yang belum ditangani oleh paralegal (masih berstatus 'menunggu'). | 1. Buka detail pengaduan berstatus **Menunggu**.<br>2. Ketuk tombol **Batalkan Pengaduan**.<br>3. Ketuk **Ya** pada dialog konfirmasi. | Klik konfirmasi pembatalan | Status kasus berubah menjadi "dibatalkan", linimasa/timeline bertambah poin *"Pengaduan Dibatalkan"*, dan tombol batal menghilang. | Pengaduan berhasil dibatalkan di server, timeline ter-update, dan tombol aksi pembatalan dinonaktifkan di UI. | Ya |

#### 1.1.5 Fitur Chat Realtime (POV Warga)
Langkah pengujian untuk memvalidasi interaksi obrolan dua arah antara warga dengan pendamping hukum, pengiriman berkas, dan visual gelembung chat.

##### UAT_WR_19: Akses Ruang Obrolan Pendamping Hukum
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_19** | Memverifikasi akses warga masuk ke ruang obrolan pendamping hukum pada kasus aktif. | 1. Masuk ke detail pengaduan aktif berstatus **Diproses**.<br>2. Ketuk tombol **Hubungi Pendamping / Paralegal**. | Klik hubungi pendamping | Ruang obrolan terbuka, header menampilkan nama paralegal pendamping secara dinamis, dan riwayat obrolan termuat. | Halaman chat terbuka sukses, memuat nama pendamping secara dinamis ("Andi Setiawan, S.H.") beserta riwayat chat. | Ya |

##### UAT_WR_20: Pengiriman Pesan & Tata Letak Bubble Obrolan (WhatsApp Style)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_20** | Memverifikasi pengiriman pesan chat teks dan perataan gelembung chat (bubble chat). | 1. Ketik pesan teks pada input obrolan.<br>2. Tekan tombol kirim. | Pesan:<br>`"Halo Pak Andi, bagaimana kelanjutan laporan sengketa lahan saya?"` | Pesan terkirim ke server Laravel. Bubble chat warga (pengirim) berada di sisi kanan dengan warna gelap, posisi jam merapat di kanan bawah. | Pesan sukses terkirim, gelembung chat berada di kanan, format jam di kanan bawah berjalan sesuai standar WhatsApp. | Ya |

##### UAT_WR_21: Penerimaan Pesan via Polling Real-time & Auto-Scroll
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_21** | Memverifikasi penerimaan pesan baru secara berkala (polling 3 detik) tanpa refresh manual serta auto-scroll halaman chat. | 1. Biarkan layar chat tetap terbuka.<br>2. Terima pesan masuk dari akun paralegal pendamping. | Pesan masuk dari paralegal | Pesan dari paralegal otomatis muncul di layar HP warga maksimal 3 detik setelah dikirim, berada di sisi kiri (putih), dan layar otomatis scroll ke bawah. | Pesan baru diterima secara real-time via polling 3 detik, posisi berada di kiri, dan layar melakukan auto-scroll ke bawah. | Ya |

##### UAT_WR_22: Pengiriman & Pratinjau Lampiran Dokumen/Gambar Chat
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_22** | Memverifikasi pengiriman media berkas (PDF/Gambar) di ruang chat dan pratinjau gambarnya. | 1. Ketuk tombol (+), pilih gambar.<br>2. Ketuk tombol (+), pilih berkas PDF.<br>3. Kirim dan buka berkas yang dikirim. | Berkas gambar:<br>`bukti_tambahan.jpg` (1.5 MB) | Berkas terunggah via Multipart ke `/pengaduan/{id}/lampiran`. Gambar dapat ditap untuk pratinjau fullscreen zoom. PDF terbuka via In-App PDF Viewer. | Berkas terunggah lancar, gambar terbuka fullscreen dengan cubit-zoom, PDF terbuka pada pemutar internal. | Ya |

##### UAT_WR_23: Akses Halaman Informasi Posbankum Pendamping
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_23** | Memverifikasi akses ke halaman informasi detail Posbankum dari ruang obrolan warga. | 1. Masuk ke ruang chat warga.<br>2. Ketuk ikon menu/info di kanan atas header. | Klik ikon info chat | Menampilkan halaman Info Chat Posbankum berisi nama Posbankum Kelurahan, kontak telepon, alamat fisik, peta lokasi, dan jadwal layanan. | Masuk ke halaman Info Chat Posbankum, rincian kantor Posbankum pembina tampil lengkap dan valid. | Ya |

#### 1.1.6 Fitur Penerimaan Notifikasi Pop-up (POV Warga)
Langkah pengujian untuk memverifikasi fungsionalitas penerimaan notifikasi sistem dan push notification secara real-time pada gawai warga.

##### UAT_WR_24: Penerimaan Pop-up Banner Notifikasi Pembaruan Status Kasus
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_24** | Memverifikasi penerimaan notifikasi pop-up melayang (in-app banner) saat ada pembaruan status kasus oleh paralegal. | 1. Buka aplikasi warga di layar beranda.<br>2. Ubah status kasus menjadi "Diproses" dari akun paralegal. | Aksi ubah status dari paralegal | Banner notifikasi in-app melayang muncul secara real-time di bagian atas layar HP warga menginformasikan perubahan status pengaduan. | Notifikasi pop-up muncul di atas layar beranda mengabarkan bahwa status kasus warga telah diperbarui oleh paralegal. | Ya |

##### UAT_WR_25: Penerimaan Pop-up Banner Notifikasi Pesan Chat Baru
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_25** | Memverifikasi penerimaan notifikasi dengan suara kustom saat ada pesan chat masuk ketika aplikasi di background. | 1. Tekan tombol home (aplikasi berada di background).<br>2. Kirim pesan chat dari akun paralegal.<br>3. Perhatikan bilah status HP warga. | Pesan chat masuk dari paralegal | Banner notifikasi muncul di bilah status HP, berbunyi dengan suara kustom (`notif_sound.mp3`). Ketika ditap, aplikasi terbuka mengarah ke ruang chat. | Notifikasi bar muncul disertai suara kustom yang terkonfigurasi, ketika ditap langsung membuka ruang obrolan terkait. | Ya |

---

### 1.2 Pengujian Aktor Paralegal (Pendamping Hukum)
Aktor Paralegal bertindak sebagai pelaksana di lapangan yang bertugas mengklaim kasus sewilayah tugas, memperbarui progress, berkonsultasi via chat, mengirimkan laporan kegiatan lapangan, serta menerima notifikasi persetujuan kegiatan dari admin.

#### 1.2.1 Fitur Login dan Autentikasi
Langkah pengujian untuk memverifikasi proses masuk paralegal menggunakan email penugasan resmi melalui Google Sign-In.

##### UAT_PL_01: Login Paralegal via Google Sign-In (Pencocokan Email Terdaftar)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_01** | Memverifikasi login akun Paralegal menggunakan Single Sign-On (SSO) Google berdasarkan email terdaftar. | 1. Pada halaman masuk, ketuk **Masuk dengan Google**.<br>2. Pilih akun Google paralegal yang telah didaftarkan oleh admin di website. | Akun Google:<br>`paralegal.andi@posbankum.org` | Sistem mendeteksi email tersebut terdaftar sebagai paralegal, mengarahkan login berhasil, dan menampilkan Dashboard Utama Paralegal. | Login berhasil, sistem mengenali peran sebagai paralegal berdasarkan email, lalu masuk ke Dashboard Utama Paralegal. | Ya |

#### 1.2.2 Fitur Manajemen Profil Paralegal
Langkah pengujian untuk mengubah nomor telepon, foto profil paralegal, serta memvalidasi ketiadaan kolom password lokal.

##### UAT_PL_02: Perbaruan Foto Profil & Nomor Telepon Paralegal
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_02** | Memverifikasi pembaruan foto profil via unggahan kamera dan nomor telepon pada akun paralegal. | 1. Masuk ke menu Edit Profil paralegal.<br>2. Ketuk ikon kamera, potret foto baru.<br>3. Ganti nomor telepon.<br>4. Ketuk **Simpan**. | - Foto baru: `profile_andi.jpg` (2.1 MB)<br>- No HP: `081223344556` | Proses upload berjalan lancar, berkas cover/profil terunggah ke database Laravel, data profil utama paralegal ter-update instan. | Foto hasil potret kamera terunggah sukses, nomor telepon tersimpan, profil utama paralegal ter-update. | Ya |

##### UAT_PL_03: Peniadaan Modul Password Lokal & Logout Aman
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_03** | Memverifikasi tidak adanya opsi password lokal untuk paralegal dan tombol logout berfungsi aman. | 1. Periksa form edit profil paralegal.<br>2. Masuk ke halaman profil utama, ketuk tombol **Logout**. | Klik tombol **Logout** | Form ubah password ditiadakan. Setelah logout, sesi Bearer token dibersihkan dari penyimpanan lokal (`GetStorage`) dan kembali ke halaman Welcome. | Opsi password tidak ditemukan pada form. Logout berhasil menghapus sesi token dan kembali ke halaman Welcome. | Ya |

#### 1.2.3 Fitur Klaim Pengaduan Warga
Langkah pengujian untuk memverifikasi penyaringan wilayah tugas kelurahan, pengurutan skala prioritas kasus, lazy loading, dan pengambilan kasus (claim case).

##### UAT_PL_04: Sinkronisasi Wilayah Tugas (Filter Otomatis)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_04** | Memastikan daftar kasus yang masuk di dashboard paralegal terfilter otomatis hanya dari wilayah kelurahan tugasnya. | 1. Login menggunakan akun paralegal wilayah kelurahan Tangkerang Barat.<br>2. Periksa detail asal wilayah pengaduan di daftar kasus masuk. | Akun Paralegal Kelurahan Tangkerang Barat | Daftar kasus masuk hanya menampilkan laporan sengketa/pengaduan hukum dari warga yang berdomisili di Kelurahan Tangkerang Barat. | Semua laporan kasus yang tampil pada daftar kasus masuk berasal dari domisili Kelurahan Tangkerang Barat. | Ya |

##### UAT_PL_05: Pengurutan Kasus Berdasarkan Urgensi (Priority Queue)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_05** | Memverifikasi daftar kasus terurut secara otomatis berdasarkan bobot urgensi tertinggi menggunakan struktur *Priority Queue*. | 1. Masuk ke halaman utama list kasus masuk.<br>2. Perhatikan urutan daftar dari atas ke bawah. | Urutan daftar kasus | Kasus dengan tingkat prioritas "Sangat Tinggi" (misal: Kejahatan Seksual/Kekerasan Fisik) berada paling atas, diikuti prioritas "Tinggi", "Sedang", dan "Rendah". | Urutan kasus secara otomatis menampilkan kasus dengan tag urgensi "Sangat Tinggi" di baris pertama daftar kasus. | Ya |

##### UAT_PL_06: Visualisasi Tingkat Prioritas & Status Kasus pada Dashboard
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_06** | Memverifikasi kejelasan visual tag prioritas dan badge status kasus pada dashboard paralegal. | 1. Periksa label visual kartu kasus pada dashboard.<br>2. Periksa menu riwayat penanganan. | Tampilan kartu kasus | Tag prioritas memiliki kode warna kontras (Merah: Sangat Tinggi, Kuning: Sedang). Warna badge status aduan selaras di dashboard dan riwayat. | Tag prioritas dan badge status ter-render dengan warna yang kontras serta konsisten di seluruh halaman aplikasi. | Ya |

##### UAT_PL_07: Paginasi & Lazy Loading pada Daftar Kasus Masuk
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_07** | Memverifikasi pemuatan data kasus bertahap (lazy loading) ketika daftar digulirkan ke bawah. | 1. Lakukan scroll secara terus-menerus ke bawah pada daftar kasus masuk. | *Gesture* gulir bawah (Scroll Down) | Ketika mencapai batas bawah halaman pertama, muncul animasi loading kecil, lalu sistem memuat kasus halaman berikutnya tanpa lag. | Paginasi halaman terpicu saat scroll mencapai batas akhir, memuat data halaman berikutnya dengan lancar. | Ya |

##### UAT_PL_08: Proses Klaim Kasus (Ambil Alih Penanganan Kasus)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_08** | Memverifikasi proses pengambilan kasus berstatus "Menunggu" oleh paralegal sewilayah. | 1. Pilih kasus berstatus **Menunggu**.<br>2. Ketuk tombol **Ambil Kasus**.<br>3. Konfirmasi pilihan **Ya** pada dialog GetX. | Klik ambil kasus & Klik Ya | Status kasus berubah menjadi "diproses" di server Laravel, mencatat `id_paralegal`, dan dashboard paralegal terupdate instan. | Dialog konfirmasi sukses muncul, status berubah menjadi diproses, dan kasus pindah ke tab kasus aktif milik paralegal. | Ya |

#### 1.2.4 Fitur Update Status & Progres Kasus
Langkah pengujian untuk memvalidasi pembaruan progress penanganan kasus, unggahan berkas multipart, sinkronisasi linimasa warga, in-app PDF viewer, dan penyelesaian formal kasus.

##### UAT_PL_09: Formulir Update Progres Kasus (Multipart Request)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_09** | Memverifikasi pengisian laporan progres penanganan kasus disertai berkas lampiran. | 1. Buka kasus aktif, ketuk **Update Progres**.<br>2. Isi catatan progres.<br>3. Pilih berkas lampiran pendukung.<br>4. Ketuk **Kirim**. | - Catatan:<br>`"Menyerahkan berkas gugatan sengketa ke Pengadilan Negeri Pekanbaru"`<br>- File: `tanda_terima.pdf` (1.1 MB) | Data terkirim secara Multipart ke backend Laravel, status ter-update, dan paralegal diarahkan kembali ke detail dengan progres baru tercatat di linimasa. | Data terkirim sukses, progres baru berhasil tersimpan ke tabel `pengaduan_timeline` dan ter-render di detail kasus. | Ya |

##### UAT_PL_10: Sinkronisasi Pembaruan Riwayat Kasus pada Linimasa Warga
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_10** | Memverifikasi sinkronisasi otomatis riwayat penanganan kasus ke layar linimasa (timeline) warga pelapor. | 1. Login kembali menggunakan akun warga pelapor.<br>2. Buka detail pengaduan sengketa lahan terkait.<br>3. Periksa bagian linimasa kasus. | Akses riwayat linimasa warga | Poin histori linimasa warga bertambah secara otomatis memuat teks catatan progres yang dimasukkan paralegal pada langkah UAT_PL_09. | Poin linimasa baru bermuatan catatan penyerahan berkas pengadilan muncul di layar warga, sinkron secara real-time. | Ya |

##### UAT_PL_11: Fitur Pembukaan Berkas Lampiran Awal (In-App PDF Viewer & Zoom)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_11** | Memverifikasi pembukaan berkas bukti awal warga oleh paralegal (gambar & PDF). | 1. Buka detail kasus.<br>2. Ketuk berkas bukti berformat gambar.<br>3. Ketuk berkas bukti berformat PDF. | Klik lampiran berkas | Gambar terbuka layar penuh dan dapat dicubit-zoom. Berkas PDF terunduh aman ke cache lokal dan terbuka di penampil PDF internal. | Penampil gambar fullscreen dan In-App PDF Viewer berjalan lancar tanpa tabrakan dengan tombol navigasi sistem HP. | Ya |

##### UAT_PL_12: Penyelesaian Kasus Secara Formal (Status Selesai / Dibatalkan dengan Catatan)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_12** | Memverifikasi proses penutupan kasus secara formal disertai pengisian catatan penutupan kasus. | 1. Pada detail kasus aktif, ketuk **Selesaikan Kasus**.<br>2. Pilih opsi status Selesai.<br>3. Isi catatan penutupan kasus, ketuk **Konfirmasi**. | - Opsi: `Selesai`<br>- Catatan:<br>`"Kasus sengketa diselesaikan melalui mediasi kekeluargaan dan terlapor setuju membongkar bangunan secara sukarela."` | Status kasus di server berubah menjadi "selesai", tercatat di linimasa penutupan, dan seluruh form aksi penanganan dinonaktifkan. | Kasus berhasil diselesaikan, status terupdate di backend Laravel, form aksi penanganan menghilang dari UI. | Ya |

#### 1.2.5 Fitur Chat Realtime (POV Paralegal)
Langkah pengujian untuk memvalidasi interaksi obrolan dari sisi paralegal, indikator pesan belum dibaca, halaman info klien, dan pertukaran berkas media.

##### UAT_PL_13: Akses Ruang Obrolan dengan Klien (Warga)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_13** | Memverifikasi akses paralegal masuk ke ruang obrolan warga pelapor. | 1. Buka halaman detail kasus aktif milik paralegal.<br>2. Ketuk tombol **Chat Warga**. | Klik tombol chat warga | Ruang obrolan terbuka, header menampilkan nama warga secara dinamis, dan riwayat obrolan terdahulu termuat. | Chat room terbuka sukses, menampilkan nama klien "Budi" di header secara dinamis. | Ya |

##### UAT_PL_14: Pengiriman & Tata Letak Bubble Obrolan Pendamping Hukum
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_14** | Memverifikasi pengiriman pesan chat balasan dan visual gelembung chat paralegal. | 1. Ketik pesan balasan pada input obrolan.<br>2. Tekan tombol kirim. | Pesan:<br>`"Selamat pagi Pak Budi, berkas gugatan sedang kami susun dan akan didaftarkan ke Pengadilan Negeri Pekanbaru besok."` | Pesan sukses terkirim, gelembung chat berada di sisi kanan (bubble gelap), jam pesan merapat rapi di kanan bawah teks. | Pesan berhasil dikirim, visual gelembung chat berada di kanan, format jam di kanan bawah bubble. | Ya |

##### UAT_PL_15: Penerimaan Pesan via Polling Real-time & Auto-Scroll
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Official Result / Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_15** | Memverifikasi penerimaan pesan dari warga via polling 3 detik dan auto-scroll halaman chat paralegal. | 1. Biarkan layar chat paralegal tetap terbuka.<br>2. Terima pesan baru dari akun warga. | Pesan masuk dari warga | Pesan dari warga otomatis muncul di layar HP paralegal maksimal 3 detik setelah dikirim, di sisi kiri (putih), layar otomatis scroll ke bawah. | Pesan masuk ter-render otomatis dalam 3 detik di sisi kiri, auto-scroll berjalan lancar. | Ya |

##### UAT_PL_16: Indikator Pesan Belum Dibaca (Garis Biru 4px & Badge Bulat Biru)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_16** | Memverifikasi indikator visual pesan belum dibaca pada daftar chat aktif milik paralegal. | 1. Kirim pesan dari akun warga saat akun paralegal berada di halaman daftar chat aktif. | Pesan baru belum dibaca masuk | Item chat warga memunculkan garis biru setebal 4px di sisi kiri kartu, jam pesan berwarna biru, dan menampilkan badge bulat jumlah pesan baru. | Visual indikator pesan belum dibaca muncul dengan garis biru 4px, jam biru, dan badge angka notifikasi. | Ya |

##### UAT_PL_17: Pengiriman & Pembukaan Lampiran Media/PDF pada Chat
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_17** | Memverifikasi pengiriman file dokumen PDF/gambar melalui chat dan pembukaan berkasnya. | 1. Ketuk tombol (+), pilih berkas PDF.<br>2. Kirim dan buka berkas tersebut. | Berkas dokumen:<br>`draft_surat_kuasa.pdf` (850 KB) | Berkas terkirim dengan format khusus. Dokumen PDF terunduh aman via header secure token (tidak terhalang 401 redirect) dan terbuka di viewer internal. | Berkas terkirim lancar, PDF dapat dibuka melalui In-App PDF Viewer dengan aman. | Ya |

##### UAT_PL_18: Akses Halaman Informasi Detail Klien (Warga)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_18** | Memverifikasi akses halaman rincian informasi detail warga dari ruang obrolan paralegal. | 1. Buka ruang chat paralegal.<br>2. Ketuk ikon menu/info di kanan atas header. | Klik ikon info chat | Menampilkan halaman Info Chat Warga yang berisi NIK klien, nama lengkap, email, nomor HP, dan alamat detail domisili warga pelapor. | Masuk ke halaman Info Chat Warga, rincian data diri warga pelapor termuat dengan lengkap dan rapi. | Ya |

#### 1.6 Fitur Pengiriman Laporan Kegiatan Lapangan (Penyuluhan / Sosialisasi)
Langkah pengujian untuk memvalidasi pembuatan laporan kegiatan, filter pencarian, edit/update data, bagikan detail (PDF/Teks), dan penampilan alasan penolakan.

##### UAT_PL_19: Akses Halaman Kelola Kegiatan Lapangan (Responsif)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_19** | Memverifikasi navigasi masuk dan tata letak halaman Kelola Kegiatan Lapangan yang responsif. | 1. Buka tab/menu **Kegiatan** pada aplikasi paralegal.<br>2. Perhatikan tata letak halaman pada HP dan tablet. | Akses menu kegiatan | Masuk ke halaman Kelola Kegiatan dengan header melengkung berlatar gambar gedung, layout ter-constraint maksimal `650.0` pada layar lebar/tablet. | Halaman Kelola Kegiatan berhasil diakses, struktur layout ter-constraint di tablet dan rapi di ponsel. | Ya |

##### UAT_PL_20: Pencarian & Filter Kegiatan Berdasarkan Rentang Tanggal
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_20** | Memverifikasi penyaringan daftar kegiatan berdasarkan pencarian kata kunci dan filter kalender tanggal. | 1. Ketik kata kunci pada search bar.<br>2. Ketuk tombol filter kalender, pilih tanggal pelaksanaan. | - Kata Kunci: `Penyuluhan`<br>- Tanggal: `15 Juli 2026` | Daftar kegiatan menyaring secara instan berdasarkan judul/lokasi, judul daftar berubah format menjadi "DAFTAR KEGIATAN: JULI 2026". | Hasil pencarian dan filter tanggal menyaring daftar secara instan dengan judul bulanan ter-update. | Ya |

##### UAT_PL_21: Pembuatan Laporan Kegiatan Baru (Camera Cover Picker)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_21** | Memverifikasi pembuatan laporan kegiatan baru dengan upload gambar via kamera/galeri dan input reaktif. | 1. Ketuk **Mulai buat Laporan kegiatan**.<br>2. Isi form kegiatan (judul, tgl mulai/selesai, lokasi, deskripsi, hasil kegiatan pada input text area).<br>3. Ketuk unggah cover kegiatan, pilih foto via kamera HP.<br>4. Ketuk **Simpan Kegiatan** (tombol berwarna biru tua `0xFF2A2E5E`). | - Judul: `"Penyuluhan Hukum Kesadaran Pertanahan RT 02 Tangkerang"`<br>- Tanggal: `15 Juli 2026`<br>- Lokasi: `Balai Desa Kelurahan Tangkerang Barat`<br>- Deskripsi: `"Sosialisasi hukum pertanahan dan pencegahan sertifikat ganda."`<br>- Hasil Kegiatan: `"Meningkatnya pemahaman warga RT 02 mengenai sertifikat tanah resmi."`<br>- Foto Cover: Potret kamera langsung (`foto_kegiatan.jpg`, 3.2 MB) | Validasi mewajibkan seluruh input terisi. Field jumlah peserta dan anggota tim ditiadakan (nama pelapor auto-filled). Data terunggah via Multipart ke server Laravel, status awal kegiatan diset ke **MENUNGGU**. | Form tervalidasi dengan baik, foto berhasil dipotret dan diunggah, data tersimpan dengan status awal "MENUNGGU". | Ya |

##### UAT_PL_22: Tampilan Detail Laporan Kegiatan Lapangan
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_22** | Memverifikasi rincian data laporan kegiatan lapangan yang telah dibuat. | 1. Ketuk salah satu kegiatan di daftar kegiatan. | Klik item kegiatan | Menampilkan detail rapi: cover foto (HTTPS ter-normalisasi), nama Posbankum dan wilayah regional penugasan ("Posbankum Kel. Tangkerang Barat • Marpoyan Damai, Pekanbaru"), status kegiatan, tanggal, lokasi, nama pelapor, deskripsi, dan hasil kegiatan. | Rincian kegiatan tampil lengkap dan detail posbankum regional termuat dengan baik. | Ya |

##### UAT_PL_23: Pengeditan Laporan Kegiatan (Status Reset ke MENUNGGU)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_23** | Memverifikasi pengeditan data laporan kegiatan yang berstatus "MENUNGGU". | 1. Di detail kegiatan, ketuk **Edit Kegiatan**.<br>2. Ubah hasil kegiatan pada input text area.<br>3. Ketuk **Simpan Kegiatan** (tombol berwarna biru tua `0xFF2A2E5E`). | - Perubahan hasil kegiatan: `"Meningkatnya pemahaman warga RT 02 mengenai sertifikat tanah resmi serta pencegahan sengketa waris."` | Form menampilkan data awal di header melengkung, data ter-update di server Laravel, dan status reset kembali ke "MENUNGGU" untuk persetujuan ulang admin. | Perubahan berhasil disimpan, status kegiatan di server kembali ke "MENUNGGU". | Ya |

##### UAT_PL_24: Bagikan Detail Kegiatan (PDF/Teks)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_24** | Memverifikasi fitur pembagian detail laporan kegiatan baik dalam bentuk ringkasan teks maupun berkas dokumen PDF. | 1. Buka detail kegiatan.<br>2. Ketuk **Bagikan Detail**.<br>3. Ketuk **Bagikan Teks**.<br>4. Ketuk **Bagikan Gambar PDF**. | Klik tombol Bagikan Detail | Sistem berhasil membagikan ringkasan teks ke media sosial/chat lain, dan berhasil mencetak detail kegiatan menjadi berkas PDF ukuran A4 untuk dibagikan. | Opsi bagikan teks dan konversi detail kegiatan menjadi file PDF berjalan lancar tanpa error. | Ya |

##### UAT_PL_25: Penampilan Alasan Penolakan Laporan Kegiatan (Catatan Admin)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_25** | Memverifikasi penampilan kartu catatan penolakan admin jika status laporan kegiatan "DITOLAK". | 1. Buka detail kegiatan yang berstatus **DITOLAK**. | Klik item kegiatan ditolak | Muncul kartu berwarna merah terang bertuliskan **Catatan Admin** yang berisi detail alasan penolakan dari admin website. | Kartu catatan penolakan admin "Catatan Admin: Harap sertakan foto cover yang memperlihatkan audiens secara luas" muncul di bagian bawah detail. | Ya |

#### 1.2.7 Fitur Terima Notifikasi Persetujuan Kegiatan dari Admin (POV Paralegal)
Langkah pengujian untuk memvalidasi penerimaan notifikasi sistem ketika admin menyetujui atau menolak laporan kegiatan lapangan paralegal.

##### UAT_PL_26: Penerimaan Pop-up Banner Notifikasi Persetujuan (Approval) Laporan Kegiatan
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_26** | Memverifikasi penerimaan notifikasi pop-up melayang di aplikasi ketika laporan kegiatan disetujui oleh admin via website. | 1. Buka aplikasi paralegal di layar beranda.<br>2. Ubah status kegiatan menjadi disetujui di panel admin website SIBAPAK. | Persetujuan kegiatan dari admin | Muncul pop-up banner notifikasi in-app di bagian atas layar mengabarkan bahwa kegiatan "Penyuluhan Hukum..." telah disetujui. | Notifikasi pop-up in-app muncul di atas layar mengabarkan laporan disetujui. | Ya |

##### UAT_PL_27: Penerimaan Pop-up Banner Notifikasi Penolakan Laporan Kegiatan dengan Catatan
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh (Actual Result) | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_27** | Memverifikasi penerimaan notifikasi in-app ketika kegiatan ditolak admin beserta link navigasi cepat ke catatan penolakan. | 1. Buka aplikasi paralegal.<br>2. Ubah status kegiatan menjadi ditolak di panel admin website SIBAPAK.<br>3. Ketuk notifikasi tersebut. | Penolakan kegiatan dari admin | Muncul notifikasi banner penolakan kegiatan. Saat ditap, aplikasi langsung berpindah (deep link) ke halaman Detail Rincian Kegiatan tersebut untuk membaca catatan admin. | Notifikasi banner penolakan muncul, ditap langsung mengarah ke halaman detail rincian kegiatan terkait. | Ya |

---

## 2. REKAPITULASI HASIL UAT
Berdasarkan hasil pengujian yang dilakukan pada kedua peran pengguna (Warga dan Paralegal), rekapitulasi tingkat kelulusan skenario adalah sebagai berikut:

*   **Aktor Warga:**
    *   Jumlah Skenario Uji: **25 Skenario**
    *   Jumlah Lulus (Ya): **25 Skenario**
    *   Jumlah Gagal (Tidak): **0 Skenario**
    *   Tingkat Keberhasilan Warga: **100%**

*   **Aktor Paralegal:**
    *   Jumlah Skenario Uji: **27 Skenario**
    *   Jumlah Lulus (Ya): **27 Skenario**
    *   Jumlah Gagal (Tidak): **0 Skenario**
    *   Tingkat Keberhasilan Paralegal: **100%**

*   **Total Keseluruhan:**
    *   Total Skenario Uji: **52 Skenario**
    *   Total Lulus: **52 Skenario**
    *   Tingkat Kelulusan Sistem: **100% (Sistem Diterima oleh Pengguna)**

---
**Tanda Tangan Persetujuan UAT:**

| Perwakilan Penguji (Warga) | Perwakilan Paralegal | Koordinator Pengembang SIBAPAK |
| :---: | :---: | :---: |
| | | |
| | | |
| **Budi Santoso**<br>Warga Pekanbaru | **Andi Setiawan, S.H.**<br>Paralegal Lapangan | **[Nama Mahasiswa/User]**<br>NIM. [NIM Anda] |
