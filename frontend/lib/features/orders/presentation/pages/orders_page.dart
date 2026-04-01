import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final Color primaryPink = const Color(0xFFFFBCC9);
  final Color softPinkBg = const Color(0xFFFFE4E9);
  final Color darkGrey = const Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: softPinkBg,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeaderLogo(),
              const SizedBox(height: 10),
              
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      _buildPageTitle(),
                      const SizedBox(height: 20),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildTabBar(),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildListByStatus("Shipped"),   
                            _buildListByStatus("Delivered"), 
                            _buildListByStatus("Cancelled"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // bottom nav
      ),
    );
  }


  Widget _buildHeaderLogo() {
    return Text(
      'MIXÉRA',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryPink,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildPageTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.arrow_back_ios_new, size: 20, color: primaryPink),
          ),
          Text(
            'Orders',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkGrey,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTabBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TabBar(
        padding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: primaryPink,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: "Ongoing"),
          Tab(text: "Delivered"),
          Tab(text: "Cancelled"),
        ],
      ),
    );
  }

  Widget _buildListByStatus(String status) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildOrderCard(
          "Order#124$index", 
          "April 25, 2025", 
          "Rp 179.000", 
          status,
        );
      },
    );
  }

  Widget _buildOrderCard(String id, String date, String price, String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case "Delivered":
        statusColor = Colors.greenAccent.shade700;
        statusIcon = Icons.check_circle;
        break;
      case "Cancelled":
        statusColor = Colors.redAccent;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = primaryPink;
        statusIcon = Icons.more_horiz;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(id, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Text(price, style: TextStyle(fontSize: 16, color: primaryPink, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 25, thickness: 0.5),
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: softPinkBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.shopping_bag_outlined, color: primaryPink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(status, style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Icon(statusIcon, color: statusColor, size: 18),
                      ],
                    ),
                    if (status == "Shipped")
                      Text(". . . . . . .", style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              _viewOrderButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _viewOrderButton() {
    return GestureDetector(
      onTap: () {}, 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: softPinkBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("View Order", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            Icon(Icons.chevron_right, size: 14, color: primaryPink),
          ],
        ),
      ),
    );
  }
}