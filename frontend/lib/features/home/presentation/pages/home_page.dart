import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/models/recommendation_banner_model.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';
import '../controllers/home_controller.dart';
import '../widgets/greeting_header.dart';
import '../widgets/on_sale_section.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/recommended_section.dart';
import '../widgets/wardrobe_preview_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    // Manual DI — swap with your preferred solution (GetIt, Provider, Riverpod…)
    _controller = HomeController(
      GetDashboardUseCase(HomeRepositoryImpl(HomeRemoteDataSourceImpl())),
    )..addListener(_onControllerChange);

    _controller.loadDashboard();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blushPink),
      );
    }

    if (_controller.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              _controller.errorMessage ?? 'Something went wrong',
              style: AppTextStyles.description,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.loadDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_controller.hasData) return const SizedBox.shrink();

    final data = _controller.dashboard!;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
            child: GreetingHeader(
              greeting: data.greeting,
              subtitle: data.greetingSubtitle,
              onNotificationTap: () {},
            ),
          ),
        ),

        // ── Featured Banner ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _FeaturedBanner(banner: data.featuredBanner),
          ),
        ),

        // ── Quick Actions ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: QuickActionsSection(
              actions: data.quickActions,
              onViewAll: () {},
              onActionTap: (action) {},
            ),
          ),
        ),

        // ── Wardrobe Preview ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: WardrobePreviewSection(
              items: data.wardrobeItems,
              onViewAll: () {},
            ),
          ),
        ),

        // ── Complete Your Look ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: _CompleteYourLookSection(
              items: data.recommendedItems.take(2).toList(),
            ),
          ),
        ),

        // ── On Sale ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: OnSaleSection(
              items: data.saleItems,
              onViewAll: () {},
              onItemTap: (_) {},
            ),
          ),
        ),

        // ── Recommended ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: RecommendedSection(
              items: data.recommendedItems,
              onViewAll: () {},
              onItemTap: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}

// ── Featured Banner ──────────────────────────────────────────────────────────

class _FeaturedBanner extends StatelessWidget {
  final RecommendationBannerModel banner;

  const _FeaturedBanner({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.blushPink.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          // Text side
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(banner.title, style: AppTextStyles.productName),
                  Text(
                    banner.subtitle,
                    style: AppTextStyles.description.copyWith(height: 1.4),
                  ),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blushPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        textStyle: AppTextStyles.button.copyWith(fontSize: 13),
                      ),
                      child: Text(banner.ctaLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Image side
          SizedBox(
            width: 130,
            height: 160,
            child: Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.roseMist,
                child: const Icon(
                  Icons.checkroom_outlined,
                  color: AppColors.blushPink,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Complete Your Look ───────────────────────────────────────────────────────

class _CompleteYourLookSection extends StatelessWidget {
  final List<RecommendedItemModel> items;

  const _CompleteYourLookSection({required this.items});

  String _formatPrice(double price) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp.$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Complete Your Look', style: AppTextStyles.section),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.softWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // "From Local Brand" header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Text(
                      'From Local Brand ',
                      style: AppTextStyles.description.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                    const Text('🇮🇩', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              // Product row
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: items.map((item) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: item == items.last ? 0 : 10,
                        ),
                        child: _CompleteItem(
                          item: item,
                          formattedPrice: _formatPrice(item.price),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // View all button
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blushPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('View All', style: AppTextStyles.button),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompleteItem extends StatelessWidget {
  final RecommendedItemModel item;
  final String formattedPrice;

  const _CompleteItem({required this.item, required this.formattedPrice});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 0.9,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.roseMist,
                child: const Icon(
                  Icons.checkroom_outlined,
                  color: AppColors.blushPink,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          formattedPrice,
          style: AppTextStyles.small.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


