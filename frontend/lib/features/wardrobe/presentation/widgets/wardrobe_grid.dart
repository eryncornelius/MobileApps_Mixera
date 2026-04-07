import 'package:flutter/material.dart';

// ── Category Card Widget ────────────────────────────────────────────
class CategoryCard extends StatelessWidget {
  final String label;
  final int count;
  final String imagePath;
  final VoidCallback onTap;

  const CategoryCard({
    required this.label,
    required this.count,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // [CONFIG] Warna background kartu kategori
          borderRadius: BorderRadius.circular(16), // [CONFIG] Border radius kartu
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Label & Count Row ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0), // [CONFIG] Padding label
              child: Row(
                children: [
                  // [CONFIG] Teks label kategori
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // [CONFIG] Teks jumlah item kategori
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            // ── Category Image ────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8), // [CONFIG] Padding gambar dalam kartu
                child: Center(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEEF0), // [CONFIG] Warna placeholder gambar
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}