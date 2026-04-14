# Feature: Mix & Match

Rekomendasi outfit dari item wardrobe (dan opsi shop), konfirmasi item, hasil outfit, outfit tersimpan.

## Struktur

- **`presentation/`** — `mix_match_page`, `pick_from_wardrobe_page`, `confirm_items_page`, `outfit_result_page`, `saved_outfits_page`, `MixMatchController`.
- **`data/`** — `mix_match_remote_datasource`, model API mix/match.

## Backend terkait

- Prefix: **`/api/mixmatch/`** — generate mix, hasil, simpan outfit, dsb.

## Catatan dev

- Alur panjang multi-halaman; state utama di `MixMatchController`.
- Pratinjau/hasil bisa bergantung pada job AI di backend; tangani loading & error di UI.
