import 'package:flutter/material.dart';
import '../../../../app/routes/route_names.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_image_carousel.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'New', 'Tops', 'Bottoms', 'Dress'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Text('MIXERA', style: TextStyle(color: Color(0xFFFF8B94), fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Shop', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w300)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF8B94))),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Color(0xFFFF8B94))),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Discover items you'll love", style: TextStyle(color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              readOnly: true,
              onTap: () => Navigator.of(context).pushNamed(RouteNames.search),
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const ProductImageCarousel(),
          const SizedBox(height: 10),
          CategoryTabs(
            selectedCategory: selectedCategory,
            categories: categories,
            onCategorySelected: (cat) => setState(() => selectedCategory = cat),
          ),
          const SizedBox(height: 10),
          Expanded(child: ProductGrid(itemCount: 4)),
        ],
      ),
    );
  }
}