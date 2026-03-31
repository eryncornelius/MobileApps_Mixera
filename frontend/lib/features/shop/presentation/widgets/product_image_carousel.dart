import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../data/models/product_detail_model.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<ProductImageModel> images;
  const ProductImageCarousel({super.key, required this.images});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  int _current = 0;
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _placeholder();
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              return Image.network(
                widget.images[i].imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => _placeholder(),
              );
            },
          ),
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _current ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _current ? AppColors.blushPink : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      height: 320,
      color: AppColors.roseMist,
      child: const Icon(Icons.image_outlined, size: 64, color: AppColors.blushPink),
    );
  }
}
