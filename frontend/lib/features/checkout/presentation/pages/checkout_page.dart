import 'package:flutter/material.dart';
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDECEE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFF4A4B5), size: 20),
          onPressed: () {},
        ),
        title: const Text(
          'MIXÉRA',
          style: TextStyle(
            color: Color(0xFFE58A9E),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontFamily: 'Serif', 
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFFF4A4B5), size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4D54),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Items in your bag',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B6E75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  const CartItemCard(),
                  const SizedBox(height: 12),
                  const CartItemCard(),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B6E75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  const ShippingAddressCard(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          const OrderSummaryBottom(),
        ],
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key});

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.checkroom, 
              color: Color(0xFFFCAEBE), 
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Blush puff sleeve top',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4D54),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Soft Rose Blush',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Size : M',
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: const Icon(Icons.remove, size: 16, color: Colors.black87),
                            onPressed: () {},
                          ),
                          const Text('1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: const Icon(Icons.add, size: 16, color: Colors.black87),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Rp 179.000',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFA92A6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShippingAddressCard extends StatelessWidget {
  const ShippingAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE1E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.home, color: Color(0xFFFCAEBE)),
              const SizedBox(width: 8),
              const Text(
                'Home address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4D54),
                ),
              ),
              const Spacer(),
              const Icon(Icons.check_circle, color: Color(0xFFFCAEBE), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Joni Purwoko',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A4D54)),
          ),
          const SizedBox(height: 4),
          const Text(
            '6767 ohio street Springfield, IL 62701',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B6E75)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Primary Address +1 555 123-4567',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B6E75)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFAEBC),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {},
                  child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4A4D54),
                    side: BorderSide(color: Colors.grey.shade300),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class OrderSummaryBottom extends StatelessWidget {
  const OrderSummaryBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Products:', 'Rp 358.000'),
          const SizedBox(height: 8),
          _buildSummaryRow('Delivery', 'Rp 20.000'),
          const SizedBox(height: 8),
          _buildSummaryRow('Discount', '-Rp 10.000', isDiscount: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A4D54)),
              ),
              const Text(
                'Rp 368.000',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A4D54)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAEBC),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Confirm & Pay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Continue Shopping',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B6E75)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
            color: isDiscount ? const Color(0xFF9E9E9E) : const Color(0xFF4A4D54),
          ),
        ),
      ],
    );
  }
}