# Skrip presentasi — Mixera (alur utama)

Dokumen ini untuk **dibacakan/dimodifikasi** saat demo ke penguji/dosen/investor. Sesuaikan durasi: inti demo **~8–12 menit**, total **~15–20 menit** termasuk pembuka & Q&A.

---

## 0. Sebelum mulai (cek cepat)

- [ ] HP / emulator sudah login akun demo (atau siap register cepat).
- [ ] Backend & API jalan; koneksi internet stabil.
- [ ] Slide deck (opsional): logo, diagram arsitektur dari `README.md`, 1 screenshot fitur AI.
- [ ] Matikan notifikasi ganggu; brightness layar cukup.

---

## 1. Pembuka (~1 menit)

**Kalimat pembuka (contoh):**

> “Selamat [pagi/siang/malam], kami dari tim Mixera. Kami akan memperkenalkan **Mixera** — aplikasi mobile fashion berbasis AI untuk belanja, mengelola lemari digital, dan mencoba gaya secara virtual. Setelah pengenalan singkat, kami **demo langsung** di perangkat ini.”

**Hook satu kalimat:**

> “Masalah yang kami tangani: orang sering **ragu membeli fashion online** karena tidak yakin cocok, lemari pakaian sulit dikelola, dan penjual butuh dashboard yang ringkas. Mixera menggabungkan **e-commerce + AI wardrobe + virtual try-on** dalam satu aplikasi.”

**Struktur presentasi (bilang ke audiens):**

> “Alurnya: konteks singkat → solusi & arsitektur ringkas → **demo alur pembeli** → **demo penjual** → penutup.”

---

## 2. Konteks & solusi (~2 menit)

### Masalah (3 poin, singkat)

1. **Keputusan belanja** — user ingin tahu kombinasi outfit dan cocok tidak di tubuh mereka.  
2. **Lemari digital** — koleksi pakaian di rumah tidak terdokumentasi; sulit mix-and-match.  
3. **Penjual UMKM / seller** — butuh kelola produk, pesanan, dan saldo tanpa tool yang berat.

### Solusi Mixera (mapping fitur)

| Kebutuhan | Fitur di app |
|-----------|----------------|
| Belanja & bayar | Toko, keranjang, checkout, wallet, Midtrans |
| Kelola & outfit AI | Wardrobe (upload → deteksi AI), Mix & Match, saved outfits |
| Coba sebelum beli | Virtual try-on (AI image) |
| Setelah beli | Pesanan, tracking pengiriman |
| Penjual | Seller dashboard: produk, pesanan, saldo |

**Kalimat transisi ke teknis:**

> “Secara teknis, aplikasi ini **Flutter** untuk frontend, **Django REST** untuk backend, terintegrasi **OpenAI** untuk deteksi pakaian dan rekomendasi, **Midtrans** pembayaran, **Biteship** ongkir & resi, dan **Firebase** untuk push notification.”

*(Opsional: tunjukkan diagram arsitektur di `README.md` — 30 detik.)*

---

## 3. Demo — alur pembeli (~6–8 menit)

**Instruksi ke audiens:**  
> “Sekarang kami tunjukkan **satu alur utuh** dari sudut pembeli.”

### Urutan demo (ikuti ini)

1. **Splash & onboarding singkat** (jika ada) — kesan brand MIXÉRA.  
2. **Home** — highlight banner / rekomendasi / shortcut ke wardrobe atau shop.  
3. **Autentikasi** *(bisa diskip jika sudah login)* — login email/Google atau biometric jika sudah diset.  
4. **Shop**  
   - Cari produk / filter kategori.  
   - Buka **detail produk** (foto, varian, harga).  
5. **Keranjang** — tambah item; cek isi cart.  
6. **Checkout**  
   - Pilih alamat; lihat **ongkir** (Biteship).  
   - Pilih metode bayar (wallet / kartu sesuai yang siap demo).  
7. **Wallet / top-up** *(singkat jika waktu pas)* — top-up atau saldo cukup untuk demo.  
8. **Pesanan**  
   - Tab **Ongoing / Delivered / Canceled**; buka **detail pesanan**; tunjuk **resi** jika ada.  
9. **Wardrobe** *(inti diferensiasi)*  
   - Upload foto pakaian (maks sesuai app) → **review hasil deteksi AI** → konfirmasi ke wardrobe.  
   - Buka **kategori** → tunjuk item, **favourite**, **edit nama**, filter **style / favourites**.  
10. **Mix & Match** *(jika stabil untuk demo)*  
    - Pilih beberapa item → lihat rekomendasi / skor / tips.  
11. **Try-on** *(opsional, sering paling lambat)*  
    - Hanya jika API & waktu siap; sebut sebagai “fitur coba visual dengan AI”.  
12. **Notifikasi / profil** *(15 detik)* — notifikasi in-app atau edit profil singkat.

**Narasi penutup demo pembeli:**

> “Itu alur utama pembeli: dari eksplorasi, transaksi, hingga **menggunakan AI untuk wardrobe dan gaya** — tanpa harus pindah aplikasi.”

---

## 4. Demo — penjual (~2–3 menit)

**Transisi:**

> “Mixera juga punya mode **penjual**. Kami switch ke Seller Dashboard.”

### Urutan demo seller

1. **Masuk mode penjual** (dari profil / menu sesuai app).  
2. **Dashboard** — ringkasan pesanan, stok rendah, saldo.  
3. **Produk** — daftar; tambah/edit produk *(singkat)*.  
4. **Pesanan** — filter status; buka satu pesanan; **isi resi** → **tandai dikirim** → *(jika data demo sudah shipped)* **tandai selesai**.  
5. **Saldo / payout** *(sekilas)* — histori atau permintaan payout jika relevan.

**Narasi:**

> “Seller mengelola katalog dan fulfillment dalam satu tempat; status pesanan mengalir ke pembeli dan notifikasi.”

---

## 5. Penutup & Q&A (~2 menit)

**Ringkasan 3 poin:**

1. **Mixera** = fashion commerce + **AI wardrobe & styling** + try-on.  
2. **Stack** = Flutter + Django + integrasi pembayaran, logistik, dan AI.  
3. **Siap uji** = APK bisa diuji paralel di banyak perangkat dengan backend yang sama.

**Ajakan Q&A:**

> “Demikian alur utama kami. Kami buka untuk pertanyaan — teknis, bisnis, atau skenario edge case.”

**Cadangan jawaban singkat (jika ditanya):**

- **Skalabilitas:** backend stateless REST, bisa horizontal scale; bottleneck biasanya AI & payment provider.  
- **Keamanan:** JWT, secure storage token; pembayaran lewat Midtrans.  
- **Privasi:** foto wardrobe/try-on diproses sesuai kebijakan API; jelaskan jika ada dokumentasi internal.

---

## Lembar cheat — durasi dipangkas (~10 menit total)

1. Pembuka + masalah+solutsi **1,5 menit**  
2. Demo: **login → shop → detail → cart → checkout (sampai sukses/bayar mock)** **4 menit**  
3. **Wardrobe: upload → review → 1 kategori + favourite** **3 menit**  
4. Seller: **dashboard + 1 pesanan update resi** **1,5 menit**  
5. Penutup **30 detik**

---

## Catatan presenter

- **Jangan** panjangkan teori jika penguji minta demo: **prioritaskan layar**.  
- Jika **API error**, sebutkan: “Ini ketergantungan jaringan / key demo — di lingkungan produksi kami …” lalu loncat ke layar yang masih jalan.  
- Sebut **nama anggota tim** per blok demo jika presentasi berkelompok.

---

*File ini bisa disalin ke Google Docs / PowerPoint speaker notes. Perbarui angka durasi setelah latihan dry-run.*
