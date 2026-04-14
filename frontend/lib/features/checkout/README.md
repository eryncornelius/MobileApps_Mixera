# Feature: Checkout

Alur pemesanan: alamat, ongkir, metode bayar, kartu tersimpan, 3DS/WebView bila perlu, halaman selesai beli.

## Struktur

- **`presentation/`** — `checkout_page`, `card_3ds_page`, `card_tokenize_page`, `purchase_complete_page`, `CheckoutController`, widget alamat & pembayaran.
- **`data/`** — request checkout, order, kartu tersimpan; datasource checkout & pembayaran kartu.

## Backend terkait

- **`/api/cart/`** — konteks berat/ringkasan bila digunakan.
- **`/api/orders/`** — pembuatan order.
- **`/api/payments/`** — tokenisasi/charge kartu (sesuai endpoint backend).

## Catatan dev

- Pastikan `API_BASE_URL` di `.env` mengarah ke server yang sama dengan konfigurasi payment backend.
