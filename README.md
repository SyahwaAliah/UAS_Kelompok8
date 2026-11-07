
# 📱 Aplikasi Bimbingan Skripsi

Aplikasi Bimbingan Skripsi merupakan aplikasi mobile berbasis Flutter (Dart) yang dikembangkan untuk memenuhi tugas UAS mata kuliah Mobile Programming.

Aplikasi ini ditujukan khusus untuk mahasiswa dalam mengelola jadwal bimbingan, melakukan booking jadwal, mencatat revisi, mengelola dokumen, serta memantau progres pengerjaan skripsi.

## 🛠️ Teknologi yang Digunakan

- Flutter & Dart — Pengembangan aplikasi Android
- Visual Studio Code — Code editor
- Android Emulator — Pengujian aplikasi mobile
- SQLite (sqflite) — Database lokal
- Git & GitHub — Version control dan kolaborasi kelompok

## 🚀 Cara Menjalankan Aplikasi

### 1. Persiapan

Pastikan perangkat sudah memiliki:
- Flutter SDK
- Android SDK
- Android Emulator
- Visual Studio Code
- Extension Flutter dan Dart

Cek instalasi Flutter:

```cmd
flutter doctor
```

### 2. Buka Project

Buka project melalui VS Code, lalu jalankan terminal Command Prompt:

```cmd
cd /d "D:\Semester 5\Moprog\UAS"
```

Catatan: Sesuaikan lokasi folder project dengan laptop masing-masing.

### 3. Install Dependency

Ketika pertama kali menjalankan project atau terdapat perubahan dependency, jalankan:

```cmd
flutter pub get
```

Aplikasi menggunakan package `sqflite` dan `path` untuk database SQLite.

Jika dependency belum ditambahkan ke project:

```cmd
flutter pub add sqflite path
```

SQLite tidak perlu diinstal secara terpisah pada Android Emulator.

### 4. Aktifkan Android Emulator

Jalankan:

```cmd
flutter emulators --launch Medium_Phone
```

Tunggu hingga emulator menampilkan home screen Android.

Untuk melihat daftar emulator yang tersedia:

```cmd
flutter emulators
```

### 5. Jalankan Aplikasi

Buka terminal baru dan jalankan:

```cmd
flutter run -d emulator-5554
```

Jika ID emulator berbeda, periksa menggunakan:

```cmd
flutter devices
```

Aplikasi akan dijalankan pada Android Emulator.

### 6. Perintah Tambahan

| Perintah | Fungsi |
|---|---|
| `r` | Hot Reload |
| `R` | Hot Restart |
| `q` | Menghentikan aplikasi |
| `flutter pub get` | Menginstal dependency |
| `flutter analyze` | Memeriksa kode Dart |
| `flutter devices` | Melihat perangkat terhubung |

## 📂 Fitur Aplikasi

Halaman utama aplikasi sudah dibuat menggunakan Flutter dan Dart.

Fitur yang tersedia atau sedang dikembangkan:

1. Dashboard Mahasiswa
2. Jadwal Bimbingan
3. Booking Jadwal Bimbingan
4. Checklist Skripsi
5. Revisi Skripsi
6. Dokumen Skripsi
7. Chat Bimbingan
8. Profil Mahasiswa
9. Notifikasi
10. Video Call

**Catatan:** Beberapa fitur masih berupa UI dan memerlukan integrasi lebih lanjut agar berfungsi sepenuhnya. Chat dan video call antarperangkat membutuhkan layanan tambahan di luar SQLite.

## 📁 Struktur Project

Struktur file tambahan yang direncanakan:

```text
lib/
├── main.dart
├── dashboard_page.dart
├── jadwal_page.dart
├── booking_jadwal_page.dart
├── chat_page.dart
├── checklist_page.dart
├── dokumen_page.dart
├── ... (file Dart halaman lainnya)
│
├── database/
│   └── database_helper.dart
│
├── models/
│   ├── mahasiswa_model.dart
│   ├── jadwal_model.dart
│   ├── checklist_model.dart
│   ├── revisi_model.dart
│   └── dokumen_model.dart
│
├── repositories/
│   ├── mahasiswa_repository.dart
│   ├── jadwal_repository.dart
│   ├── checklist_repository.dart
│   ├── revisi_repository.dart
│   └── dokumen_repository.dart
│
├── widgets/
│   ├── custom_calendar.dart
│   ├── animated_button.dart
│   ├── empty_state.dart
│   └── loading_widget.dart
│
├── utils/
│   └── booking_validator.dart
│
└── services/
    ├── file_service.dart
    └── notification_service.dart
```

Struktur di atas merupakan target pengembangan. File Dart halaman yang sudah ada tetap digunakan dan tidak perlu dibuat ulang.

## 👥 Pembagian Tugas Kelompok

Project ini dikerjakan oleh **3 anggota kelompok**.

Karena halaman utama aplikasi sudah dibuat, pengembangan berikutnya difokuskan pada penambahan file Dart yang belum tersedia, pengembangan fungsi, dan integrasi database.

### 👩‍💻 Anggota 1 — Database SQLite & CRUD

**File yang perlu dibuat:**

- `lib/models/mahasiswa_model.dart`
- `lib/models/jadwal_model.dart`
- `lib/models/checklist_model.dart`
- `lib/models/revisi_model.dart`
- `lib/models/dokumen_model.dart`
- `lib/repositories/mahasiswa_repository.dart`
- `lib/repositories/jadwal_repository.dart`
- `lib/repositories/checklist_repository.dart`
- `lib/repositories/revisi_repository.dart`
- `lib/repositories/dokumen_repository.dart`

**File yang dikembangkan:**

- `lib/database/database_helper.dart`

**Tanggung jawab:**
- Membuat struktur tabel SQLite.
- Membuat model data.
- Membuat operasi CRUD (Create, Read, Update, Delete).
- Menghubungkan database dengan halaman aplikasi.
- Memastikan data tetap tersimpan setelah aplikasi ditutup.
- Menguji proses penyimpanan dan pengambilan data.

### 👩‍💻 Anggota 2 — Kalender, Booking & Animasi

**File Dart yang perlu ditambahkan:**

- `lib/widgets/custom_calendar.dart`
- `lib/widgets/animated_button.dart`
- `lib/utils/booking_validator.dart`

**File lama yang dikembangkan:**

- `lib/jadwal_page.dart`
- `lib/booking_jadwal_page.dart`
- `lib/dashboard_page.dart`

**Tanggung jawab:**
- Membuat kalender bimbingan interaktif.
- Menambahkan animasi pada tombol dan pilihan jadwal.
- Membuat validasi tanggal dan waktu booking.
- Menampilkan jadwal yang dipilih mahasiswa.
- Memastikan tampilan kalender responsif.
- Mengintegrasikan komponen baru dengan halaman yang sudah tersedia.

### 👩‍💻 Anggota 3 — Fitur Pendukung Mahasiswa

**File Dart yang perlu ditambahkan:**

- `lib/services/file_service.dart`
- `lib/services/notification_service.dart`
- `lib/widgets/empty_state.dart`
- `lib/widgets/loading_widget.dart`

**File lama yang dikembangkan:**

- `lib/dokumen_page.dart`
- `lib/checklist_page.dart`
- `lib/detailrevisi_page.dart`
- `lib/profile_mahasiswa_page.dart`
- `lib/notification_page.dart`

**Tanggung jawab:**
- Membuat fungsi pemilihan dokumen lokal.
- Mengembangkan notifikasi pengingat jadwal.
- Menambahkan tampilan ketika data kosong.
- Menambahkan indikator loading.
- Menyempurnakan UI halaman dokumen, revisi, checklist, dan profil.
- Mengintegrasikan fitur tambahan dengan halaman lama.

### Aturan Pembagian Tugas

- File Dart halaman yang sudah ada tidak perlu dibuat ulang.
- Pertahankan bahasa Dart dan struktur Flutter yang sudah digunakan.
- Setiap anggota fokus pada file sesuai pembagian tugas.
- Perubahan pada file bersama harus dikoordinasikan.
- File tambahan harus diintegrasikan ke aplikasi.
- Setiap anggota wajib menguji hasil pengembangan pada Android Emulator.

## 🌿 Panduan Kolaborasi GitHub

Repository:
https://github.com/SyahwaAliah/UTS_Kelompok8

Untuk mempermudah pengerjaan kelompok, setiap anggota akan ditambahkan sebagai GitHub Collaborator.

### 1. Menambahkan Collaborator

Dilakukan oleh pemilik repository:

1. Buka repository GitHub.
2. Masuk ke menu **Settings**.
3. Pilih **Collaborators** pada bagian Access.
4. Klik **Add people**.
5. Masukkan username GitHub anggota kelompok.
6. Kirim invitation.
7. Anggota menerima invitation yang dikirim GitHub.

Setelah invitation diterima, anggota dapat berkontribusi pada repository sesuai izin yang diberikan.

### 2. Clone Repository

Untuk anggota yang belum memiliki project di laptop:

```cmd
git clone https://github.com/SyahwaAliah/UTS_Kelompok8.git
cd UTS_Kelompok8
flutter pub get
```

Jika sudah memiliki project dari repository yang sama, tidak perlu clone ulang.

### 3. Pembagian Branch

Setiap anggota menggunakan branch berbeda.

| Branch | Penanggung Jawab |
|---|---|
| `main` | Kode utama aplikasi |
| `feature/database` | Anggota 1 |
| `feature/jadwal-booking` | Anggota 2 |
| `feature/fitur-mahasiswa` | Anggota 3 |

Branch `main` digunakan sebagai hasil penggabungan pekerjaan seluruh anggota.

### 4. Membuat Branch

Contoh untuk Anggota 1 (Database):

```cmd
git switch main
git pull origin main
git switch -c feature/database
```

Untuk Anggota 2:

```cmd
git switch main
git pull origin main
git switch -c feature/jadwal-booking
```

Untuk Anggota 3:

```cmd
git switch main
git pull origin main
git switch -c feature/fitur-mahasiswa
```

Jika branch sudah dibuat sebelumnya, gunakan:

```cmd
git switch nama-branch
```

Pastikan perubahan lokal sudah disimpan atau di-commit sebelum berpindah branch.

### 5. Menyimpan Perubahan (Commit)

Setelah melakukan perubahan kode:

```cmd
git status
git add .
git commit -m "Menambahkan fitur sesuai tugas"
```

Periksa `git status` terlebih dahulu untuk memastikan tidak ada file yang tidak seharusnya ikut di-commit.

### 6. Upload Perubahan (Push)

Contoh untuk Anggota 1:

```cmd
git push -u origin feature/database
```

Untuk Anggota 2:

```cmd
git push -u origin feature/jadwal-booking
```

Untuk Anggota 3:

```cmd
git push -u origin feature/fitur-mahasiswa
```

Perintah push digunakan untuk mengirim hasil perubahan branch lokal ke GitHub.

### 7. Membuat Pull Request

Setelah berhasil push:

1. Buka repository GitHub.
2. Pilih menu **Pull requests**.
3. Klik **New pull request**.
4. Atur `base: main`.
5. Pilih branch masing-masing pada bagian `compare`.
6. Isi judul Pull Request.
7. Jelaskan perubahan yang sudah dibuat.
8. Klik **Create pull request**.

Contoh judul:

- `Implementasi Database SQLite dan CRUD`
- `Penambahan Kalender dan Validasi Booking`
- `Penambahan Fitur Dokumen dan Notifikasi`

### 8. Review dan Merge Pull Request

Sebelum perubahan digabungkan:

1. Anggota lain memeriksa kode yang dikirim.
2. Pastikan tidak ada error atau konflik.
3. Jalankan pengujian jika diperlukan.
4. Klik **Merge pull request** jika perubahan sudah sesuai.
5. Konfirmasi penggabungan ke branch `main`.

Anggota sebaiknya tidak melakukan merge terhadap perubahan yang belum diuji.

### 9. Mengambil Update Terbaru (Pull)

Setelah Pull Request berhasil digabungkan, anggota lain dapat mengambil perubahan terbaru:

```cmd
git switch main
git pull origin main
```

Perintah ini digunakan untuk memperbarui project lokal berdasarkan branch utama GitHub.

Jika ingin memperbarui branch fitur dengan perubahan terbaru dari `main`, lakukan merge atau rebase secara terpisah setelah memastikan pekerjaan lokal aman.

### 10. Mengubah File Langsung di GitHub

Untuk perubahan kecil seperti README:

1. Buka repository.
2. Pilih file yang ingin diedit.
3. Klik ikon pensil (Edit).
4. Ubah isi file.
5. Klik **Commit changes**.
6. Pilih commit langsung ke `main` jika disepakati dan memiliki izin, atau buat branch baru untuk Pull Request.

Untuk perubahan kode Flutter yang besar, disarankan menggunakan VS Code dan Pull Request.

## ⚠️ Aturan Kolaborasi

- Jangan menghapus file atau kode anggota lain tanpa koordinasi.
- Gunakan branch masing-masing.
- Hindari push langsung ke `main` untuk perubahan besar.
- Gunakan pesan commit yang jelas.
- Lakukan Pull Request setelah menyelesaikan fitur.
- Pastikan kode sudah diuji sebelum merge.
- Jangan mengunggah file log, hasil build, atau data pribadi.
- Pastikan seluruh fitur sudah digabungkan sebelum pengumpulan UAS.

## ✅ Checklist Pengembangan UAS

### Database
- [ ] Struktur tabel SQLite lengkap
- [ ] Model data selesai
- [ ] CRUD berjalan
- [ ] Data tersimpan secara lokal
- [ ] Database terhubung ke halaman Flutter

### Kalender dan Booking
- [ ] Kalender interaktif
- [ ] Validasi tanggal booking
- [ ] Validasi jam booking
- [ ] Animasi tombol dan pilihan jadwal
- [ ] Jadwal tersimpan dan tampil kembali

### Fitur Mahasiswa
- [ ] Dokumen bisa dipilih dan dibuka
- [ ] Checklist bisa diperbarui
- [ ] Revisi dapat dikelola
- [ ] Profil mahasiswa dapat diperbarui
- [ ] Notifikasi lokal berjalan
- [ ] Empty state dan loading tersedia

### Pengujian
- [ ] Aplikasi berjalan di Android Emulator
- [ ] Navigasi antarhalaman berfungsi
- [ ] Tidak ada error yang menghambat penggunaan
- [ ] Data tetap ada setelah aplikasi ditutup
- [ ] Semua Pull Request sudah digabungkan ke main
- [ ] README dan source code siap dikumpulkan

## 📝 Catatan Akhir

Project ini masih dalam tahap pengembangan UAS.

Fokus pengerjaan selanjutnya adalah menambahkan file Dart pendukung yang belum tersedia, menyempurnakan fitur yang sudah dibuat, mengintegrasikan SQLite, dan memastikan aplikasi berjalan dengan baik pada Android Emulator.

Setiap anggota bertanggung jawab terhadap tugas masing-masing dan melakukan kolaborasi melalui GitHub menggunakan branch dan Pull Request.
