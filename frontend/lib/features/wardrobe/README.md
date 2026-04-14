# Feature: Wardrobe

Lemari pakaian digital: unggah item, kategori/tag, detail item, batch review; dipakai mix-match & try-on.

## Struktur

- **`presentation/`** — `wardrobe_page`, detail, batch review, `WardrobeController`.
- **`data/`** — model wardrobe API, `wardrobe_remote_datasource`.

## Backend terkait

- Prefix: **`/api/wardrobe/`** — CRUD item, analisis/tagging AI sesuai endpoint backend.

## Catatan dev

- Gambar dari `image_picker` perlu base URL media yang sama dengan shop bila disajikan sebagai URL relatif.
