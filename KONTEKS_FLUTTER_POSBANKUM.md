# KONTEKS PROYEK POSBANKUM — Flutter Mobile App

> Dokumen ini berisi konteks lengkap untuk AI agent yang membantu pengerjaan
> kode Flutter POSBANKUM. Baca semua sebelum menyarankan perubahan kode.

---

## 1. Gambaran Umum

POSBANKUM adalah aplikasi yang menghubungkan masyarakat yang butuh bantuan hukum
dengan kantor Posbankum (Pos Bantuan Hukum) beserta paralegalnya di wilayah
Kanwil Kemenkumham Riau.

**Sistem terdiri dari dua aplikasi terpisah:**
- **Mobile (Flutter + GetX)** — dikerjakan Ican, ini yang sedang dikerjakan
- **Web (Laravel + Inertia + Vue)** — dikerjakan tim web, sudah berjalan di VPS

---

## 2. Tech Stack Mobile

- **Framework**: Flutter
- **State management**: GetX
- **Auth Google**: package `google_sign_in`
- **Backend**: Laravel REST API
- **Auth API**: Laravel Sanctum — semua request protected pakai `Authorization: Bearer <token>`
- **Base URL API**: `https://sibapak.pocari.id/api`

---

## 3. Struktur Role User

Ada 3 role, tapi **admin hanya ada di web**:

| Role | Keterangan |
|---|---|
| `warga` | Masyarakat umum yang submit pengaduan |
| `paralegal` | Petugas yang menangani pengaduan, di-assign ke posbankum oleh admin |
| `admin` | Hanya di web — tidak login ke mobile |

Satu aplikasi Flutter menangani **dua role sekaligus** (warga & paralegal).
Routing halaman dibedakan berdasarkan field `role` dari response API.

---

## 4. Struktur Database Aktual (v4 — sudah final)

```
users
  id_user          char(36) PK         — UUID via trigger
  nama_lengkap     varchar(255)
  email            varchar(255)
  google_id        varchar(255) NULL   — untuk Google OAuth
  google_token     text NULL           — untuk Google OAuth
  password_hash    varchar(255)        — untuk login manual
  role             enum(admin|paralegal|warga)
  foto_profile     text NULL
  nomor_telepon    varchar(30) NULL
  status           enum(aktif|nonaktif)
  -- kolom admin-only (tidak diekspos ke Flutter):
  -- nip, email_kantor, nomor_kantor, jabatan, unit_kerja, alamat_kantor, name

masyarakat
  id_user          FK → users (juga PK)
  nik              varchar(30)
  alamat           text
  id_kabupaten     char(36) FK → kabupaten   ← PAKAI ID, bukan nama string
  id_kecamatan     char(36) FK → kecamatan   ← PAKAI ID, bukan nama string
  id_kelurahan     char(36) FK → kelurahan   ← PAKAI ID, bukan nama string

posbankum
  id_posbankum     char(36) PK
  id_kelurahan     char(36) FK → kelurahan   ← lokasi posbankum via ID
  nama             varchar(255)
  alamat           text
  nomor_tlp        varchar(30)
  latitude, longitude                        ← koordinat maps
  status_verifikasi_tagging_area enum(menunggu|disetujui|ditolak)
  -- kolom tidak relevan di mobile: email_akun, password_akun (sisa lama)

posbankum_paralegal          ← many-to-many, ini acuan utama assign paralegal
  id_relasi        char(36) PK
  id_posbankum     FK → posbankum
  id_user          FK → users (paralegal)
  is_primary       tinyint — apakah paralegal utama posbankum ini
  status           enum(aktif|nonaktif)
  assigned_by      FK → users (admin yang assign)

pengaduan
  id_pengaduan     char(36) PK
  id_posbankum     FK → posbankum
  id_kabupaten     char(36) FK → kabupaten   ← PAKAI ID
  id_kecamatan     char(36) FK → kecamatan   ← PAKAI ID
  id_kelurahan     char(36) FK → kelurahan   ← PAKAI ID
  nomor_pengaduan  varchar(100)
  nama_pelapor     varchar(255)
  nomor_telepon    varchar(30)
  nik              varchar(30)
  jenis_masalah    varchar(150)
  judul_pengaduan  varchar(255)
  kronologi        text
  tanggal_kejadian date
  lokasi_kejadian  text
  status           enum(menunggu|diproses|selesai|dibatalkan)
  catatan_internal text NULL  ← alasan penolakan (dibatalkan) / catatan selesai
  created_by       FK → users
  masyarakat_id    FK → users (warga pemilik pengaduan)
  id_paralegal     FK → users (paralegal yang ditugaskan, nullable)
  -- catatan: prioritas diset admin web, tidak perlu di form Flutter

pengaduan_lampiran
  id_lampiran      char(36) PK
  id_pengaduan     FK → pengaduan
  id_timeline      FK → pengaduan_timeline (nullable)
  nama_file        varchar(255)
  path_file        text
  mime_type        varchar(150)
  size_bytes       bigint
  jenis_lampiran   enum(bukti_awal|progress|chat|lainnya)
  created_by       FK → users

pengaduan_timeline
  id_timeline      char(36) PK
  id_pengaduan     FK → pengaduan
  tipe             enum(status|catatan|lampiran|sistem)
  title            varchar(255)
  deskripsi        text
  is_visible       tinyint — jika 0, sembunyikan dari warga
  tanggal          datetime
  created_by       FK → users

chat_pesan
  id_pesan         char(36) PK
  id_pengaduan     FK → pengaduan
  pengirim_id      FK → users
  pengirim_nama    varchar(255)
  pengirim_role    enum(admin|paralegal|warga)
  isi_pesan        text
  lampiran_url     text NULL
  is_read          tinyint
  read_at          datetime NULL

kegiatan
  id_kegiatan      char(36) PK
  id_posbankum     FK → posbankum
  judul            varchar(255)
  deskripsi        text
  catatan          text NULL
  status           varchar(50) default 'draft'
  tgl_mulai        date NULL
  tgl_selesai      date NULL
  thumbnail_path   text NULL
  lokasi           text NULL
  anggota_terlibat json NULL
  kategori         varchar(100) NULL
  hasil_kegiatan   text NULL
  created_by       FK → users

notifikasi
  id_notifikasi    char(36) PK
  id_posbankum     FK → posbankum (NOT NULL — wajib diisi, termasuk untuk notif warga)
  id_user_penerima FK → users NULL  ← untuk notifikasi ke warga
  judul            varchar(255)
  pesan            text
  kategori         enum(pengaduan|kegiatan|dokumen|sistem)
  prioritas        enum(tinggi|sedang|rendah)
  is_read          tinyint — trigger otomatis isi read_at saat is_read=1
  ref_table        varchar(100) NULL  ← nama tabel referensi (e.g. 'pengaduan')
  ref_id           char(36) NULL      ← id record referensi

kabupaten  → kecamatan (id_kabupaten) → kelurahan (id_kecamatan)
  Selalu pakai ID untuk relasi, TIDAK PERNAH nama string

-- VIEW tersedia (dibuat tim web, bisa dipakai di controller):
v_paralegal_posbankum
  JOIN users + posbankum_paralegal + posbankum + kelurahan + kecamatan + kabupaten
  Berguna untuk cek wilayah kerja paralegal tanpa query kompleks
```

---

## 5. Aturan Bisnis Penting

### Assign Paralegal ke Posbankum
- **Tidak ada `id_posbankum` di tabel `users`** — ini sudah dihapus
- Relasi paralegal ↔ posbankum **hanya** via tabel `posbankum_paralegal`
- Satu paralegal bisa di-assign ke beberapa posbankum (`is_primary` menentukan yang utama)
- Assignment dilakukan admin via web, bukan dari mobile

### Pengaduan & Wilayah Kerja Paralegal
- Routing otomatis: pengaduan masuk ke posbankum berdasarkan kecocokan
  `id_kelurahan` masyarakat dengan `id_kelurahan` posbankum
- Paralegal **hanya bisa melihat pengaduan dari kelurahan wilayah kerjanya**
- Filter ini dilakukan di backend — gunakan view `v_paralegal_posbankum`
- Trigger DB memvalidasi bahwa `id_paralegal` di pengaduan harus paralegal
  aktif di posbankum yang sama

### Lampiran / Dokumen
- Lampiran = **bukti dokumen dari warga** (foto KTP, surat, dll)
- Tabel: `pengaduan_lampiran`
- Warga: hanya bisa lihat & upload lampiran pengaduan **miliknya sendiri**
- Paralegal: bisa lihat semua lampiran dari pengaduan **wilayah kerjanya**
- **Tidak ada fitur dokumen legalitas posbankum di mobile** (itu urusan web)

### Status Pengaduan
```
menunggu → diproses → selesai    (catatan_internal: opsional, catatan akhir)
                    → dibatalkan (catatan_internal: WAJIB, alasan penolakan)
```

### Timeline
- `is_visible = 0` artinya entri timeline tidak ditampilkan ke warga
- Flutter harus filter `is_visible = 1` untuk tampilan warga
- Paralegal bisa lihat semua `is_visible`

### Notifikasi
- Untuk **paralegal**: filter by `id_posbankum`
- Untuk **warga**: filter by `id_user_penerima`
- `id_posbankum` wajib ada di setiap notifikasi (NOT NULL) — tim web isi ini
  dari `id_posbankum` pengaduan terkait saat kirim notifikasi ke warga

### Kegiatan vs Berita
- Tabel `kegiatan` = konten yang diupload paralegal via **mobile** ✅
- Tabel `berita` = konten admin via **web saja**, tidak ada di mobile ❌

---

## 6. Daftar Lengkap Endpoint API

**Format response semua endpoint:**
```json
{ "status": true/false, "message": "...", "data": { ... } }
```

### PUBLIC (tanpa token)

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/auth/google/callback` | Kirim `id_token` dari google_sign_in → return Sanctum token |
| POST | `/register` | Register manual (email + password) |
| POST | `/login` | Login manual (email + password) |
| POST | `/forgot-password` | Kirim email reset. Body: `{ email }` |
| POST | `/reset-password` | Submit token baru. Body: `{ token, email, password }` |
| GET | `/posbankum` | List posbankum. Query: `?search=&id_kabupaten=&id_kecamatan=` |
| GET | `/posbankum/{id}` | Detail posbankum + daftar paralegal aktif |
| GET | `/wilayah/kabupaten` | List semua kabupaten |
| GET | `/wilayah/kecamatan` | List kecamatan. Query: `?id_kabupaten={id}` |
| GET | `/wilayah/kelurahan` | List kelurahan. Query: `?id_kecamatan={id}` |

### PROTECTED (wajib `Authorization: Bearer <token>`)

**Auth & Profil**

| Method | Endpoint | Body / Keterangan |
|---|---|---|
| POST | `/logout` | Hapus token aktif |
| GET | `/profile` | Profil user login + data masyarakat (jika role warga) |
| PUT | `/profile` | Update profil. Field: `nama_lengkap, nomor_telepon, foto_profile, nik, alamat, id_kelurahan` |
| PUT | `/profile/password` | `{ old_password, new_password }` |
| POST | `/profile/google/link` | `{ id_token }` — hubungkan Google ke akun |
| DELETE | `/profile/google/link` | Lepas Google (hanya jika punya password_hash) |

**Upload**

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/upload/foto-profil` | multipart/form-data, field: `foto`, maks 2MB |

**Dashboard**

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/pengaduan/statistik` | Jumlah pengaduan per status (filter by role otomatis) |

**Pengaduan**

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/pengaduan` | List pengaduan (warga: miliknya; paralegal: wilayah kerjanya) |
| POST | `/pengaduan` | Buat pengaduan baru |
| GET | `/pengaduan/{id}` | Detail pengaduan |
| PATCH | `/pengaduan/{id}/status` | `{ status, catatan_internal }` — update status (paralegal) |
| GET | `/pengaduan/{id}/lampiran` | List lampiran bukti |
| POST | `/pengaduan/{id}/lampiran` | Upload lampiran. multipart/form-data, maks 10MB, field: `file, jenis_lampiran, id_timeline` |
| GET | `/pengaduan/{id}/timeline` | List progres kasus (warga: filter is_visible=1) |
| POST | `/pengaduan/{id}/timeline` | Tambah progres (paralegal). `{ title, deskripsi, tipe }` |

**Chat**

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/chat/{id_pengaduan}` | List pesan |
| POST | `/chat/{id_pengaduan}` | Kirim pesan. `{ isi_pesan }` |

**Kegiatan**

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/kegiatan` | List kegiatan |
| POST | `/kegiatan` | Upload kegiatan baru (paralegal only) |
| GET | `/kegiatan/{id}` | Detail kegiatan |
| PUT | `/kegiatan/{id}` | Update kegiatan (paralegal pemilik only) |

**Notifikasi**

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/notifikasi` | List notifikasi user login |
| GET | `/notifikasi/unread-count` | Jumlah notifikasi belum dibaca |
| PATCH | `/notifikasi/{id}/read` | Tandai satu sudah dibaca |
| PATCH | `/notifikasi/read-all` | Tandai semua sudah dibaca |

---

## 7. Pola Auth di Flutter

### Google Sign In → Sanctum Token
```dart
// 1. Trigger Google Sign In
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
final String idToken = googleAuth.idToken!;

// 2. Kirim ke backend
final response = await dio.post('/auth/google/callback', data: {
  'id_token': idToken,
});

// 3. Simpan token Sanctum + role
final String token = response.data['data']['token'];
final String role  = response.data['data']['user']['role'];
```

### Request dengan Token
```dart
dio.options.headers['Authorization'] = 'Bearer $token';
dio.options.headers['Accept'] = 'application/json';
```

### Routing Berdasarkan Role
```dart
if (role == 'warga') {
  Get.offAllNamed('/warga/home');
} else if (role == 'paralegal') {
  Get.offAllNamed('/paralegal/home');
}
```

---

## 8. Yang TIDAK Ada di Mobile

| Fitur | Alasan |
|---|---|
| ❌ Endpoint `/berita` | Tabel berita hanya untuk web |
| ❌ Endpoint `/posbankum/{id}/dokumen` | Dokumen legalitas posbankum hanya web |
| ❌ Halaman / fitur admin | Admin hanya di web |
| ❌ Verifikasi data posbankum | Hanya web |
| ❌ Manajemen akun paralegal | Hanya web (admin yang assign) |
| ❌ Input `prioritas` pengaduan | Diset admin web |

---

## 9. Catatan Penting untuk AI Agent

- Saat mengubah kode yang hit API, selalu cek tabel endpoint di section 6
- Semua field wilayah wajib pakai **ID** (`id_kabupaten`, `id_kecamatan`, `id_kelurahan`), bukan nama string
- `users` **tidak punya `id_posbankum`** — relasi paralegal ke posbankum hanya via `posbankum_paralegal`
- Response dari backend selalu `{ status, message, data }` — parse dari field `data`
- Upload file selalu pakai `multipart/form-data`, bukan JSON
- Token Sanctum dikirim via header `Authorization: Bearer <token>`
- Filter wilayah kerja paralegal ada di backend — Flutter cukup konsumsi responsenya
- View `v_paralegal_posbankum` tersedia di DB untuk query wilayah paralegal
- Timeline dengan `is_visible = 0` tidak ditampilkan ke warga
