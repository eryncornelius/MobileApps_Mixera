import 'package:flutter/material.dart';

// ============================================================
// WARDROBE FILTER BOTTOM SHEET WIDGET
// ============================================================
// Cara pakai:
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     builder: (_) => WardrobeFilterTabs(
//       selectedStyles: _selectedStyles,
//       onApply: (styles) { ... },
//       onRemove: () { ... },
//     ),
//   );
// ============================================================

class WardrobeFilterTabs extends StatefulWidget {
  // [CONFIG] Style yang sudah terpilih sebelumnya (dari controller)
  final List<String> selectedStyles;

  // [CONFIG] Callback saat user tap "Apply Filters"
  final Function(List<String> selectedStyles) onApply;

  // [CONFIG] Callback saat user tap "Remove" (reset filter)
  final VoidCallback onRemove;

  const WardrobeFilterTabs({
    super.key,
    required this.onApply,
    required this.onRemove,
    this.selectedStyles = const [],
  });

  @override
  State<WardrobeFilterTabs> createState() => _WardrobeFilterTabsState();
}

class _WardrobeFilterTabsState extends State<WardrobeFilterTabs> {
  late List<String> _selected;

  // [CONFIG] Daftar opsi clothing style — tambah/hapus sesuai kebutuhan
  static const List<String> _styleOptions = [
    'Formal',
    'casual',
    'goth',
    'cottagecore',
    'muslim',
    'street wear',
  ];

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedStyles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Pink Header ───────────────────────────────────────
        _buildPinkHeader(context),

        // ── White Body ───────────────────────────────────────
        Container(
          width: double.infinity,
          // [CONFIG] Warna background body filter
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32), // [CONFIG] Padding body
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Title ──────────────────────────────
              const Text(
                'Clothing style',
                style: TextStyle(
                  fontSize: 18, // [CONFIG] Ukuran font judul section
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 20), // [CONFIG] Jarak judul ke chips

              // ── Style Chips ────────────────────────────────
              _buildStyleChips(),
              const SizedBox(height: 40), // [CONFIG] Jarak chips ke tombol apply

              // ── Apply Filters Button ───────────────────────
              _buildApplyButton(context),
            ],
          ),
        ),
      ],
    );
  }

  // ── Pink Header ─────────────────────────────────────────────────
  Widget _buildPinkHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      // [CONFIG] Tinggi header pink
      height: 56,
      decoration: const BoxDecoration(
        // [CONFIG] Warna background header
        color: Color(0xFFF4A7BB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),  // [CONFIG] Border radius top kiri
          topRight: Radius.circular(20), // [CONFIG] Border radius top kanan
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Judul "Filter" ─────────────────────────────────
          const Text(
            'Filter',
            style: TextStyle(
              fontSize: 18, // [CONFIG] Ukuran font judul header
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          // ── Tombol "Remove" ────────────────────────────────
          Positioned(
            right: 12, // [CONFIG] Posisi tombol Remove dari kanan
            child: GestureDetector(
              onTap: () {
                // Reset semua pilihan lalu tutup
                setState(() => _selected.clear());
                widget.onRemove();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, // [CONFIG] Padding horizontal tombol Remove
                  vertical: 6,    // [CONFIG] Padding vertikal tombol Remove
                ),
                decoration: BoxDecoration(
                  // [CONFIG] Warna background tombol Remove
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20), // [CONFIG] Border radius tombol Remove
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 13, // [CONFIG] Ukuran font tombol Remove
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Style Chips Grid ─────────────────────────────────────────────
  Widget _buildStyleChips() {
    return Wrap(
      spacing: 10,   // [CONFIG] Spasi horizontal antar chip
      runSpacing: 12, // [CONFIG] Spasi vertikal antar baris chip
      children: _styleOptions.map((style) {
        final isSelected = _selected.contains(style);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selected.remove(style);
              } else {
                _selected.add(style);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: 18, // [CONFIG] Padding horizontal chip
              vertical: 10,   // [CONFIG] Padding vertikal chip
            ),
            decoration: BoxDecoration(
              // [CONFIG] Warna background chip saat terpilih / tidak
              color: isSelected
                  ? const Color(0xFFF4A7BB)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10), // [CONFIG] Border radius chip
              border: Border.all(
                // [CONFIG] Warna border chip saat terpilih / tidak
                color: isSelected
                    ? const Color(0xFFF4A7BB)
                    : const Color(0xFFD0D0D0),
                width: 1.2, // [CONFIG] Ketebalan border chip
              ),
            ),
            child: Text(
              style,
              style: TextStyle(
                fontSize: 13, // [CONFIG] Ukuran font teks chip
                fontWeight: FontWeight.w400,
                // [CONFIG] Warna teks chip saat terpilih / tidak
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF5A5A5A),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Apply Filters Button ─────────────────────────────────────────
  Widget _buildApplyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52, // [CONFIG] Tinggi tombol Apply Filters
      child: ElevatedButton(
        onPressed: () {
          widget.onApply(_selected);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          // [CONFIG] Warna background tombol Apply Filters
          backgroundColor: const Color(0xFFF4A7BB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // [CONFIG] Border radius tombol
          ),
        ),
        child: const Text(
          'Apply Filters',
          style: TextStyle(
            fontSize: 16, // [CONFIG] Ukuran font tombol
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}