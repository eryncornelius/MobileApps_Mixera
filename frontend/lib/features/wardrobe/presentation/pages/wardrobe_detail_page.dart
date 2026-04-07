import 'package:flutter/material.dart';
import '../widgets/wardrobe_filter_tabs.dart';

// ============================================================
// KONFIGURASI LAYOUT:
// - [CONFIG] Warna background halaman
// - [CONFIG] AppBar style (back arrow, title, filter button)
// - [CONFIG] Grid layout kartu pakaian
// - [CONFIG] Item card style (gambar, nama, tombol aksi)
// - [CONFIG] Action icons (edit, delete, duplicate)
// ============================================================

// Model data item pakaian — sesuaikan dengan model dari data layer
class WardrobeItemDisplay {
  final String id;
  final String name;
  final String imagePath;
  final bool isFavorited;

  const WardrobeItemDisplay({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isFavorited = false,
  });
}

class WardrobeDetailPage extends StatefulWidget {
  // [CONFIG] Parameter wajib saat navigate ke halaman ini
  final String categoryName; // contoh: 'Top'
  final int itemCount; // contoh: 10

  const WardrobeDetailPage({
    super.key,
    // required this.categoryName,
    this.categoryName = 'Category', // [CONFIG] Default 'Category' jika tidak diberikan
    // required this.itemCount,
    this.itemCount = 0, // [CONFIG] Default 0 jika tidak diberikan
  });

  @override
  State<WardrobeDetailPage> createState() => _WardrobeDetailPageState();
}

class _WardrobeDetailPageState extends State<WardrobeDetailPage> {
  // [CONFIG] Data dummy — ganti dengan data dari controller/repository
  final List<WardrobeItemDisplay> _items = const [
    WardrobeItemDisplay(id: '1', name: 'White Tank Top', imagePath: 'assets/images/white_tank.png', isFavorited: false),
    WardrobeItemDisplay(id: '2', name: 'Pink Camisole', imagePath: 'assets/images/pink_camisole.png', isFavorited: false),
    WardrobeItemDisplay(id: '3', name: 'White Tee', imagePath: 'assets/images/white_tee.png', isFavorited: true),
    WardrobeItemDisplay(id: '4', name: 'Stripped Tee', imagePath: 'assets/images/stripped_tee.png', isFavorited: true),
    WardrobeItemDisplay(id: '5', name: 'Pink Blouse', imagePath: 'assets/images/pink_blouse.png', isFavorited: false),
    WardrobeItemDisplay(id: '6', name: 'Cream Puff Sleeve Top', imagePath: 'assets/images/cream_puff.png', isFavorited: true),
    WardrobeItemDisplay(id: '7', name: 'Blue Button Shirt', imagePath: 'assets/images/blue_button.png', isFavorited: true),
    WardrobeItemDisplay(id: '8', name: 'Warm Beige Knit', imagePath: 'assets/images/beige_knit.png', isFavorited: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [CONFIG] Warna background halaman detail
      backgroundColor: const Color(0xFFFCEEF0),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────
            _buildAppBar(context),
            const SizedBox(height: 12), // [CONFIG] Jarak AppBar ke grid

            // ── Items Grid ───────────────────────────────────
            Expanded(
              child: _buildItemsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Custom AppBar ───────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), // [CONFIG] Padding AppBar
      child: Row(
        children: [
          // [CONFIG] Tombol kembali
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20, // [CONFIG] Ukuran icon back
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(width: 12),

          // [CONFIG] Teks judul AppBar (kategori + jumlah)
          Expanded(
            child: Text(
              'You own ${widget.itemCount} ${widget.categoryName.toLowerCase()}s',
              style: const TextStyle(
                fontSize: 18, // [CONFIG] Ukuran font judul AppBar
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),

          // [CONFIG] Filter button
          _buildFilterButton(),
        ],
      ),
    );
  }

  // ── Filter Button ───────────────────────────────────────────────
  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () {
        // [CONFIG] Filter muncul dari ATAS layar
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Filter',
          // [CONFIG] Warna & opacity background gelap di belakang filter
          barrierColor: Colors.black.withOpacity(0.4),
          transitionDuration: const Duration(milliseconds: 300), // [CONFIG] Durasi animasi
          pageBuilder: (_, __, ___) => const SizedBox.shrink(),
          transitionBuilder: (context, animation, _, __) {
            // Animasi slide dari atas ke bawah
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut, // [CONFIG] Kurva animasi
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1), // [CONFIG] Mulai dari atas layar
                end: Offset.zero,
              ).animate(curved),
              child: Align(
                alignment: Alignment.topCenter, // [CONFIG] Posisi sheet (topCenter = atas)
                child: Material(
                  color: Colors.transparent,
                  child: SafeArea(
                    child: WardrobeFilterTabs(
                      selectedStyles: const [], // [CONFIG] Ganti dengan state aktif dari controller
                      onApply: (selectedStyles) {
                        // TODO: Handle filter apply dari controller
                        debugPrint('Filter applied: $selectedStyles');
                      },
                      onRemove: () {
                        // TODO: Reset filter dari controller
                        debugPrint('Filter removed');
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14, // [CONFIG] Padding horizontal filter button
          vertical: 8, // [CONFIG] Padding vertikal filter button
        ),
        decoration: BoxDecoration(
          color: Colors.white, // [CONFIG] Warna background filter button
          borderRadius: BorderRadius.circular(20), // [CONFIG] Border radius filter button
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.filter_list_rounded,
              size: 16, // [CONFIG] Ukuran icon filter
              color: Color(0xFF2D2D2D),
            ),
            SizedBox(width: 4),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: 13, // [CONFIG] Ukuran font teks filter
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Items Grid ──────────────────────────────────────────────────
  Widget _buildItemsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), // [CONFIG] Padding grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // [CONFIG] Jumlah kolom grid item
        crossAxisSpacing: 12, // [CONFIG] Spasi horizontal antar kartu
        mainAxisSpacing: 12, // [CONFIG] Spasi vertikal antar kartu
        childAspectRatio: 0.82, // [CONFIG] Rasio lebar:tinggi kartu item — kecilkan jika teks kepotong
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _ClothingItemCard(
          item: _items[index],
          onEdit: () {
            // TODO: Navigate ke edit item page
          },
          onDelete: () {
            // TODO: Tampilkan konfirmasi hapus
          },
          onDuplicate: () {
            // TODO: Duplicate item
          },
          onFavorite: () {
            // TODO: Toggle favorite
          },
        );
      },
    );
  }
}

// ── Clothing Item Card Widget ───────────────────────────────────────
class _ClothingItemCard extends StatelessWidget {
  final WardrobeItemDisplay item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onFavorite;

  const _ClothingItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // [CONFIG] Warna background kartu item
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
          // ── Item Name + Favorite Icon Row ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0), // [CONFIG] Padding header kartu
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // [CONFIG] Teks nama item pakaian
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13, // [CONFIG] Ukuran font nama item
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // [CONFIG] Tombol favorit — tampil hanya jika item.isFavorited
                if (item.isFavorited)
                  GestureDetector(
                    onTap: onFavorite,
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 18, // [CONFIG] Ukuran icon favorit
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
              ],
            ),
          ),

          // ── Item Image ────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // [CONFIG] Padding gambar
              child: Center(
                child: Image.asset(
                  item.imagePath,
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

          // ── Action Buttons Row ────────────────────────────
          _buildActionBar(),
        ],
      ),
    );
  }

  // ── Action Bar: Edit | Delete | Duplicate ───────────────────────
  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10), // [CONFIG] Padding action bar
      child: Row(
        children: [
          // [CONFIG] Tombol Edit
          GestureDetector(
            onTap: onEdit,
            child: Row(
              children: const [
                Icon(
                  Icons.edit_outlined,
                  size: 14, // [CONFIG] Ukuran icon edit
                  color: Color(0xFFF4A7BB),
                ),
                SizedBox(width: 3),
                Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12, // [CONFIG] Ukuran font teks edit
                    color: Color(0xFFF4A7BB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // [CONFIG] Tombol Delete
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 18, // [CONFIG] Ukuran icon delete
              color: Color(0xFFF4A7BB),
            ),
          ),
          const SizedBox(width: 10), // [CONFIG] Spasi antara delete & duplicate
          // [CONFIG] Tombol Duplicate
          GestureDetector(
            onTap: onDuplicate,
            child: const Icon(
              Icons.copy_outlined,
              size: 17, // [CONFIG] Ukuran icon duplicate
              color: Color(0xFFF4A7BB),
            ),
          ),
        ],
      ),
    );
  }
}