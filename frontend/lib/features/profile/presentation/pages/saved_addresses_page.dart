import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';
import '../widgets/address_card.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  @override
  void initState() {
    super.initState();
    Get.find<ProfileController>().fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final profileC = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Manage your Delivery Addresses',
                  style: AppTextStyles.description,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(() {
                  if (profileC.isLoadingAddresses.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.blushPink),
                    );
                  }
                  if (profileC.addresses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_off_outlined,
                              size: 48, color: AppColors.border),
                          const SizedBox(height: 12),
                          Text('No saved addresses yet.',
                              style: AppTextStyles.description),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.blushPink,
                    onRefresh: profileC.fetchAddresses,
                    child: ListView.builder(
                      itemCount: profileC.addresses.length,
                      itemBuilder: (_, i) {
                        final address = profileC.addresses[i];
                        return AddressCard(
                          address: address,
                          onEdit: () => Navigator.pushNamed(
                            context,
                            RouteNames.editAddress,
                            arguments: address,
                          ),
                          onDelete: () => _confirmDelete(context, profileC, address.id),
                          onSetPrimary: () => profileC.setPrimaryAddress(address),
                        );
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, RouteNames.addNewAddress),
                child: const Text('Make New Address'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProfileController profileC, int id) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete address?', style: AppTextStyles.section),
        content: Text(
          'This address will be permanently removed.',
          style: AppTextStyles.description,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.description
                    .copyWith(color: AppColors.blushPink)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              profileC.deleteAddress(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left_rounded,
                  size: 28, color: AppColors.primaryText),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'MIXÉRA',
                  style: AppTextStyles.logo
                      .copyWith(color: AppColors.blushPink, letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
        const SizedBox(height: 16),
        Text('Saved Addresses', style: AppTextStyles.headline),
      ],
    );
  }
}
