import 'package:flutter/material.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5F6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Home address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A4A5F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Joni Purwoko',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A4A5F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '6767 ohio street Springfield, IL 62701 Primary Address +1 555\n123-4567',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A8A9E),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, color: Colors.grey, size: 40),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Midi Skirt',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A4A5F),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Rp 199.000',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFA9B8),
                                        ),
                                      ),
                                      Text(
                                        'Rp 259.000',
                                        style: TextStyle(
                                          fontSize: 12,
                                          decoration: TextDecoration.lineThrough,
                                          color: Color(0xFFFFA9B8).withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A4A5F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current Balance:',
                            style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9E)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp 676.700',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A4A5F),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildCardItem(
                                  logoText: 'VISA',
                                  logoColor: Colors.blue.shade800,
                                  cardName: 'Visa',
                                  cardNumber: '****1234',
                                  expDate: 'Exp 12/25',
                                  showArrow: false,
                                ),
                                Divider(height: 1, color: Colors.grey.shade200, indent: 16, endIndent: 16),
                                _buildCardItem(
                                  isMastercard: true,
                                  cardName: 'Mastercard',
                                  cardNumber: '5678',
                                  expDate: 'Exp 12/25',
                                  showArrow: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rincian Pembayaran',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8A8A9E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Subtotal:', '259.000'),
                          const SizedBox(height: 6),
                          _buildDetailRow('Diskon:', '60.000'),
                          const SizedBox(height: 6),
                          _buildDetailRow('Total:', '199.000'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              color: Color(0xFFFFF5F6),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A5F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFA9B8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Rp 199.000',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A5F),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A5F),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem({
    String? logoText,
    Color? logoColor,
    bool isMastercard = false,
    required String cardName,
    required String cardNumber,
    required String expDate,
    required bool showArrow,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: isMastercard
                ? Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                      Transform.translate(
                        offset: const Offset(-6, 0),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.8), shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  )
                : Text(
                    logoText ?? '',
                    style: TextStyle(
                      color: logoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Text(
            cardName,
            style: TextStyle(fontSize: 14, color: Color(0xFF4A4A5F)),
          ),
          const SizedBox(width: 8),
          Text(
            cardNumber,
            style: TextStyle(fontSize: 14, color: Color(0xFF4A4A5F)),
          ),
          const Spacer(),
          Text(
            expDate,
            style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9E)),
          ),
          if (showArrow) ...[
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF8A8A9E)),
          ] else ...[
            const SizedBox(width: 22),
          ]
        ],
      ),
    );
  }
}