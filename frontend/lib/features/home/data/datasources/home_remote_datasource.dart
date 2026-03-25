import '../models/dashboard_model.dart';
import '../models/quick_action_model.dart';
import '../models/recommendation_banner_model.dart';

abstract class HomeRemoteDataSource {
  Future<DashboardModel> getDashboard();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  // TODO: inject Dio or http client here
  // final Dio _dio;
  // HomeRemoteDataSourceImpl(this._dio);

  @override
  Future<DashboardModel> getDashboard() async {
    // TODO: replace with real API call, e.g.:
    // final response = await _dio.get('/api/dashboard');
    // return DashboardModel.fromJson(response.data);

    // --- Mock data ---
    await Future.delayed(const Duration(milliseconds: 600));

    return DashboardModel(
      greeting: 'Good Morning',
      greetingSubtitle: 'Ready to style today?',
      featuredBanner: const RecommendationBannerModel(
        id: 'banner_1',
        title: 'Emo top review',
        subtitle: 'Soft pastel look\nfor a casual day',
        imageUrl:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
        ctaLabel: 'Mix My Outfit',
        ctaRoute: '/mix',
      ),
      quickActions: const [
        QuickActionModel(
          id: 'qa_1',
          label: 'Add Clothes',
          iconName: 'shirt',
          route: '/wardrobe/add',
        ),
        QuickActionModel(
          id: 'qa_2',
          label: 'Mix Ai',
          iconName: 'sparkles',
          route: '/mix',
        ),
        QuickActionModel(
          id: 'qa_3',
          label: 'Saved Outfits',
          iconName: 'heart',
          route: '/saved',
        ),
        QuickActionModel(
          id: 'qa_4',
          label: 'Orders',
          iconName: 'bag',
          route: '/orders',
        ),
      ],
      wardrobeItems: const [
        WardrobeItemModel(
          id: 'w1',
          imageUrl:
              'https://images.unsplash.com/photo-1571945153237-4929e783af4a?w=200',
          name: 'Knit Top',
        ),
        WardrobeItemModel(
          id: 'w2',
          imageUrl:
              'https://images.unsplash.com/photo-1604575021891-1b95c60659b9?w=200',
          name: 'Pink Blazer',
        ),
        WardrobeItemModel(
          id: 'w3',
          imageUrl:
              'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=200',
          name: 'Jeans',
        ),
        WardrobeItemModel(
          id: 'w4',
          imageUrl:
              'https://images.unsplash.com/photo-1515347619252-60a4bf4fff4f?w=200',
          name: 'Heels',
        ),
      ],
      saleItems: const [
        SaleItemModel(
          id: 's1',
          name: 'Blush Puff Sleeve Top',
          imageUrl:
              'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=300',
          originalPrice: 180000,
          salePrice: 113300,
          discountPercent: 30,
        ),
        SaleItemModel(
          id: 's2',
          name: 'Soft Pink Ruched Blouse',
          imageUrl:
              'https://images.unsplash.com/photo-1604575021891-1b95c60659b9?w=300',
          originalPrice: 259000,
          salePrice: 179000,
          discountPercent: 25,
        ),
        SaleItemModel(
          id: 's3',
          name: 'Midi Skirt',
          imageUrl:
              'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=300',
          originalPrice: 259000,
          salePrice: 199000,
          discountPercent: 20,
        ),
      ],
      recommendedItems: const [
        RecommendedItemModel(
          id: 'r1',
          name: 'Midi Skirt',
          brand: 'Fall & Bloom',
          imageUrl:
              'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=300',
          price: 199000,
        ),
        RecommendedItemModel(
          id: 'r2',
          name: 'Midi Skirt',
          brand: 'Fall & Bloom',
          imageUrl:
              'https://images.unsplash.com/photo-1581338834647-b0fb40704e21?w=300',
          price: 199000,
        ),
        RecommendedItemModel(
          id: 'r3',
          name: 'Linen Blouse',
          brand: 'Soft Stitch',
          imageUrl:
              'https://images.unsplash.com/photo-1551163943-3f7253a97bca?w=300',
          price: 149000,
        ),
        RecommendedItemModel(
          id: 'r4',
          name: 'Floral Top',
          brand: 'Petal Co.',
          imageUrl:
              'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=300',
          price: 129000,
        ),
      ],
    );
  }
}
