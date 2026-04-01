import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFFFC1CC);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("View Order", style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.grey),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Order#1246", style: TextStyle(color: Color(0xFFF48FB1), fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("April 25, 2025", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: primaryPink, borderRadius: BorderRadius.circular(10)),
                    child: const Text("Shipped", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text("From Amazing Productions", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            const Text("Items", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

            _buildItemTile("Light Pink Ballet Flats", "Rp 95.000", Color(0xFFF48FB1)),
            _buildItemTile("White Long Sleeve Blouse", "Rp 95.000", Color(0xFFF48FB1)),

            const SizedBox(height: 20),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoSection("Shipping Information", "Joni Purwoko\n6767 ohio street\nSpringfield, IL 62701\n+1 555 123-4567")),
                const SizedBox(width: 10),
                Expanded(child: _buildPaymentSection("E-Wallet", "190.000", "10.000", "200.000", primaryPink)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(String title, String price, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Text(price, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.pink),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(15)),
          child: Text(content, style: const TextStyle(fontSize: 11, height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(String method, String sub, String ship, String total, Color pink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Method", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Text(method, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              _rowPrice("Subtotal", sub),
              _rowPrice("Shipping", ship),
              const SizedBox(height: 5),
              Container(
                color: pink,
                padding: const EdgeInsets.all(4),
                child: _rowPrice("Total", total, isBold: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rowPrice(String label, String price, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("Rp $price", style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}