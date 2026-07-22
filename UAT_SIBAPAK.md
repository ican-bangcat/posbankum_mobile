# DOKUMEN FORMAL USER ACCEPTANCE TESTING (UAT)
## SISTEM APLIKASI POSBANKUM BERDAMPAK (SIBAPAK) - MODUL MOBILE

---

## DAFTAR ISI

*   **DAFTAR ISI**
*   **LEMBAR PENGESAHAN**
*   **DESKRIPSI DAN HASIL UJI**
    *   **1.1 Pengujian Aktor Warga (Masyarakat Pelapor)**
        *   1.1.1 Fitur Onboarding (Layar Pengenalan)
        *   1.1.2 Fitur Registrasi dan Login Warga
        *   1.1.3 Fitur Manajemen Profil Warga (Wilayah Riau)
        *   1.1.4 Fitur Pengajuan Pengaduan Baru
        *   1.1.5 Fitur Chat Real-time (POV Warga)
        *   1.1.6 Fitur Penerimaan Notifikasi Pop-up (POV Warga)
    *   **1.2 Pengujian Aktor Paralegal (Pendamping Hukum)**
        *   1.2.1 Fitur Login dan Autentikasi
        *   1.2.2 Fitur Manajemen Profil Paralegal
        *   1.2.3 Fitur Klaim Pengaduan Warga
        *   1.2.4 Fitur Update Status & Progres Kasus
        *   1.2.5 Fitur Chat Real-time (POV Paralegal)
        *   1.2.6 Fitur Laporan Kegiatan Lapangan (Penyuluhan / Sosialisasi)
        *   1.2.7 Fitur Terima Notifikasi Persetujuan Kegiatan dari Admin (POV Paralegal)
*   **REKAPITULASI HASIL UAT**

---

## LEMBAR PENGESAHAN

Yang bertanda tangan di bawah ini menyatakan bahwa seluruh skenario pengujian *User Acceptance Testing* (UAT) untuk aplikasi mobile **SIBAPAK (Sistem Aplikasi Posbankum Berdampak)** telah selesai dilaksanakan dengan hasil yang tertera dalam dokumen ini.

| Perwakilan Penguji (Warga) | Perwakilan Paralegal | Koordinator Pengembang SIBAPAK |
| :---: | :---: | :---: |
| | | |
| | | |
| **Dwi Maya Charly**<br>Penguji Warga | **M. Ikhsan Kurniawan**<br>Paralegal Lapangan | **[Nama Mahasiswa]**<br>NIM. [NIM Anda] |

---

## DESKRIPSI DAN HASIL UJI

### 1.1 Pengujian Aktor Warga (Masyarakat Pelapor)
Aktor Warga menggunakan aplikasi untuk melakukan pendaftaran, melengkapi profil wilayah Riau, mengajukan kasus hukum, berkonsultasi via chat real-time dengan Paralegal pendamping, serta menerima notifikasi pembaruan status pengaduan.

#### 1.1.1 Fitur Onboarding (Layar Pengenalan)
Skenario untuk menguji tampilan pengenalan pertama kali aplikasi dibuka.

##### UAT_WR_01: Navigasi Layar Pengenalan (Onboarding Swiping)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_01** | Memastikan pengguna baru dapat menggeser layar intro aplikasi untuk membaca informasi dasar SIBAPAK. | 1. Buka aplikasi SIBAPAK pertama kali.<br>2. Geser layar ke kiri pada halaman onboarding pertama dan kedua. | Geser layar (swipe) ke kiri | Layar bergeser dengan lancar menampilkan informasi slide berikutnya secara berurutan. | Layar onboarding bergeser dengan transisi halus dan menampilkan konten slide berikutnya dengan tepat. | Ya |

##### UAT_WR_02: Aksi Tombol Mulai Aplikasi
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_02** | Memverifikasi tombol "Mulai" pada halaman onboarding terakhir dapat mengarahkan pengguna ke halaman Welcome. | 1. Geser slide onboarding hingga halaman terakhir (slide ketiga).<br>2. Ketuk tombol **Mulai**. | Klik tombol **Mulai** | Aplikasi menutup halaman onboarding dan mengarahkan pengguna ke halaman Welcome/Masuk. | Halaman onboarding ditutup dan pengguna langsung diarahkan masuk ke halaman Welcome. | Ya |

#### 1.1.2 Fitur Registrasi dan Login Warga
Skenario untuk memverifikasi pendaftaran dan login menggunakan akun Google.

##### UAT_WR_03: Registrasi Warga Baru via Google Sign-In
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_03** | Memverifikasi pendaftaran akun Warga baru menggunakan login akun Google. | 1. Pada halaman masuk/daftar, ketuk tombol **Daftar dengan Google**.<br>2. Pilih akun Google baru yang belum pernah terdaftar. | Akun Google:<br>`dwimayacharly@gmail.com` | Sistem berhasil masuk dan mengarahkan pengguna baru ke Dashboard utama Warga. | Pengguna berhasil terdaftar dengan email yang dimasukkan dan diarahkan masuk ke Dashboard Warga. | Ya |

##### UAT_WR_04: Login Warga via Google Sign-In (Sesi Aktif)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_04** | Memverifikasi bahwa Warga yang telah login tidak perlu login kembali saat membuka aplikasi kembali. | 1. Tutup aplikasi SIBAPAK sepenuhnya.<br>2. Buka kembali aplikasi.<br>3. Amati layar awal yang ditampilkan. | Membuka kembali aplikasi | Sistem langsung mendeteksi akun yang sudah aktif dan mengarahkan langsung ke Dashboard Warga tanpa meminta login kembali. | Aplikasi langsung menampilkan Dashboard Warga tanpa melalui proses login dari awal. | Ya |

#### 1.1.3 Fitur Manajemen Profil Warga (Wilayah Riau)
Skenario untuk mengisi dan memperbarui profil domisili serta foto profil.

##### UAT_WR_05: Deteksi Kelengkapan Profil (Warning Card)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_05** | Memverifikasi adanya deteksi visual berupa kartu peringatan jika data profil warga belum lengkap. | 1. Login menggunakan akun Warga baru.<br>2. Masuk ke halaman beranda/dashboard utama. | Akun Warga Baru:<br>`dwimayacharly@gmail.com` | Muncul kartu peringatan berwarna biru gelap bertuliskan **"Profil Belum Lengkap"** disertai tombol **"Lengkapi Sekarang"**. | Kartu peringatan "Profil Belum Lengkap" muncul di bagian atas halaman beranda dengan tombol tindakan berwarna kontras. | Ya |

##### UAT_WR_06: Pengisian Data Profil Warga (Wilayah Riau)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_06** | Memverifikasi pengisian wilayah domisili menggunakan pilihan bertingkat (cascading dropdown). | 1. Ketuk tombol **Lengkapi Sekarang** pada kartu peringatan.<br>2. Pilih Provinsi, Kota/Kabupaten, Kecamatan, Kelurahan.<br>3. Isi alamat, lalu ketuk **Simpan Perubahan**. | - Provinsi: `Riau`<br>- Kabupaten/Kota: `Kota Pekanbaru`<br>- Kecamatan: `Rumbai`<br>- Kelurahan: `Limbungan Baru`<br>- Alamat: `Jl. Limbungan No. 15` | Pilihan wilayah menyaring secara otomatis berdasarkan urutan pilihan. Data berhasil disimpan, dan kartu peringatan di beranda otomatis hilang. | Pilihan dropdown wilayah berjalan secara dinamis, data tersimpan, dan kartu peringatan di beranda hilang. | Ya |

##### UAT_WR_07: Validasi Kolom NIK (16 Digit)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_07** | Memvalidasi input NIK warga harus berupa angka dan wajib tepat berjumlah 16 digit. | 1. Masuk ke halaman Edit Profil.<br>2. Ketik NIK kurang dari 16 digit.<br>3. Ketuk tombol **Simpan**. | NIK:<br>`147101120395` (12 digit angka) | Sistem menampilkan pesan kesalahan (*snackbar*) bahwa NIK harus tepat berjumlah 16 digit angka dan data batal disimpan. | Muncul pesan error snackbar "NIK wajib 16 digit angka!" dan perubahan profil ditolak. | Ya |

##### UAT_WR_08: Pembaruan Foto Profil & Nomor Telepon Warga
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_08** | Memverifikasi pembaruan foto profil melalui unggahan berkas foto dan nomor telepon warga. | 1. Buka halaman Edit Profil.<br>2. Pilih berkas foto dari galeri.<br>3. Isi kolom nomor telepon.<br>4. Ketuk **Simpan**. | - Berkas Foto Profil<br>- Nomor Telepon | Sistem menyimpan data baru, dan menampilkan foto profil serta nomor telepon yang baru di halaman profil utama. | Foto profil terupdate di UI, nomor telepon baru tersimpan dengan sukses. | Ya |

##### UAT_WR_09: Logout Akun Warga
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_09** | Memverifikasi tombol logout untuk mengakhiri sesi akun warga. | 1. Masuk ke halaman profil utama.<br>2. Ketuk tombol **Logout**.<br>3. Konfirmasi keluar. | Klik tombol **Logout** | Sesi pengguna diakhiri, aplikasi menutup dashboard dan mengarahkan kembali ke halaman Welcome/Masuk. | Sesi terhapus dan pengguna berhasil diarahkan kembali ke halaman Welcome. | Ya |

#### 1.1.4 Fitur Pengajuan Pengaduan Baru
Skenario untuk mengisi formulir aduan hukum, melihat status, serta pembatalan aduan.

##### UAT_WR_10: Mengisi Formulir Pengaduan Baru
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_10** | Memverifikasi pengisian formulir pengaduan baru (memilih jenis masalah, tanggal/waktu kejadian, dan melampirkan berkas bukti awal). | 1. Buka menu **Buat Pengaduan**.<br>2. Pilih jenis masalah dari daftar.<br>3. Pilih tanggal & waktu kejadian.<br>4. Pilih berkas lampiran bukti awal (PDF/Gambar). | - Jenis masalah<br>- Tanggal & waktu<br>- File lampiran bukti | Semua kolom form terisi dengan data yang valid, berkas lampiran berhasil dipilih, dan tombol Kirim aktif. | Kolom form terisi lengkap, berkas aduan terpilih masuk to daftar lampiran secara tepat. | Ya |

##### UAT_WR_11: Mengirimkan Formulir Pengaduan Baru
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_11** | Memverifikasi pengiriman formulir aduan hingga memicu pembuatan kode tiket pengaduan. | 1. Pastikan seluruh formulir terisi lengkap.<br>2. Ketuk tombol **Kirim Pengaduan**. | Klik tombol **Kirim Pengaduan** | Sistem mengirimkan data, menampilkan indikator pemuatan, lalu mengarahkan ke halaman sukses dengan kode tiket pengaduan. | Formulir terkirim, layar menampilkan halaman sukses beserta kode nomor aduan (misal: PGN-2026-00045). | Ya |

##### UAT_WR_12: Melihat Riwayat dan Detail Progres Pengaduan
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_12** | Memverifikasi penampilan riwayat daftar pengaduan warga beserta rincian status progres penanganan. | 1. Masuk ke halaman **Pengaduan Saya**.<br>2. Ketuk salah satu pengaduan dalam daftar. | Klik pengaduan aktif | Sistem menampilkan status detail pengaduan beserta linimasa progres penanganan (Menunggu, Diproses, Selesai). | Rincian data pengaduan dan histori tahapan penanganan kasus tampil secara lengkap. | Ya |

##### UAT_WR_13: Pembatalan Pengaduan oleh Warga
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_13** | Memverifikasi pembatalan kasus secara mandiri oleh warga saat pengaduan masih berstatus 'Menunggu'. | 1. Buka rincian pengaduan berstatus **Menunggu**.<br>2. Ketuk tombol **Batalkan Pengaduan**.<br>3. Konfirmasi pilihan **Ya**. | Klik konfirmasi pembatalan | Pengaduan berganti status menjadi "Dibatalkan", tercatat di linimasa pembatalan, dan tombol aksi pembatalan dinonaktifkan. | Kasus berhasil dibatalkan, status ter-update, dan tombol pembatalan menghilang dari UI. | Ya |

#### 1.1.5 Fitur Chat Real-time (POV Warga)
Skenario komunikasi langsung dua arah antara warga pelapor dengan paralegal pendamping.

##### UAT_WR_14: Masuk ke Ruang Chat Pendamping Hukum
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_14** | Memverifikasi pembukaan ruang chat untuk berkonsultasi dengan paralegal pendamping yang menangani kasus. | 1. Masuk ke rincian aduan berstatus **Diproses**.<br>2. Ketuk tombol **Hubungi Pendamping / Paralegal**. | Klik hubungi pendamping | Ruang obrolan terbuka secara otomatis dan menampilkan nama paralegal pendamping di bagian atas header. | Halaman chat room terbuka sukses dan memuat nama paralegal yang menangani kasus. | Ya |

##### UAT_WR_15: Mengirim dan Menerima Pesan Chat
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_15** | Memverifikasi proses pengiriman pesan teks warga dan penerimaan pesan balasan dari paralegal secara real-time. | 1. Ketik pesan teks pada input obrolan dan ketuk kirim.<br>2. Amati layar saat paralegal mengirimkan balasan. | Teks pesan chat | Pesan terkirim (berada di bubble kanan). Pesan balasan dari paralegal langsung muncul di sisi kiri secara otomatis tanpa memuat ulang halaman. | Pesan terkirim di sisi kanan, balasan masuk secara otomatis di sisi kiri secara real-time. | Ya |

##### UAT_WR_16: Mengirim & Membuka Lampiran Chat
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_16** | Memverifikasi pengiriman berkas gambar/PDF dalam ruang chat dan pembukaannya. | 1. Ketuk tombol (+), pilih gambar/PDF, lalu kirim.<br>2. Ketuk berkas gambar/PDF yang telah terkirim di dalam chat. | Berkas Gambar / PDF | Berkas terkirim di chat. Saat gambar ditap akan terbuka secara layar penuh, dan PDF terbuka di penampil internal. | Gambar berhasil dikirim dan dapat dibuka fullscreen, PDF terbuka pada viewer bawaan aplikasi. | Ya |

##### UAT_WR_17: Melihat Informasi Detail Paralegal Pendamping
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_17** | Memverifikasi penampilan informasi detail data diri paralegal pendamping dari ruang chat. | 1. Pada halaman ruang chat, ketuk nama paralegal pada header atas. | Klik nama Paralegal | Sistem menampilkan halaman informasi detail profil paralegal pendamping (nama, nomor kontak, instansi posbankum penugasan). | Halaman profil informasi paralegal pendamping tampil memuat detail kontak secara lengkap. | Ya |

#### 1.1.6 Fitur Penerimaan Notifikasi Pop-up (POV Warga)
Skenario pengujian notifikasi melayang (push notification) di HP warga.

##### UAT_WR_18: Menerima Notifikasi Pembaruan Status Kasus
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_18** | Memverifikasi notifikasi pop-up melayang di HP warga saat paralegal mengubah status penanganan kasus. | 1. Buka aplikasi warga di beranda.<br>2. Lakukan perubahan status kasus menjadi "Diproses" dari akun paralegal. | Perubahan status kasus | HP warga memunculkan notifikasi pop-up di atas layar secara real-time mengabarkan status aduan telah diperbarui. | Notifikasi pop-up melayang muncul secara instan di layar HP warga mengabarkan perubahan status kasus. | Ya |

##### UAT_WR_19: Menerima Notifikasi Pop-up Pesan Chat Baru
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_WR_19** | Memverifikasi notifikasi pop-up chat baru masuk saat aplikasi berada di luar layar (background). | 1. Tutup aplikasi atau kembalikan ke background.<br>2. Kirim pesan chat dari akun paralegal.<br>3. Amati bilah notifikasi HP warga, lalu ketuk notifikasi tersebut. | Pesan chat masuk | HP warga berdering dan memunculkan pop-up notifikasi. Saat ditap, aplikasi otomatis terbuka mengarah ke ruang chat terkait. | Notifikasi muncul di status bar HP dengan suara peringatan, ketika ditap langsung masuk ke halaman chat terkait. | Ya |

---

### 1.2 Pengujian Aktor Paralegal (Pendamping Hukum)
Aktor Paralegal bertindak sebagai pendamping lapangan yang bertugas melayani konsultasi warga di wilayah tugasnya, memperbarui progres aduan, serta melaporkan kegiatan sosialisasi hukum ke sistem.

#### 1.2.1 Fitur Login dan Autentikasi
Skenario masuk akun resmi paralegal.

##### UAT_PL_01: Login Paralegal via Google Sign-In
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_01** | Memverifikasi masuk akun paralegal menggunakan akun Google terdaftar. | 1. Pada halaman masuk, ketuk tombol **Masuk dengan Google**.<br>2. Pilih akun Google resmi milik paralegal. | Akun Google:<br>`ikhsan23ti@mahasiswa.pcr.ac.id` | Sistem mencocokkan email terdaftar dan mengarahkan paralegal masuk ke Dashboard Utama Paralegal. | Login berhasil dan pengguna masuk ke halaman utama dengan peran akses sebagai Paralegal. | Ya |

#### 1.2.2 Fitur Manajemen Profil Paralegal
Skenario pengubahan data profil paralegal.

##### UAT_PL_02: Pembaruan Profil Paralegal
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_02** | Memverifikasi pengubahan foto profil dan nomor HP paralegal. | 1. Masuk ke halaman Edit Profil.<br>2. Pilih berkas foto baru dari galeri.<br>3. Ubah nomor HP.<br>4. Ketuk **Simpan**. | - Berkas Foto<br>- Nomor HP Baru | Data profil tersimpan dengan sukses, perubahan foto dan nomor telepon tampil di profil utama paralegal. | Profil berhasil diubah, foto profil baru dan nomor HP ter-update di UI. | Ya |

##### UAT_PL_03: Logout Akun Paralegal
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_03** | Memverifikasi logout dari akun paralegal dan mengakhiri sesi. | 1. Masuk ke halaman profil utama.<br>2. Ketuk tombol **Logout**. | Klik tombol **Logout** | Sesi akun diakhiri secara aman dan aplikasi mengarahkan kembali ke halaman Welcome/Masuk. | Akun berhasil keluar dan kembali ke halaman Welcome. | Ya |

#### 1.2.3 Fitur Klaim Pengaduan Warga
Skenario penugasan mandiri atas kasus masuk di wilayah tugas kelurahan.

##### UAT_PL_04: Sinkronisasi Wilayah Tugas (Filter Otomatis)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_04** | Memastikan kasus yang muncul di daftar kasus masuk hanya berasal dari wilayah kelurahan tugasnya. | 1. Login menggunakan akun paralegal Kelurahan Limbungan Baru.<br>2. Buka menu daftar kasus masuk. | Akun Paralegal Kelurahan Limbungan Baru | Daftar kasus masuk yang ditampilkan hanya berisi pengaduan yang diajukan oleh warga berdomisili di Kelurahan Limbungan Baru. | Daftar kasus tersaring otomatis hanya memuat aduan asal Kelurahan Limbungan Baru. | Ya |

##### UAT_PL_05: Pengurutan Kasus Berdasarkan Urgensi
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_05** | Memverifikasi daftar kasus masuk terurut secara otomatis dari tingkat prioritas tertinggi ke terendah. | 1. Masuk ke halaman daftar kasus masuk.<br>2. Amati kartu kasus dari atas ke bawah. | Urutan daftar aduan | Kasus dengan tingkat prioritas "Sangat Tinggi" berada di urutan teratas, diikuti kasus prioritas dibawahnya. | Kasus berlabel prioritas tertinggi otomatis ter-render di urutan paling atas. | Ya |

##### UAT_PL_06: Mengambil Alih Penanganan Kasus (Klaim Kasus)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_06** | Memverifikasi klaim/pengambilan kasus hukum berstatus "Menunggu" oleh paralegal penanggung jawab wilayah. | 1. Pilih kasus berstatus **Menunggu**.<br>2. Ketuk tombol **Ambil Kasus**.<br>3. Konfirmasi pilihan **Ya**. | Klik ambil kasus & klik Ya | Kasus berpindah kepemilikan ke akun paralegal, status aduan berganti menjadi "Diproses", dan pindah ke tab kasus aktif. | Kasus berhasil diklaim, status kasus berubah menjadi "Diproses", dan masuk ke riwayat penanganan aktif paralegal. | Ya |

#### 1.2.4 Fitur Update Status & Progres Kasus
Skenario penginputan aktivitas penanganan dan penyelesaian kasus.

##### UAT_PL_07: Menambahkan Progres Penanganan Kasus
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_07** | Memverifikasi pengisian laporan berkala progres kasus dan melampirkan berkas bukti penanganan. | 1. Buka kasus aktif, ketuk **Update Progres**.<br>2. Tulis catatan tindakan.<br>3. Pilih file bukti penanganan (PDF/Gambar), lalu kirim. | - Catatan tindakan progres<br>- Berkas bukti penanganan | Tindakan berhasil tersimpan, riwayat penanganan ter-update di linimasa, dan file lampiran progres berhasil diunggah. | Progres berhasil diinput, catatan dan lampiran masuk ke baris linimasa detail kasus. | Ya |

##### UAT_PL_08: Melihat Berkas Bukti Awal Klien
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_08** | Memverifikasi pembukaan lampiran berkas bukti aduan awal (PDF/Gambar) yang dikirim oleh warga pelapor. | 1. Buka rincian kasus.<br>2. Ketuk berkas lampiran bukti awal warga pelapor. | Klik lampiran bukti | Lampiran terbuka secara tepat (gambar terbuka layar penuh, dokumen PDF tampil di pemutar internal aplikasi). | Berkas lampiran aduan warga sukses dibuka dan terbaca dengan jelas oleh paralegal. | Ya |

##### UAT_PL_09: Menyelesaikan Kasus (Status Selesai dengan Catatan)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_09** | Memverifikasi penyelesaian kasus secara formal disertai penginputan catatan mediasi/keputusan akhir. | 1. Pada detail kasus aktif, ketuk **Selesaikan Kasus**.<br>2. Pilih status Selesai.<br>3. Isi catatan kesimpulan mediasi, lalu kirim. | - Status: Selesai<br>- Catatan kesimpulan | Status kasus ditutup (selesai), catatan penutupan terdokumentasi di akhir linimasa, dan tombol tindakan dinonaktifkan. | Kasus berhasil ditutup dengan status "Selesai", catatan penutupan tampil di bagian akhir timeline aduan. | Ya |

#### 1.2.5 Fitur Chat Real-time (POV Paralegal)
Skenario komunikasi obrolan dari sisi paralegal.

##### UAT_PL_10: Masuk ke Ruang Chat Klien (Warga)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_10** | Memverifikasi masuk ke ruang chat konsultasi aktif dengan warga pelapor. | 1. Buka kasus aktif milik paralegal.<br>2. Ketuk tombol **Chat Warga**. | Klik tombol chat warga | Ruang chat terbuka sukses dan menampilkan nama warga pelapor secara dinamis pada judul obrolan. | Ruang chat terbuka dengan nama warga pelapor tampil dinamis di header obrolan. | Ya |

##### UAT_PL_11: Mengirim dan Menerima Pesan Chat
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_11** | Memverifikasi pengiriman pesan balasan paralegal dan penerimaan pesan warga secara real-time. | 1. Ketik teks balasan pada input obrolan dan kirim.<br>2. Amati layar saat ada pesan masuk baru dari warga. | Teks pesan chat | Pesan terkirim di sisi kanan. Balasan masuk dari warga langsung tampil di sisi kiri secara otomatis tanpa lag. | Pesan terkirim ke sisi kanan, pesan baru dari warga langsung tertampil di sisi kiri layar secara real-time. | Ya |

##### UAT_PL_12: Indikator Pesan Belum Dibaca
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_12** | Memverifikasi adanya tanda visual penanda pesan masuk baru pada daftar chat aktif paralegal. | 1. Kirim chat baru dari akun warga saat paralegal sedang di halaman daftar chat. | Pesan chat baru masuk | Item baris warga pada daftar chat memunculkan penanda visual (seperti garis warna samping atau pin angka jumlah pesan). | Tanda visual chat belum dibaca muncul dengan penanda yang jelas pada baris chat warga terkait. | Ya |

##### UAT_PL_13: Mengirim & Membuka Lampiran Chat
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_13** | Memverifikasi pengiriman lampiran gambar/file PDF di ruang chat dan pembukaannya. | 1. Ketuk tombol (+), pilih file gambar/PDF, kirim.<br>2. Ketuk balon chat gambar/PDF yang terkirim. | Berkas Gambar / PDF | Berkas dikirim ke ruang obrolan. Gambar dapat dibuka layar penuh, dan PDF terbuka di pemutar internal. | Lampiran berhasil dikirim dan dapat dibuka secara lancar di aplikasi. | Ya |

##### UAT_PL_14: Melihat Informasi Detail Klien (Warga)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_14** | Memverifikasi pemuatan rincian data profil warga pelapor langsung dari tombol menu informasi chat. | 1. Masuk ke ruang chat dengan klien.<br>2. Ketuk ikon informasi/nama warga pada header atas. | Klik info chat warga | Menampilkan halaman detail data diri klien pelapor (nama lengkap, NIK, alamat domisili terdaftar). | Profil rincian data klien pelapor dimuat dan tertampil dengan jelas. | Ya |

#### 1.2.6 Fitur Laporan Kegiatan Lapangan (Penyuluhan / Sosialisasi)
Skenario pelaporan aktivitas penyuluhan hukum lapangan kepada admin.

##### UAT_PL_15: Membuat Laporan Kegiatan Baru
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_15** | Memverifikasi pembuatan aduan/laporan kegiatan baru dengan memilih foto dokumentasi dari galeri. | 1. Ketuk tombol tambah kegiatan.<br>2. Isi rincian data kegiatan (judul, tgl pelaksanaan, lokasi, uraian deskripsi).<br>3. Unggah foto dokumentasi dari galeri, ketuk **Simpan Kegiatan**. | - Data teks kegiatan<br>- Berkas foto galeri | Laporan kegiatan tersimpan, status aduan diatur menjadi **MENUNGGU** persetujuan admin website. | Laporan berhasil disimpan ke sistem dengan status awal pengajuan "MENUNGGU". | Ya |

##### UAT_PL_16: Tampilan Detail Laporan Kegiatan Lapangan
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_16** | Memverifikasi rincian data laporan kegiatan lapangan yang sudah dibuat. | 1. Buka menu kegiatan.<br>2. Ketuk salah satu kegiatan dalam daftar. | Klik item kegiatan | Menampilkan halaman detail laporan kegiatan berisi foto dokumentasi, status laporan, lokasi, tanggal, deskripsi, dan nama pelapor. | Layar rincian menampilkan data kegiatan lapangan beserta status aduan secara lengkap. | Ya |

##### UAT_PL_17: Mengedit Laporan Kegiatan Berstatus Menunggu
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_17** | Memverifikasi pengeditan data laporan kegiatan yang saat ini berstatus "MENUNGGU". | 1. Buka detail kegiatan berstatus **MENUNGGU**.<br>2. Ketuk tombol edit, ubah data laporan.<br>3. Ketuk **Simpan Kegiatan**. | Perubahan data teks kegiatan | Data baru berhasil disimpan dan status laporan tetap berada dalam status pengajuan **MENUNGGU**. | Edit berhasil disimpan, rincian data kegiatan ter-update dengan status tetap "MENUNGGU". | Ya |

##### UAT_PL_18: Bagikan Detail Kegiatan (Teks / PDF)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_18** | Memverifikasi fitur cetak dan ekspor ringkasan detail kegiatan lapangan ke format teks atau berkas PDF. | 1. Buka detail kegiatan.<br>2. Ketuk tombol bagikan detail.<br>3. Pilih bagikan format teks atau cetak berkas PDF. | Klik bagikan detail | Aplikasi memproses konversi teks untuk dikirim atau berhasil meng-ekspor visual rincian kegiatan ke dokumen PDF. | Ringkasan teks berhasil dibagikan, file PDF laporan kegiatan berhasil dicetak dan diunduh. | Ya |

##### UAT_PL_19: Melihat Alasan Penolakan Laporan Kegiatan (Catatan Admin)
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_19** | Memverifikasi penampilan kartu catatan evaluasi dari admin jika status laporan kegiatan aduan ditolak. | 1. Buka detail laporan kegiatan yang berstatus **DITOLAK**. | Klik kegiatan ditolak | Sistem menampilkan box merah bertuliskan **Catatan Admin** yang memuat ulasan/alasan penolakan dari admin. | Ulasan alasan penolakan dari admin tampil di detail kegiatan untuk bahan revisi laporan. | Ya |

#### 1.2.7 Fitur Terima Notifikasi Persetujuan Kegiatan dari Admin (POV Paralegal)
Skenario penerimaan notifikasi dari admin website.

##### UAT_PL_20: Menerima Notifikasi Persetujuan Laporan Kegiatan
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_20** | Memverifikasi notifikasi pop-up masuk saat laporan kegiatan disetujui oleh admin via website. | 1. Buka beranda aplikasi paralegal.<br>2. Setujui laporan kegiatan tersebut dari website admin. | Persetujuan dari admin | HP paralegal memunculkan banner notifikasi pop-up melayang secara instan mengabarkan kegiatan telah disetujui. | Notifikasi pop-up in-app muncul di atas layar mengabarkan laporan kegiatan telah disetujui admin. | Ya |

##### UAT_PL_21: Menerima Notifikasi Penolakan Laporan Kegiatan
| Identifikasi | Deskripsi | Prosedur Pengujian | Masukan | Hasil yang Diharapkan | Hasil yang Diperoleh | Kesimpulan |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **UAT_PL_21** | Memverifikasi notifikasi masuk saat laporan kegiatan ditolak oleh admin dan membuka detailnya ketika ditap. | 1. Tutup aplikasi paralegal ke background.<br>2. Tolak laporan kegiatan dari website admin.<br>3. Ketuk notifikasi banner yang muncul di HP. | Penolakan dari admin | HP berdering memunculkan notifikasi banner. Saat ditap, aplikasi otomatis terbuka langsung mengarah ke halaman rincian kegiatan terkait. | Notifikasi banner penolakan muncul di status bar HP, saat diklik membuka langsung detail kegiatan ditolak tersebut. | Ya |

---

## REKAPITULASI HASIL UAT

Berdasarkan hasil pengujian yang dilakukan pada kedua peran pengguna (Warga dan Paralegal), rekapitulasi tingkat kelulusan skenario adalah sebagai berikut:

*   **Aktor Warga:**
    *   Jumlah Skenario Uji: **19 Skenario**
    *   Jumlah Lulus (Ya): **19 Skenario**
    *   Jumlah Gagal (Tidak): **0 Skenario**
    *   Tingkat Keberhasilan Warga: **100%**

*   **Aktor Paralegal:**
    *   Jumlah Skenario Uji: **21 Skenario**
    *   Jumlah Lulus (Ya): **21 Skenario**
    *   Jumlah Gagal (Tidak): **0 Skenario**
    *   Tingkat Keberhasilan Paralegal: **100%**

*   **Total Keseluruhan:**
    *   Total Skenario Uji: **40 Skenario**
    *   Total Lulus: **40 Skenario**
    *   Tingkat Kelulusan Sistem: **100% (Sistem Diterima oleh Pengguna)**
