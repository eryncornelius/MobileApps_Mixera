# Mixera

**Mixera** adalah aplikasi mobile fashion e-commerce berbasis AI yang dikembangkan sebagai proyek kolaborasi mahasiswa **Angkatan 25 DBT (Digital Business & Technology) Universitas Prasmul (Prasetiya Mulya)**. Aplikasi ini menggabungkan pengalaman belanja fashion modern dengan fitur kecerdasan buatan untuk membantu pengguna mengeksplorasi gaya berpakaian, mengelola lemari baju digital, serta mencoba pakaian secara virtual sebelum membeli.

---

## Fitur Utama

### Untuk Pembeli

| Fitur | Deskripsi |
|-------|-----------|
| **Autentikasi** | Login/register via email, Google, Facebook; OTP email untuk reset password; biometric login (fingerprint/face ID) |
| **Toko** | Browse produk fashion, pencarian, filter kategori, wishlist, detail produk lengkap dengan galeri gambar |
| **Keranjang & Checkout** | Tambah ke keranjang, pilih alamat pengiriman, kalkulasi ongkir real-time via Biteship, checkout via E-Wallet atau Kartu Kredit |
| **Pembayaran** | E-Wallet internal, top-up via Midtrans Snap, pembayaran kartu kredit native (tokenisasi + 3DS via Midtrans Core API) |
| **Pesanan** | Riwayat pesanan, detail per pesanan, pelacakan resi pengiriman real-time via Biteship |
| **Wardrobe** | Upload foto pakaian, deteksi & klasifikasi item oleh AI (GPT-4o Vision), kelola koleksi lemari digital per kategori |
| **Mix & Match** | Rekomendasi outfit AI berdasarkan item wardrobe: pilih 2–5 item, dapatkan saran kombinasi gaya, skor kecocokan, dan tips styling. Preview outfit di-generate oleh AI (gpt-image) |
| **Virtual Try-On** | Coba pakaian secara virtual menggunakan foto diri, diproses oleh model AI berbasis OpenAI Image |
| **Saved Outfits** | Simpan hasil rekomendasi Mix & Match untuk diakses kembali kapan saja |
| **Notifikasi** | Notifikasi in-app (status pesanan, promo) dan push notification via Firebase Cloud Messaging (FCM) |
| **Profil** | Edit profil, kelola alamat pengiriman, saved cards, keamanan akun (ganti password, hapus akun) |

### Untuk Penjual (Seller Dashboard)

| Fitur | Deskripsi |
|-------|-----------|
| **Dashboard** | Ringkasan statistik: total pesanan, produk aktif, stok rendah, estimasi saldo |
| **Manajemen Produk** | CRUD produk (nama, harga, deskripsi, varian ukuran & stok), upload foto, nonaktifkan produk |
| **Manajemen Pesanan** | Lihat & filter pesanan (processing/shipped/completed), isi nomor resi, tandai dikirim/selesai, lihat alamat penerima |
| **Keuangan** | Riwayat pendapatan, ekspor CSV, permintaan payout, histori payout |
| **Kalkulasi Ongkir** | Simulasi ongkos kirim berdasarkan berat dan tujuan via Biteship |
| **Notifikasi Seller** | Notifikasi khusus seller untuk pesanan masuk dan perubahan status |

---

## Arsitektur Sistem

```
┌──────────────────────────────────┐
│         Flutter Mobile App       │
│         (Android / iOS)          │
│                                  │
│  Feature Modules:                │
│  auth · shop · cart · checkout   │
│  orders · wallet · wardrobe      │
│  mix_match · tryon · seller      │
│  profile · notifications         │
└────────────┬─────────────────────┘
             │ REST API (JWT Bearer)
             ▼
┌──────────────────────────────────┐
│        Django REST API           │
│  (Python 3.14 / Django 6.0)      │
│                                  │
│  Apps:                           │
│  users · shop · cart · orders    │
│  payments · wallet · sellers     │
│  wardrobe · mixmatch · tryon     │
└──┬──────┬──────┬────────┬────────┘
   │      │      │        │
   ▼      ▼      ▼        ▼
OpenAI  Midtrans Biteship Firebase
  AI    Payment  Shipping  FCM Push
```

---

## Tech Stack

### Frontend — Flutter

| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **Flutter** | 3.41.6 | Framework mobile cross-platform (Android & iOS) |
| **Dart** | ^3.10.4 | Bahasa pemrograman |
| **GetX** | ^4.7.3 | State management, dependency injection, routing |
| **Dio** | ^5.9.2 | HTTP client, interceptor JWT auto-refresh |
| **Flutter Secure Storage** | ^10.0.0 | Penyimpanan token JWT yang aman di keychain/keystore |
| **Google Sign-In** | ^7.2.0 | OAuth login via Google |
| **Flutter Facebook Auth** | ^7.1.6 | OAuth login via Facebook |
| **Firebase Core** | ^3.0.0 | Firebase SDK base |
| **Firebase Messaging** | ^15.2.10 | Push notification (FCM) |
| **Flutter Local Notifications** | ^17.0.0 | Tampilan notifikasi di system tray |
| **Local Auth** | ^3.0.1 | Biometric authentication (fingerprint / face ID) |
| **WebView Flutter** | ^4.10.0 | 3DS payment flow, Midtrans Snap payment page |
| **Image Picker** | ^1.1.2 | Upload foto dari kamera atau galeri |
| **Google Fonts** | ^8.0.2 | Tipografi |
| **flutter_dotenv** | ^6.0.0 | Konfigurasi environment variable |

### Backend — Django

| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **Python** | 3.14.3 | Runtime |
| **Django** | 6.0.3 | Web framework |
| **Django REST Framework** | 3.17.1 | RESTful API |
| **SimpleJWT** | 5.5.1 | Autentikasi JWT (access + refresh token) |
| **django-cors-headers** | 4.9.0 | CORS handling untuk mobile client |
| **Firebase Admin SDK** | 7.4.0 | Kirim push notification FCM dari server |
| **OpenAI SDK** | 2.30.0 | AI: Mix & Match, Virtual Try-On, Wardrobe item detection |
| **Requests** | 2.33.0 | HTTP client untuk integrasi Midtrans & Biteship |
| **environs / python-dotenv** | — | Manajemen konfigurasi `.env` |

### Layanan Pihak Ketiga

| Layanan | Kegunaan |
|---------|----------|
| **OpenAI API** (GPT-4o-mini, gpt-image) | Rekomendasi outfit Mix & Match, generate preview image outfit, virtual try-on, deteksi & klasifikasi item wardrobe |
| **Midtrans** (Core API + Snap) | Payment gateway: tokenisasi kartu kredit, 3DS authentication, top-up wallet via Snap |
| **Biteship** | Kalkulasi ongkos kirim real-time, pelacakan status resi pengiriman |
| **Firebase Cloud Messaging (FCM)** | Push notification ke perangkat Android/iOS |
| **Google OAuth 2.0** | Login via akun Google |
| **Facebook OAuth** | Login via akun Facebook |

---

## Struktur Proyek

```
MobileApps_Mixera/
├── backend/                    # Django REST API
│   ├── backend/                # Settings, URL routing, WSGI
│   ├── users/                  # Autentikasi, profil, OTP, FCM token, notifikasi user
│   ├── shop/                   # Produk, kategori, wishlist
│   ├── cart/                   # Keranjang belanja, kalkulasi ongkir
│   ├── orders/                 # Pesanan, tracking resi via Biteship
│   ├── payments/               # Midtrans Core API, saved cards, 3DS webhook
│   ├── wallet/                 # Saldo, top-up Snap, riwayat transaksi
│   ├── sellers/                # Seller dashboard, produk, pesanan, keuangan, payout
│   ├── wardrobe/               # Upload & deteksi item pakaian via AI
│   ├── mixmatch/               # AI outfit recommendation & preview image
│   └── tryon/                  # Virtual try-on via AI
│
└── frontend/                   # Flutter App
    └── lib/
        ├── app/
        │   ├── routes/         # AppRouter, RouteNames
        │   └── theme/          # AppColors, AppTextStyles
        ├── core/
        │   ├── network/        # Dio setup, JWT interceptor, base URLs
        │   └── services/       # FcmService
        ├── di/                 # GetX dependency injection (injection.dart)
        └── features/
            ├── auth/           # Login, register, OTP, Google, Facebook, biometric
            ├── home/           # Halaman utama, rekomendasi, on-sale
            ├── shop/           # Product grid, search, product detail
            ├── cart/           # Keranjang belanja
            ├── checkout/       # Checkout flow, address & payment selector
            ├── orders/         # Daftar & detail pesanan, tracking pengiriman
            ├── wallet/         # Saldo, top-up, riwayat transaksi
            ├── wardrobe/       # Lemari digital, upload pakaian, kategori
            ├── mix_match/      # AI outfit, pilih item, result, saved outfits
            ├── tryon/          # Virtual try-on
            ├── profile/        # Profil, alamat, wishlist, keamanan, saved cards
            ├── seller/         # Seller dashboard, produk, pesanan, keuangan
            └── notifications/  # In-app notification center
```

---

## Cara Menjalankan

### Backend

```bash
cd backend

# Install dependencies
pip install -r requirements.txt

# Salin dan isi file environment
cp .env.example .env

# Jalankan migrasi database
python manage.py migrate

# Jalankan server
python manage.py runserver 0.0.0.0:8000
```

**Variabel `.env` yang diperlukan:**

```env
SECRET_KEY=...
DEBUG=True
ALLOWED_HOSTS=*

MIDTRANS_SERVER_KEY=SB-...
MIDTRANS_CLIENT_KEY=SB-...
MIDTRANS_IS_PRODUCTION=False

BITESHIP_API_KEY=...
BITESHIP_ORIGIN_POSTAL_CODE=12430

OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4o-mini

FIREBASE_SERVICE_ACCOUNT_JSON=backend/firebase-adminsdk.json
BACKEND_PUBLIC_URL=http://<IP_SERVER>:8000
```

### Frontend

```bash
cd frontend

# Install dependencies
flutter pub get

# Salin dan isi file environment
cp .env.example .env
# Set BASE_URL ke IP server backend (bukan localhost jika pakai device fisik)

# Jalankan di device / emulator
flutter run
```

> **Catatan device fisik:** Gunakan IP LAN server (misal `http://192.168.x.x:8000`) atau ngrok agar device Android/iOS bisa mengakses backend. `http://127.0.0.1:8000` hanya bekerja di emulator.

---

## Tim

Proyek ini merupakan bagian dari program studi **DBT (Digital Business & Technology) Angkatan 25 — Universitas Prasmul (Prasetiya Mulya)**.

---

## Lisensi

Proyek ini dibuat untuk keperluan akademik. Penggunaan di luar lingkup akademik memerlukan izin dari tim pengembang.
