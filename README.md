# SiMikro

**Sistem Informasi Peminjaman Inventaris Mikroptik**

SiMikro merupakan aplikasi mobile untuk mendigitalisasi pengelolaan inventaris dan proses peminjaman alat di lingkungan HMP Mikroptik. Aplikasi ini dikembangkan sebagai proyek Ujian Akhir Semester (UAS) mata kuliah Pemrograman Perangkat Bergerak.

## Latar Belakang

Proses peminjaman inventaris yang masih dilakukan secara manual melalui pencatatan buku atau komunikasi pribadi berpotensi menimbulkan beberapa permasalahan, seperti:

- Kesulitan mengetahui ketersediaan alat secara aktual.
- Risiko benturan jadwal dan peminjaman ganda.
- Kesulitan memantau keterlambatan pengembalian.
- Tidak tersedianya riwayat peminjaman dan kondisi alat yang terdokumentasi dengan baik.

SiMikro dikembangkan untuk membantu mengatasi permasalahan tersebut melalui sistem inventaris dan peminjaman yang terintegrasi.

## Fitur Utama

### 1. Autentikasi dan Manajemen Pengguna
- Login dan registrasi menggunakan email.
- Pengelolaan akun mahasiswa.
- Hak akses berdasarkan peran pengguna (Admin dan Mahasiswa).

### 2. Katalog dan Ketersediaan Inventaris
- Menampilkan daftar inventaris beserta informasi alat.
- Menampilkan jumlah stok dan ketersediaan alat.
- Menampilkan kondisi inventaris.

### 3. Peminjaman dan Penjadwalan
- Mengajukan peminjaman dengan memilih alat, jumlah, tanggal, dan alasan.
- Memvalidasi jumlah peminjaman berdasarkan stok tersedia.
- Memeriksa benturan jadwal peminjaman.

### 4. Dashboard Admin dan Riwayat
- Mengelola permintaan peminjaman.
- Menyetujui atau menolak pengajuan.
- Mencatat proses serah terima dan pengembalian.
- Mengelola data inventaris dan stok.
- Melihat riwayat peminjaman beserta kondisi alat saat dikembalikan.

## Alur Penggunaan

### Mahasiswa
1. Splash Screen
2. Login / Register
3. Home
4. Katalog Inventaris
5. Detail Alat
6. Form Peminjaman
7. Riwayat Peminjaman

Navigasi utama mahasiswa: Home, Katalog, Riwayat, dan Profil.

### Admin
1. Splash Screen
2. Login
3. Admin Dashboard
4. Permintaan Peminjaman
5. Serah Terima / Pengembalian
6. Manajemen Inventaris

Navigasi utama admin: Dashboard, Permintaan, Inventaris, dan Profil.

## Teknologi

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework pengembangan aplikasi mobile |
| Dart | Bahasa pemrograman |
| Firebase Authentication | Rencana layanan autentikasi pengguna |
| Cloud Firestore | Rencana database NoSQL |

**Catatan:** Flutter dan Dart telah digunakan untuk membuat struktur awal aplikasi. Integrasi Firebase Authentication dan Cloud Firestore masih merupakan bagian dari rencana pengembangan dan belum diimplementasikan.

## Rancangan Database

Database direncanakan menggunakan Cloud Firestore dengan struktur koleksi berikut.

### `users`

Menyimpan informasi pengguna.

| Field | Keterangan |
|---|---|
| `name` | Nama pengguna |
| `nim` | Nomor Induk Mahasiswa |
| `email` | Alamat email |
| `role` | Peran pengguna (`admin` / `student`) |
| `created_at` | Waktu pembuatan akun |

### `items`

Menyimpan data inventaris.

| Field | Keterangan |
|---|---|
| `nama_alat` | Nama alat |
| `kategori` | Kategori alat |
| `deskripsi` | Deskripsi alat |
| `stok_total` | Jumlah seluruh stok |
| `stok_tersedia` | Jumlah stok yang tersedia |
| `kondisi` | Kondisi alat |
| `image_url` | URL gambar alat |

### `borrowings`

Menyimpan data transaksi peminjaman.

| Field | Keterangan |
|---|---|
| `user_id` | ID pengguna yang meminjam |
| `nama_peminjam` | Nama peminjam |
| `item_id` | ID inventaris |
| `nama_alat` | Nama alat yang dipinjam |
| `jumlah` | Jumlah alat yang dipinjam |
| `tanggal_pinjam` | Tanggal mulai peminjaman |
| `tanggal_kembali` | Tanggal rencana pengembalian |
| `tanggal_dikembalikan` | Tanggal aktual pengembalian |
| `alasan` | Tujuan peminjaman |
| `status` | Status transaksi |
| `catatan_admin` | Catatan dari admin |
| `kondisi_kembali` | Kondisi alat saat dikembalikan |
| `created_at` | Waktu pengajuan |

Status transaksi yang direncanakan:

- `pending`
- `approved`
- `borrowed`
- `returned`
- `rejected`
- `cancelled`

### Aturan Bisnis dan Keamanan

- Jumlah peminjaman tidak boleh melebihi stok yang tersedia.
- Pengurangan stok dilakukan ketika alat diserahkan kepada peminjam.
- Stok dikembalikan ketika alat telah diterima kembali.
- Perubahan stok dan status transaksi perlu diproses secara konsisten menggunakan Firestore Transaction.
- Mahasiswa hanya dapat mengakses data peminjaman miliknya.
- Pengelolaan inventaris dan perubahan status transaksi dibatasi untuk admin.

## Tim Pengembang

| Nama | GitHub | Peran dan Tanggung Jawab |
|---|---|---|
| Narendra Lintang Saputra | [Rawlseyyy](https://github.com/Rawlseyyy) | **Lead / Backend Developer** — Integrasi Firebase, autentikasi, database, validasi stok, transaksi, Security Rules, dan state management. |
| Eka Putra Noandheli | [ekaaptrnn](https://github.com/ekaaptrnn) | **Project Manager / Admin Developer** — Pengelolaan backlog, target mingguan, repository, pull request, dan pengembangan fitur admin. |
| Galang Nur Seto | [Galangnurseto](https://github.com/Galangnurseto) | **UI/UX Designer** — Wireframe, mockup, design system, dan aset visual aplikasi. |
| Felix Trinidat | [FelixDatz](https://github.com/FelixDatz) | **Front-End Developer** — Implementasi Splash Screen, Home, Katalog, Detail Alat, bottom navigation, dan shared widgets. |
| Yardan Raditya Laksana | [yardann09](https://github.com/yardann09) | **Front-End Developer / QA** — Implementasi Form Peminjaman dan Riwayat, pengujian skenario, serta dokumentasi. |

## Menjalankan Project

### Prasyarat

Pastikan perangkat pengembangan telah memiliki:

- Flutter SDK
- Dart SDK
- Android Studio atau Android SDK
- Android Emulator atau perangkat Android fisik

### Instalasi

Clone repository:

```bash
git clone https://github.com/FelixDatz/SiMikro.git
cd SiMikro
```

Instal dependencies:

```bash
flutter pub get
```

Periksa konfigurasi project:

```bash
flutter doctor
```

Jalankan aplikasi:

```bash
flutter run
```

### Validasi

Untuk memeriksa kualitas dan konsistensi kode:

```bash
flutter analyze
```

Untuk menjalankan pengujian:

```bash
flutter test
```

## Status Pengembangan

- [x] Membuat repository GitHub.
- [x] Membuat struktur awal project Flutter.
- [x] Menyiapkan konfigurasi dasar Android.
- [x] Memastikan `flutter analyze` berhasil tanpa masalah.
- [x] Memastikan pengujian awal `flutter test` berhasil.
- [ ] Menyiapkan Android Emulator.
- [ ] Mengintegrasikan Firebase Authentication.
- [ ] Mengintegrasikan Cloud Firestore.
- [ ] Mengimplementasikan fitur aplikasi.
- [ ] Melakukan pengujian dan validasi fitur.

Status di atas menggambarkan kondisi awal pengembangan dan akan diperbarui seiring kemajuan project.

## Repository

GitHub: https://github.com/FelixDatz/SiMikro
