# MIXÉRA — Backend (Django)

API REST untuk aplikasi mobile: auth JWT, marketplace, wardrobe, mix & match AI, virtual try-on, pembayaran, dompet, seller.

Dokumentasi dipusatkan di **satu file ini** supaya setup dan daftar modul mudah dicari. Detail endpoint ada di masing-masing `urls.py` per app.

## Prasyarat

- Python 3.10+ (sesuai environment proyek Anda)
- `pip` / virtual environment

## Setup cepat

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
copy .env.example .env   # lalu isi nilai rahasia & API key
python manage.py migrate
python manage.py runserver
```

Basis URL API (relatif root server): **`/api/<nama_modul>/`** — lihat `backend/urls.py`.

## Ringkasan app Django

| App | URL API | Peran singkat |
|-----|---------|----------------|
| **users** | `/api/users/` | Registrasi, OTP, login JWT, Google/Facebook, profil, alamat, notifikasi user, FCM token |
| **shop** | `/api/shop/` | Katalog produk, variasi, moderasi seller |
| **cart** | `/api/cart/` | Keranjang, estimasi berat/ongkir terkait checkout |
| **orders** | `/api/orders/` | Pesanan pembeli, item, ongkir |
| **payments** | `/api/payments/` | Midtrans / kartu / callback notifikasi |
| **wallet** | `/api/wallet/` | Saldo & transaksi dompet |
| **wardrobe** | `/api/wardrobe/` | Item lemari digital, deteksi/tagging, cutout AI opsional |
| **mixmatch** | `/api/mixmatch/` | Rekomendasi outfit, hasil mix, preview gambar |
| **tryon** | `/api/tryon/` | Virtual try-on, foto persona, hasil |
| **sellers** | `/api/sellers/` | Dashboard seller, produk seller, pesanan seller, saldo, ongkir (Biteship), dsb. |

## Konfigurasi penting (`.env`)

- **JWT** — durasi access/refresh (lihat `settings.py` / `.env.example`).
- **OPENAI_*** — fitur AI wardrobe / mix / try-on / cutout (model gambar vs chat sesuai variabel).
- **MIDTRANS_*** — pembayaran.
- **BITESHIP_*** — ongkir (opsional / stub sesuai implementasi).
- **BACKEND_PUBLIC_URL** — URL publik agar path media absolut benar untuk klien mobile.
- **FIREBASE_SERVICE_ACCOUNT_JSON** — push FCM (opsional).

Contoh variabel ada di **`.env.example`** (jangan commit file `.env`).

## Per app README terpisah?

Tidak wajib. Satu `README.md` di folder `backend/` ini cukup untuk tim/kampus. Jika satu modul membengkak (mis. payments + webhook), boleh tambah `backend/payments/README.md` nanti secara selektif.

## Admin & media

- Django Admin: `/admin/` (user staff superuser).
- `DEBUG=True`: file media dilayani lewat static URL di `urls.py`; produksi gunakan storage/object storage yang sesuai.

## Seed / utilitas

- Perintah management custom (jika ada): `python manage.py help` — contoh demo marketplace cek `users.management.commands` bila tersedia.
