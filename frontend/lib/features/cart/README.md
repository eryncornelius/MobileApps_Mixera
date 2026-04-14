# Feature: Cart

Keranjang belanja: item, ringkasan, aksi lanjut ke checkout.

## Struktur

- **`presentation/`** — `cart_page`, widget ringkasan, `CartController`.
- **`data/`** — model keranjang, datasource ke API cart.

## Backend terkait

- Prefix: **`/api/cart/`**.

## Catatan dev

- Controller GetX mengkoordinasi UI dengan state keranjang dari remote/local sesuai implementasi datasource.
