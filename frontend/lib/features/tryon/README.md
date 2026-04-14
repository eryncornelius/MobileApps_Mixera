# Feature: Try-On

Virtual try-on: upload foto orang & pakaian, hasil, simpan hasil, daftar try-on / foto persona.

## Struktur

- **`presentation/`** — halaman alur try-on, hasil, `TryOnController`.
- **`data/`** — `tryon_remote_datasource`, model request/result.

## Backend terkait

- Prefix: **`/api/tryon/`**.

## Catatan dev

- Proses bisa async/lama; tampilkan loading dan penanganan error dari backend (`error_message` bila ada).
