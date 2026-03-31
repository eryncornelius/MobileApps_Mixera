import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileC = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _SubPageHeader(title: 'Edit Profile', context: context),
              const SizedBox(height: 28),
              // Avatar
              Center(
                child: Obx(() {
                  final initial = profileC.profile.value?.username.isNotEmpty == true
                      ? profileC.profile.value!.username[0].toUpperCase()
                      : '?';
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blushPink, width: 2.5),
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppColors.roseMist,
                      child: Text(
                        initial,
                        style: AppTextStyles.section.copyWith(color: AppColors.blushPink),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              // Form card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full Name', style: AppTextStyles.description),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: profileC.usernameController,
                      decoration: const InputDecoration(hintText: 'Your username'),
                    ),
                    const SizedBox(height: 20),
                    Text('Email', style: AppTextStyles.description),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: profileC.emailController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        fillColor: AppColors.border.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Phone Number', style: AppTextStyles.description),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: profileC.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: '+1 555 000-0000'),
                    ),
                    const SizedBox(height: 20),
                    // Password row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password', style: AppTextStyles.description),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, RouteNames.changePassword),
                          child: Row(
                            children: [
                              Text(
                                'Change',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.blushPink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.blushPink,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.warmCream,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border, width: 1.4),
                      ),
                      child: Text('••••••••', style: AppTextStyles.description),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Obx(() => ElevatedButton(
                    onPressed: profileC.isSaving.value
                        ? null
                        : () async {
                            final success = await profileC.saveProfile();
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: profileC.isSaving.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('Save Changes'),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubPageHeader extends StatelessWidget {
  final String title;
  final BuildContext context;

  const _SubPageHeader({required this.title, required this.context});

  @override
  Widget build(BuildContext context) {
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
                  style: AppTextStyles.logo.copyWith(
                    color: AppColors.blushPink,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
        const SizedBox(height: 16),
        Text(title, style: AppTextStyles.headline),
      ],
    );
  }
}
