import 'package:flutter/material.dart';
import '../widgets/wardrobe_grid.dart' show CategoryCard;

// ============================================================
// KONFIGURASI LAYOUT:
// - [CONFIG] Background color seluruh halaman
// - [CONFIG] AppBar title & subtitle style
// - [CONFIG] Add Clothes button style
// - [CONFIG] Saved Outfits card style
// - [CONFIG] Category grid layout (crossAxisCount, spacing, dll)
// ============================================================

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  // [CONFIG] Data kategori wardrobe — tambah/hapus kategori di sini
  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Outer', 'count': 3, 'image': 'assets/images/outer.png'},
    {'label': 'Top', 'count': 10, 'image': 'assets/images/top.png'},
    {'label': 'Bags', 'count': 6, 'image': 'assets/images/bags.png'},
    {'label': 'Bottom', 'count': 8, 'image': 'assets/images/bottom.png'},
    {'label': 'Accessories', 'count': 9, 'image': 'assets/images/accessories.png'},
    {'label': 'Shoes', 'count': 9, 'image': 'assets/images/shoes.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [CONFIG] Warna background halaman
      backgroundColor: const Color(0xFFFCEEF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20), // [CONFIG] Padding horizontal konten
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Top Bar ──────────────────────────────────────
              _buildTopBar(),
              const SizedBox(height: 6), // [CONFIG] Jarak antara brand & judul

              // ── Title & Subtitle ─────────────────────────────
              _buildHeader(),
              const SizedBox(height: 20), // [CONFIG] Jarak judul ke tombol

              // ── Add Clothes Button ───────────────────────────
              _buildAddClothesButton(),
              const SizedBox(height: 16), // [CONFIG] Jarak tombol ke saved outfits

              // ── Saved Outfits Card ───────────────────────────
              _buildSavedOutfitsCard(),
              const SizedBox(height: 20), // [CONFIG] Jarak saved outfits ke grid

              // ── Category Grid ────────────────────────────────
              _buildCategoryGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Bar: Brand + Bell Icon ──────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 12), // [CONFIG] Padding top bar dari SafeArea
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // [CONFIG] Brand name style
          const Text(
            'MIXÉRA',
            style: TextStyle(
              fontFamily: 'Serif', // [CONFIG] Ganti font brand sesuai kebutuhan
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: Color(0xFFE8A0B0), // [CONFIG] Warna teks brand
            ),
          ),
          const Spacer(),
          // [CONFIG] Bell icon
          Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFFE8A0B0), // [CONFIG] Warna icon notifikasi
            size: 24,
          ),
        ],
      ),
    );
  }

  // ── Header Title & Subtitle ─────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // [CONFIG] Judul halaman
        const Text(
          'Wardrobe',
          style: TextStyle(
            fontSize: 32, // [CONFIG] Ukuran font judul
            fontWeight: FontWeight.w300,
            color: Color(0xFF2D2D2D), // [CONFIG] Warna judul
          ),
        ),
        const SizedBox(height: 4),
        // [CONFIG] Subtitle halaman
        const Text(
          'Keep track of what you own',
          style: TextStyle(
            fontSize: 13, // [CONFIG] Ukuran font subtitle
            color: Color(0xFF9E9E9E), // [CONFIG] Warna subtitle
          ),
        ),
      ],
    );
  }

  // ── Add Clothes Button ──────────────────────────────────────────
  Widget _buildAddClothesButton() {
    return SizedBox(
      width: double.infinity,
      height: 48, // [CONFIG] Tinggi tombol
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigate to AddClothingPage
        },
        style: ElevatedButton.styleFrom(
          // [CONFIG] Warna tombol Add Clothes
          backgroundColor: const Color(0xFFF4A7BB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // [CONFIG] Border radius tombol
          ),
        ),
        child: const Text(
          '+ Add Clothes',
          style: TextStyle(
            fontSize: 15, // [CONFIG] Ukuran font teks tombol
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ── Saved Outfits Card ──────────────────────────────────────────
  Widget _buildSavedOutfitsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // [CONFIG] Padding card
      decoration: BoxDecoration(
        color: Colors.white, // [CONFIG] Warna background card saved outfits
        borderRadius: BorderRadius.circular(16), // [CONFIG] Border radius card
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08), // [CONFIG] Warna shadow card
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // [CONFIG] Icon love / heart
          const Icon(
            Icons.favorite,
            color: Color(0xFFF4A7BB), // [CONFIG] Warna icon heart
            size: 22,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // [CONFIG] Teks judul saved outfits
              Text(
                'Saved Outfits',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              SizedBox(height: 2),
              // [CONFIG] Teks keterangan jumlah outfit tersimpan
              Text(
                'You have 4 Outfits', // [CONFIG] Ganti teks sesuai data dinamis
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
          const Spacer(),
          // [CONFIG] Preview outfit image di saved outfits card
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // [CONFIG] Border radius thumbnail
            child: Image.asset(
              'assets/images/outfit_preview.png', // [CONFIG] Ganti dengan asset/network image
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEEF0),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Grid ───────────────────────────────────────────────
  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // [CONFIG] Jumlah kolom grid
        crossAxisSpacing: 12, // [CONFIG] Spasi horizontal antar kartu
        mainAxisSpacing: 12, // [CONFIG] Spasi vertikal antar kartu
        childAspectRatio: 1.0, // [CONFIG] Rasio lebar:tinggi kartu kategori
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return CategoryCard(
          label: category['label'] as String,
          count: category['count'] as int,
          imagePath: category['image'] as String,
          onTap: () {
            // TODO: Navigate to WardrobeDetailPage dengan kategori terpilih
          },
        );
      },
    );
  }
}
