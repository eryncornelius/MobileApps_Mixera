import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF0F3), 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFF4A8B6)),
          onPressed: () {},
        ),
        title: const Text(
          'MIXÉRA',
          style: TextStyle(
            color: Color(0xFFF4A8B6),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontFamily: 'Serif',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFFF4A8B6)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Header Keranjang
            Text(
              'Your Bag',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
            ),
            const SizedBox(height: 4),
            Text(
              '2 Items',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 16),

            _buildCartItem(),
            const SizedBox(height: 12),
            _buildCartItem(),
            const SizedBox(height: 24),

            Text(
              'You might also like',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildRecommendationItem(true, 'Long sleeve blouse')),
                const SizedBox(width: 12),
                Expanded(child: _buildRecommendationItem(false, 'Midi Skirt')),
              ],
            ),
            const SizedBox(height: 24),

            // Bagian Ringkasan Pembayaran
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  // Widget untuk item di dalam keranjang
  Widget _buildCartItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Placeholder Gambar Produk
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFF4A8B6)),
          ),
          const SizedBox(width: 12),
          // Detail Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blush puff sleeve top',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('Soft Rose Blush', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 4),
                Text('Size : M', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          // Harga dan Kontrol Kuantitas
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp 179.000',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF4A8B6)),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Icon(Icons.remove, size: 16),
                      ),
                    ),
                    const Text('1', style: TextStyle(fontSize: 14)),
                    InkWell(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // Widget untuk produk rekomendasi
  Widget _buildRecommendationItem(bool isNew, String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Placeholder Gambar
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_outlined, color: Color(0xFFF4A8B6), size: 40),
              ),
              if (isNew)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFF4A8B6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Rp 250.000',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9E9E9E),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Rp 179.000',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF4A8B6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk ringkasan pembayaran
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Products:', 'Rp 358.000', isBold: false),
          const SizedBox(height: 8),
          _buildSummaryRow('Delivery', 'Rp 20.000', isBold: false),
          const SizedBox(height: 8),
          _buildSummaryRow('Discount', '-Rp 10.000', isBold: false, valueColor: Color(0xFF9E9E9E)),
          const Divider(height: 24, thickness: 1),
          _buildSummaryRow('Total', 'Rp 368.000', isBold: true),
          const SizedBox(height: 20),
          
          // Tombol Checkout
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF4A8B6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Tombol Continue Shopping
          TextButton(
            onPressed: () {},
            child: Text(
              'Continue Shopping',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  // Helper untuk baris pada ringkasan pembayaran
  Widget _buildSummaryRow(String label, String value, {required bool isBold, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Color(0xFF4A4A4A),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Color(0xFF4A4A4A),
          ),
        ),
      ],
    );
  }
}