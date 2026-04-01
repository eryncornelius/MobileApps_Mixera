import 'package:flutter/material.dart';

class SearchHistorySection extends StatelessWidget {
  final List<String> recentSearches;
  final VoidCallback onClearAll;

  const SearchHistorySection({
    super.key,
    required this.recentSearches,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              GestureDetector(
                onTap: onClearAll,
                child: const Text('Clear all', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: recentSearches.map((tag) => ChoiceChip(
              label: Text(tag, style: const TextStyle(fontSize: 12)),
              selected: false,
              showCheckmark: false,
              backgroundColor: const Color(0xFFFFD1D1).withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide.none,
              onSelected: (_) {},
            )).toList(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
