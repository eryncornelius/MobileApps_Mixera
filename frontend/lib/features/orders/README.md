# Feature: Orders

Riwayat pesanan pembeli, detail pesanan, status & pelacakan bila tersedia.

## Struktur

- **`presentation/`** — `orders_page`, `order_detail_page`, widget status, use case/domain bila ada.
- **`data/`** — datasource orders, model tracking & order.

## Backend terkait

- Prefix: **`/api/orders/`**.

## Catatan dev

- Detail order mengikuti ID dari navigasi; pastikan serializer backend selaras dengan model Dart.
