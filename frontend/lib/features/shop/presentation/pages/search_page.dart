import 'package:flutter/material.dart';
import '../widgets/search_history_section.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> recentSearches = ['Midi skirt', 'Blouse', 'Sweater'];

  void _clearAll() {
    setState(() {
      recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE2E4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFF8B94)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MIXERA',
          style: TextStyle(
            color: Color(0xFFFF8B94),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            if (recentSearches.isNotEmpty)
              SearchHistorySection(
                recentSearches: recentSearches,
                onClearAll: _clearAll,
              ),

            _buildSectionHeader("Popular Searches", null),
            _buildTagCloud([
              'Midi skirt', 'Blouse', 'Sweater', 
              'Cute Tops', 'Dress', 'Floral Dress', 
              'Crop Tops', 'Pastel', 'Pink'
            ]),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Recently Viewed",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            
            SizedBox(
              height: 220,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) => const SizedBox(
                  width: 160,
                  child: ProductCardSmall(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? actionText, {VoidCallback? onActionTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTagCloud(List<String> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: tags.map((tag) => ChoiceChip(
          label: Text(tag, style: const TextStyle(fontSize: 12)),
          selected: false,
          showCheckmark: false, 
          backgroundColor: const Color(0xFFFFD1D1).withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide.none,
          onSelected: (bool selected) {},
        )).toList(),
      ),
    );
  }
}



class ProductCardSmall extends StatelessWidget {
  const ProductCardSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFF8B94), borderRadius: BorderRadius.circular(5)),
                    child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 8)),
                  ),
                ),
                const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, size: 16, color: Colors.grey)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Long-Sleeve Blouse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1),
                const Text('Soft Pink Cotton', style: TextStyle(color: Colors.grey, fontSize: 9)),
                const SizedBox(height: 4),
                const Text('Rp 179.000', style: TextStyle(color: Color(0xFFFF8B94), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}