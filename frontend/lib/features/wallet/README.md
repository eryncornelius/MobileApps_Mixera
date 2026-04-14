# Feature: Wallet

Dompet pengguna: saldo, riwayat transaksi, top-up (mengikuti integrasi payment backend).

## Struktur

- **`presentation/`** — halaman wallet, tambah saldo, tile transaksi, `WalletController`.
- **`data/`** — datasource wallet & payment top-up.

## Backend terkait

- Prefix: **`/api/wallet/`** — saldo & transaksi.
- Pembayaran top-up bisa melalui **`/api/payments/`** tergantung implementasi datasource.

## Catatan dev

- Jaga konsistensi format nominal (desimal) dengan API.
