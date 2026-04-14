# Feature: Profile

Profil user, alamat, wishlist, keamanan (ubah password, kunci sidik jari), foto persona try-on, try-on tersimpan.

## Struktur

- **`presentation/`** — `profile_page`, edit profil, alamat, `security_page`, wishlist, halaman foto orang / saved try-on.
- **`data/`** — `profile_remote_datasource`, model alamat & profil.
- **`presentation/controllers/`** — `ProfileController`.

## Backend terkait

- Prefix utama: **`/api/users/`** — `me/`, `profile/`, `addresses/`, `change-password/`, `notification-settings/`.
- Try-on / persona memakai **`/api/tryon/`** dari datasource terkait (cek import di halaman).

## Catatan dev

- Akun sosial (Google/Facebook) tidak mengubah password lewat app; UI sudah menyesuaikan di Security.
