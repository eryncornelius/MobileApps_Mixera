import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

// Widget terpisah untuk bottom action bar di AddClothingPage
// Berisi tombol Cancel + Add to Wardrobe + badge count
//
// Cara pakai di add_clothing_page.dart:
//   AddClothingBottomBar(
//     selectedCount: _selectedCount,
//     onCancel: () => Navigator.pop(context),
//     onAdd: () { /* simpan ke wardrobe */ },
//   ),
// ============================================================

class AddClothingBottomBar extends StatelessWidget {
  // [CONFIG] Jumlah item yang dipilih — tampil sebagai badge di tombol Add
  final int selectedCount;

  // [CONFIG] Callback tombol Cancel
  final VoidCallback onCancel;

  // [CONFIG] Callback tombol Add to Wardrobe
  final VoidCallback onAdd;

  const AddClothingBottomBar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16), // [CONFIG] Padding action bar
      decoration: BoxDecoration(
        color: const Color(0xFFFCEEF0), // [CONFIG] Warna background bar
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Cancel Button ───────────────────────────────────
          Expanded(
            child: SizedBox(
              height: 48, // [CONFIG] Tinggi tombol Cancel
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D2D2D),
                  side: const BorderSide(
                    color: Color(0xFFD0D0D0), // [CONFIG] Warna border Cancel
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // [CONFIG] Border radius
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15, // [CONFIG] Ukuran font Cancel
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12), // [CONFIG] Spasi antar tombol

          // ── Add to Wardrobe Button + Badge ──────────────────
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48, // [CONFIG] Tinggi tombol Add to Wardrobe
                  child: ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4A7BB), // [CONFIG] Warna tombol
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // [CONFIG] Border radius
                      ),
                    ),
                    child: const Text(
                      'Add to Wardrobe',
                      style: TextStyle(
                        fontSize: 14, // [CONFIG] Ukuran font tombol
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // ── Count Badge ─────────────────────────────────
                if (selectedCount > 0)
                  Positioned(
                    top: -6,  // [CONFIG] Posisi vertikal badge
                    right: -6, // [CONFIG] Posisi horizontal badge
                    child: Container(
                      width: 20,  // [CONFIG] Ukuran badge
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D2D2D), // [CONFIG] Warna background badge
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$selectedCount',
                          style: const TextStyle(
                            fontSize: 11, // [CONFIG] Ukuran font angka badge
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}