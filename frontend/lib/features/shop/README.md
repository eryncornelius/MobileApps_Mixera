# Feature: Shop

Katalog produk marketplace, pencarian, detail produk, variasi SKU.

## Struktur

- **`presentation/`** — `shop_page`, `product_detail_page`, grid produk, `ShopController`.
- **`data/`** — model kategori/produk, datasource shop.

## Backend terkait

- Prefix: **`/api/shop/`**.

## Catatan dev

- URL gambar produk biasanya absolut dari `MEDIA_URL` backend; pastikan base URL bisa diakses dari emulator/perangkat.
