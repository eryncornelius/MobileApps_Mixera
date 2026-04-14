# MIXÉRA — Frontend (Flutter)

Aplikasi mobile pembeli + mode seller; API memakai backend Django di folder `../backend`.

## Mulai

1. Salin `.env.example` → `.env` dan set **`API_BASE_URL`** (mis. `http://10.0.2.2:8000` untuk emulator Android menuju host).
2. `flutter pub get`
3. `flutter run`

## Dokumentasi per fitur

Setiap modul UI utama punya **`README.md`** di dalam foldernya:

`lib/features/<nama_fitur>/README.md` — isi: tujuan fitur, lapisan `data` / `presentation`, prefix API yang dipakai.

## Jaringan & auth

- Ringkasan interceptor token: `lib/core/network/README.md`.
