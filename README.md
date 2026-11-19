# QUIZIFY — Aplikasi Kuis Interaktif

**QUIZIFY** adalah proyek aplikasi kuis edukatif berbasis Flutter yang terhubung dengan REST API Laravel. Aplikasi dirancang agar pengguna dapat memilih kuis, menjawab pertanyaan, melihat hasil, dan membandingkan skor pada leaderboard. Proyek ini juga mencakup pengelolaan template kuis dan pertanyaan untuk admin.

> **Status:** proyek pembelajaran/portofolio. Repository berisi aplikasi Flutter dan backend Laravel. Ketersediaan fitur di kode belum berarti seluruh alurnya telah diuji pada perangkat baru.

## Fitur

**Pengguna**
- Registrasi dan login.
- Melihat kategori serta template kuis.
- Mengambil pertanyaan berdasarkan template kuis.
- Mengirim hasil kuis setelah login.
- Melihat leaderboard dan dashboard pengguna.

**Admin**
- Menambahkan, memperbarui, dan menghapus template kuis.
- Menambahkan, memperbarui, dan menghapus pertanyaan template.
- Endpoint pengelolaan admin dilindungi middleware `auth:sanctum` dan `admin`.

Daftar ini disusun dari rute backend dan metode pada klien Flutter. Detail tampilan serta keberhasilan alur end-to-end perlu diverifikasi melalui pengujian aplikasi.

## Teknologi

| Bagian | Teknologi |
| --- | --- |
| Aplikasi | Flutter, Dart |
| State management dan navigasi | Provider, GoRouter |
| HTTP client | `http` |
| Backend API | PHP 8.2+, Laravel 12 |
| Autentikasi API | Laravel Sanctum 4 |
| Database | Konfigurasi Laravel; MySQL digunakan menurut deskripsi proyek, perlu disesuaikan dengan `.env` lokal |

## Struktur proyek

```text
QUIZIFY/
├── lib/                   # Source code Flutter
│   └── services/api/      # Klien REST API
├── assets/                # Aset aplikasi
├── android/               # Konfigurasi Android
├── ios/                   # Konfigurasi iOS
├── quizify_backend/       # Backend Laravel
│   ├── app/
│   ├── database/          # Migration dan seeder
│   ├── routes/api.php     # Rute REST API
│   ├── composer.json
│   └── .env.example
├── pubspec.yaml
└── README.md
```

## Menjalankan secara lokal

### Prasyarat
- Flutter SDK dengan Dart SDK yang kompatibel dengan `sdk: ^3.11.0` pada `pubspec.yaml`.
- PHP 8.2 atau lebih baru dan Composer.
- Server database sesuai konfigurasi Laravel lokal (misalnya MySQL).
- Android Emulator atau perangkat yang telah dikonfigurasi untuk mengakses backend.

### 1. Siapkan backend

Dari direktori root repository:

```powershell
cd quizify_backend
composer install
Copy-Item .env.example .env
php artisan key:generate
```

Periksa `.env` dan sesuaikan `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, serta `DB_PASSWORD` dengan database lokal. **Jangan mengunggah `.env` ke GitHub.** Setelah database tersedia:

```powershell
php artisan migrate
php artisan serve --host=0.0.0.0 --port=8000
```

Jika proyek membutuhkan data awal, periksa terlebih dahulu isi seeder di `quizify_backend/database/seeders/` sebelum menjalankan `php artisan db:seed`.

### 2. Siapkan Flutter

Buka terminal lain di root repository:

```powershell
flutter pub get
flutter run
```

Periksa `lib/services/api/quiz_api.dart` sebelum dijalankan. Untuk **Android Emulator**, alamat backend yang berjalan di komputer host biasanya:

```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

Untuk **perangkat fisik**, ganti `10.0.2.2` dengan alamat IP komputer pada jaringan yang dapat dijangkau perangkat. Pastikan firewall, binding server, dan konfigurasi jaringan mengizinkan koneksi. Alamat `10.0.2.2` bukan alamat layanan publik.

## Ringkasan endpoint API

Semua path berikut relatif terhadap `/api`.

| Metode | Endpoint | Akses berdasarkan rute |
| --- | --- | --- |
| POST | `/register`, `/login` | Publik |
| POST | `/logout` | Sanctum |
| GET | `/categories`, `/quiz-templates` | Publik |
| GET | `/template-questions/{quizTemplateId}` | Publik |
| GET | `/leaderboard` | Publik |
| POST | `/quiz-results` | Sanctum |
| GET | `/user-dashboard` | Sanctum |
| POST, PUT, DELETE | `/quiz-templates` dan `/quiz-templates/{id}` | Sanctum + admin |
| POST, PUT, DELETE | `/template-questions` dan `/template-questions/{id}` | Sanctum + admin |
| GET, POST, PUT, DELETE | `/quizzes` dan `/quizzes/{id}` | Tidak ada middleware eksplisit pada file rute |
| GET | `/quizzes/{id}/play` | Tidak ada middleware eksplisit pada file rute |

**Catatan keamanan:** Endpoint mutasi `/quizzes` belum terlihat dilindungi middleware pada `routes/api.php` yang diperiksa. Perlu audit kebijakan otorisasi di controller sebelum backend dipublikasikan untuk penggunaan nyata.

## Dokumentasi tampilan

Screenshot asli aplikasi akan ditambahkan setelah dikumpulkan, misalnya: halaman login, kategori kuis, pengerjaan soal, hasil kuis, leaderboard, dan panel admin. Bagian ini sengaja belum menggunakan gambar contoh agar tidak menampilkan tampilan yang tidak sesuai implementasi.

## Catatan pengembangan

- API mendukung header `Authorization: Bearer <token>` untuk permintaan yang memerlukan login.
- Respons dan format data dapat dilihat pada controller Laravel dan implementasi klien Flutter.
- Untuk deployment produksi diperlukan konfigurasi HTTPS, variabel lingkungan yang aman, peninjauan hak akses endpoint, serta pengujian integrasi.

## Pengembang

**Arlen Prima Dinova**  
GitHub: [@arlendevID](https://github.com/arlendevID)

Repository: https://github.com/arlendevID/QUIZIFY
