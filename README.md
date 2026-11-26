# 🎓 SKRIVA — Your Thesis Companion

**SKRIVA** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu mahasiswa dan dosen dalam mengelola proses bimbingan skripsi secara lebih mudah, terstruktur, dan efisien.

Melalui Skriva, mahasiswa dapat memantau perkembangan skripsi, melakukan booking jadwal bimbingan, mengelola revisi, menyimpan dokumen, serta berkomunikasi dengan dosen pembimbing melalui satu aplikasi.

Aplikasi ini dikembangkan sebagai proyek **Ujian Akhir Semester (UAS) mata kuliah Mobile Programming** dengan menggunakan **Flutter, Dart, dan SQLite**.

---

## 📱 Fitur Utama

### 👨‍🎓 Fitur Mahasiswa

| Fitur | Deskripsi |
|---|---|
| Dashboard | Menampilkan ringkasan progress skripsi, jadwal bimbingan, revisi, dan catatan terbaru. |
| Profil Mahasiswa | Melihat serta mengubah informasi akademik dan avatar. |
| Jadwal Bimbingan | Melihat ketersediaan jadwal dosen dan melakukan booking bimbingan. |
| Progress Skripsi | Memantau persentase penyelesaian skripsi. |
| Checklist | Menambahkan, menyelesaikan, dan menghapus tahapan pengerjaan skripsi. |
| Revisi Skripsi | Melihat revisi dari dosen, mengunggah lampiran, dan mengirimkan hasil revisi. |
| Chat | Berkomunikasi dengan dosen pembimbing. |
| Notes | Membuat catatan pribadi serta menyimpan lampiran gambar dan dokumen. |
| Dokumen | Mengunggah, membuka, dan mengelola dokumen skripsi. |
| Notifikasi | Melihat informasi dan pembaruan aktivitas bimbingan. |
| Video Call | Menampilkan simulasi antarmuka panggilan video. |

### 👩‍🏫 Fitur Dosen

| Fitur | Deskripsi |
|---|---|
| Dashboard Dosen | Menampilkan ringkasan mahasiswa bimbingan, jadwal, dan revisi. |
| Profil Dosen | Melihat serta memperbarui informasi pribadi, akademik, dan avatar. |
| Kelola Jadwal | Membuat slot jadwal bimbingan dan mengelola permintaan booking. |
| Kelola Revisi | Memberikan revisi, memeriksa lampiran, dan memberikan feedback. |
| Daftar Mahasiswa | Melihat mahasiswa yang berada dalam bimbingannya. |
| Chat Mahasiswa | Berkomunikasi dengan mahasiswa bimbingan. |
| Notifikasi | Melihat pembaruan aktivitas bimbingan dan revisi. |

---

## 🛠️ Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework pengembangan aplikasi mobile |
| Dart | Bahasa pemrograman |
| SQLite | Database lokal |
| sqflite | Pengelolaan SQLite pada Flutter |
| Material Design 3 | Komponen antarmuka pengguna |
| Visual Studio Code | Code editor |
| Android Studio | Android SDK dan emulator |
| Git & GitHub | Version control dan repository |

---

## 💻 Persyaratan Sistem

Sebelum menjalankan aplikasi Skriva, pastikan perangkat sudah memiliki:

- Flutter SDK dan Dart SDK
- Visual Studio Code atau Android Studio
- Android SDK
- Android Emulator atau perangkat Android
- Git
- Koneksi internet untuk instalasi dependency awal

Untuk memastikan Flutter sudah terpasang dengan benar, jalankan:

```bash
flutter doctor
```

Pastikan konfigurasi Flutter dan Android toolchain sudah siap digunakan.

---

## 🚀 Instalasi dan Menjalankan Aplikasi

### 1. Clone Repository

Buka terminal, kemudian jalankan:

```bash
git clone <URL_REPOSITORY_GITHUB>
```

Masuk ke direktori proyek:

```bash
cd UAS
```

Ganti `<URL_REPOSITORY_GITHUB>` dengan alamat repository GitHub Skriva.

### 2. Install Dependencies

Jalankan:

```bash
flutter pub get
```

Perintah ini akan mengunduh package yang dibutuhkan oleh proyek.

### 3. Periksa Emulator

Untuk melihat emulator Android yang tersedia:

```bash
flutter emulators
```

Jika menggunakan emulator bernama `Medium_Phone`, jalankan:

```bash
flutter emulators --launch Medium_Phone
```

Tunggu hingga emulator Android terbuka.

### 4. Periksa Devices

Jalankan:

```bash
flutter devices
```

Contoh output:

```text
Found 3 connected devices:

Medium Phone  • emulator-5554 • android
Chrome        • chrome        • web
Windows       • windows       • desktop
```

### 5. Jalankan Skriva

Gunakan perintah:

```bash
flutter run -d emulator-5554
```

Sesuaikan `emulator-5554` dengan Device ID yang terdeteksi.

Jika berhasil, aplikasi akan terbuka pada emulator dan menampilkan halaman Login Skriva.

---

## 🔐 Akun Demo

Aplikasi Skriva menyediakan akun demo Mahasiswa dan Dosen untuk pengujian fitur.

### Akun Mahasiswa

| Nama | Email | NIM |
|---|---|---|
| Mahasiswa Demo 1 | mahasiswa1@skriva.demo | 20260001 |
| Mahasiswa Demo 2 | mahasiswa2@skriva.demo | 20260002 |

### Akun Dosen

| Nama | Email | ID Dosen |
|---|---|---|
| Dr. Budi Santoso, M.Kom. | budi@skriva.demo | D001 |
| Dr. Siti Rahmawati, M.Kom. | siti@skriva.demo | D002 |
| Andi Pratama, S.Kom., M.T. | andi@skriva.demo | D003 |
| Dr. Maya Puspita, M.Kom. | maya@skriva.demo | D004 |
| Rizky Firmansyah, S.Kom., M.Kom. | rizky@skriva.demo | D005 |
| Dr. Nurul Hidayah, M.Kom. | nurul@skriva.demo | D006 |
| Dimas Saputra, S.T., M.Kom. | dimas@skriva.demo | D007 |

**Catatan:**

- Akun demo belum mempunyai password bawaan pada saat database pertama kali dibuat.
- Pengguna harus melakukan aktivasi akun melalui halaman **Sign Up**.
- Password dibuat sendiri dengan minimal 8 karakter.
- Akun yang sudah diaktivasi dapat langsung digunakan untuk Login dengan password yang didaftarkan.

### Contoh Aktivasi Akun

**Mahasiswa:**

```text
Email    : mahasiswa1@skriva.demo
NIM      : 20260001
Password : Skriva123!
```

**Dosen:**

```text
Email    : budi@skriva.demo
ID Dosen : D001
Password : Skriva123!
```

Password di atas hanya contoh yang dapat dipilih saat aktivasi, bukan password yang sudah otomatis terpasang pada akun.

---

## 📖 Panduan Penggunaan

### 1. Login dan Sign Up

1. Buka aplikasi Skriva.
2. Pilih **Sign Up** apabila akun belum diaktivasi.
3. Masukkan email yang telah terdaftar.
4. Masukkan NIM atau ID Dosen sesuai akun.
5. Buat password minimal 8 karakter.
6. Selesaikan proses aktivasi.
7. Kembali ke halaman Login.
8. Masukkan email dan password.
9. Pengguna akan diarahkan menuju Dashboard sesuai role.

### 2. Dashboard

Dashboard merupakan halaman utama setelah pengguna berhasil Login.

**Dashboard Mahasiswa** menampilkan progress skripsi, jadwal bimbingan terdekat, revisi terbaru, catatan pribadi, dan akses cepat menuju fitur lainnya.

**Dashboard Dosen** menampilkan jumlah mahasiswa bimbingan, permintaan booking, revisi yang menunggu review, serta akses untuk mengelola aktivitas bimbingan.

### 3. Booking Jadwal Bimbingan

1. Mahasiswa membuka menu **Jadwal**.
2. Sistem menampilkan slot jadwal dari dosen pembimbing.
3. Pilih jadwal yang tersedia.
4. Lakukan booking bimbingan.
5. Status permintaan berubah menjadi **Menunggu**.
6. Dosen memeriksa dan menyetujui permintaan.
7. Status jadwal diperbarui menjadi **Terjadwal** setelah disetujui.
8. Dosen dapat memperbarui status menjadi **Selesai** setelah bimbingan dilaksanakan.

### 4. Mengelola Revisi Skripsi

**Dosen:**

1. Buka menu Revisi.
2. Pilih mahasiswa bimbingan.
3. Buat revisi baru.
4. Masukkan judul, catatan, dan deadline revisi.
5. Simpan revisi.
6. Periksa hasil revisi yang dikirim mahasiswa.
7. Berikan feedback dan keputusan review.

**Mahasiswa:**

1. Buka menu Revisi.
2. Pilih revisi yang diberikan dosen.
3. Baca catatan dan deadline.
4. Kerjakan revisi sesuai instruksi.
5. Unggah lampiran PDF, DOC, atau DOCX jika diperlukan.
6. Kirim hasil revisi kepada dosen.
7. Lihat feedback serta status revisi terbaru.

### 5. Progress Skripsi dan Checklist

1. Buka menu **Progress Skripsi** atau **Checklist**.
2. Sistem menampilkan daftar tahapan pengerjaan skripsi.
3. Tandai checklist yang telah selesai.
4. Tambahkan tahapan baru apabila diperlukan.
5. Hapus tahapan yang tidak digunakan.
6. Persentase progress dihitung berdasarkan jumlah checklist yang telah selesai.

Persentase progress juga ditampilkan melalui diagram pada Dashboard Mahasiswa.

### 6. Notes

Notes digunakan untuk menyimpan catatan pribadi selama pengerjaan skripsi.

Cara menggunakan:

1. Buka menu Notes.
2. Buat catatan baru.
3. Masukkan judul dan isi catatan.
4. Tambahkan lampiran jika diperlukan.
5. Simpan catatan.
6. Buka kembali catatan untuk membaca, mengedit, atau menghapusnya.

Notes mendukung lampiran berupa gambar dan dokumen sesuai format yang diizinkan aplikasi.

### 7. Dokumen Skripsi

Menu Dokumen digunakan untuk menyimpan dan mengelola file skripsi.

1. Buka menu Dokumen.
2. Pilih file yang ingin disimpan.
3. Unggah file melalui aplikasi.
4. File akan tersimpan pada penyimpanan lokal aplikasi.
5. Pengguna dapat membuka atau menghapus dokumen yang telah disimpan.

### 8. Chat

1. Buka menu Chat.
2. Pilih dosen atau mahasiswa sesuai role akun.
3. Tulis pesan pada kolom percakapan.
4. Tekan tombol Kirim.
5. Pesan disimpan dan ditampilkan dalam riwayat percakapan.

### 9. Notifikasi

Menu Notifikasi digunakan untuk menampilkan informasi dan pembaruan terkait aktivitas bimbingan, seperti jadwal dan revisi, sesuai fitur yang tersedia pada aplikasi.

### 10. Mengubah Profil

1. Buka halaman Profil.
2. Pilih **Edit Profil**.
3. Perbarui informasi yang tersedia.
4. Tekan tombol Simpan.
5. Sistem menyimpan perubahan ke database lokal.

Pengguna juga dapat mengganti avatar melalui pilihan avatar bawaan atau foto dari galeri.

---

## 🗄️ Database dan Penyimpanan

Skriva menggunakan **SQLite** sebagai database lokal untuk menyimpan informasi aplikasi.

Data yang dikelola antara lain:

- Akun Mahasiswa dan Dosen
- Relasi Dosen Pembimbing
- Profil Pengguna
- Jadwal Bimbingan
- Progress dan Checklist
- Revisi Skripsi
- Lampiran Revisi
- Chat
- Notes
- Dokumen
- Notifikasi

Database tersimpan secara lokal pada perangkat tempat aplikasi dijalankan.

### Batasan Sistem

- Data SQLite belum otomatis tersinkronisasi antarperangkat.
- Simulasi interaksi Mahasiswa dan Dosen dapat dilakukan dengan berganti akun pada instalasi aplikasi yang sama.
- Fitur Video Call masih berupa simulasi antarmuka dan belum mendukung panggilan video secara real-time.
- Aplikasi dikembangkan sebagai prototipe untuk kebutuhan pembelajaran dan pengujian akademik.

---

## 🔧 Troubleshooting

### Emulator Tidak Terdeteksi

Jalankan:

```bash
flutter devices
```

Jika emulator belum terdeteksi, coba:

```bash
adb start-server
adb devices
```

Pastikan status emulator adalah `device`, bukan `offline`.

### Dependency Belum Terpasang

```bash
flutter pub get
```

### Error pada Source Code

```bash
flutter analyze
```

Periksa error yang muncul pada terminal dan perbaiki file yang terkait.

### Aplikasi Tidak Berjalan

Pastikan Android Emulator sudah aktif, kemudian jalankan:

```bash
flutter run -d emulator-5554
```

### Hot Reload dan Hot Restart

Ketika Flutter sedang berjalan di terminal:

| Perintah | Fungsi |
|---|---|
| `r` | Hot Reload |
| `R` | Hot Restart |
| `q` | Menghentikan aplikasi |
| `h` | Menampilkan bantuan |

### Gagal Login

Pastikan:

1. Email sesuai dengan akun yang terdaftar.
2. Akun telah diaktivasi melalui Sign Up.
3. Password sesuai dengan password saat aktivasi.
4. NIM atau ID Dosen yang digunakan saat aktivasi benar.

---

## 🎯 Tujuan Pengembangan

Pengembangan Skriva bertujuan untuk:

1. Mempermudah proses pengelolaan bimbingan skripsi.
2. Membantu mahasiswa memantau perkembangan penyelesaian skripsi.
3. Memfasilitasi komunikasi antara mahasiswa dan dosen pembimbing.
4. Mengelola jadwal, revisi, catatan, dan dokumen dalam satu aplikasi.
5. Menerapkan konsep pemrograman mobile menggunakan Flutter dan Dart.
6. Mengimplementasikan SQLite sebagai sistem penyimpanan data lokal.
7. Mengembangkan antarmuka yang modern, responsif, dan mudah digunakan.

---

## 👥 Identitas Pengembang

Aplikasi **SKRIVA — Your Thesis Companion** dikembangkan oleh mahasiswa sebagai bagian dari proyek **Ujian Akhir Semester (UAS) Mobile Programming**.

| Nama Pengembang | NIM |
|---|---|
| **Albertagung H.H. Oey** | **825240004** |
| **Tracy Prycillia Kusmana** | **825240009** |
| **Syahwa Aliah Wandi** | **825240139** |

---

© 2026 **SKRIVA — Your Thesis Companion**. Developed for academic purposes.