import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_menu_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileC = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (profileC.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blushPink),
            );
          }

          final user = profileC.profile.value;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load profile', style: AppTextStyles.description),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: profileC.fetchProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final initial = user.username.isNotEmpty
              ? user.username[0].toUpperCase()
              : '?';

          return RefreshIndicator(
            color: AppColors.blushPink,
            onRefresh: profileC.fetchProfile,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'MIXÉRA',
                    style: AppTextStyles.logo.copyWith(
                      color: AppColors.blushPink,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: Text('Profile', style: AppTextStyles.headline)),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Welcome back, ${user.username}',
                    style: AppTextStyles.description,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blushPink, width: 3),
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppColors.roseMist,
                      child: Text(
                        initial,
                        style: AppTextStyles.headline
                            .copyWith(color: AppColors.blushPink),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: SizedBox(
                    width: 140,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteNames.editProfile),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _MenuCard(children: [
                  ProfileMenuTile(
                    icon: Icons.favorite_border_rounded,
                    label: 'Wishlist',
                    onTap: () {},
                  ),
                  _divider(),
                  ProfileMenuTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'Orders',
                    onTap: () => Navigator.pushNamed(context, RouteNames.orders),
                  ),
                  _divider(),
                  ProfileMenuTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                    onTap: () =>
                        Navigator.pushNamed(context, RouteNames.wallet),
                  ),
                  _divider(),
                  ProfileMenuTile(
                    icon: Icons.location_on_outlined,
                    label: 'Saved Addresses',
                    onTap: () =>
                        Navigator.pushNamed(context, RouteNames.savedAddresses),
                  ),
                ]),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Style',
                    style: AppTextStyles.description
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
                _MenuCard(children: [
                  ProfileMenuTile(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Saved Outfits',
                    onTap: () {},
                  ),
                  _divider(),
                  ProfileMenuTile(
                    icon: Icons.camera_alt_outlined,
                    label: 'My Try-On Photos',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Account',
                    style: AppTextStyles.description
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
                _MenuCard(children: [
                  ProfileMenuTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Account Details',
                    onTap: () =>
                        Navigator.pushNamed(context, RouteNames.editProfile),
                  ),
                  _divider(),
                  ProfileMenuTile(
                    icon: Icons.shield_outlined,
                    label: 'Security',
                    onTap: () =>
                        Navigator.pushNamed(context, RouteNames.security),
                  ),
                  _divider(),
                  ProfileMenuTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => Navigator.pushNamed(
                        context, RouteNames.notificationSettings),
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, color: AppColors.border, indent: 38);
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(children: children),
    );
  }
}
