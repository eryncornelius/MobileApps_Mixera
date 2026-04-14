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
                child: Obx(() {
                  final p = profileC.profile.value;
                  final pendingEmail = p?.pendingEmail;
                  final social = p?.isSocialAuth ?? false;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full Name', style: AppTextStyles.description),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: profileC.usernameController,
                        decoration: const InputDecoration(hintText: 'Your username'),
                      ),
                      const SizedBox(height: 20),
                      if (social) ...[
                        Text('Email', style: AppTextStyles.description),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warmCream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                p?.authProvider == 'google'
                                    ? Icons.g_mobiledata_rounded
                                    : Icons.facebook_rounded,
                                color: AppColors.secondaryText,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Akun ${p?.socialProviderLabel ?? 'sosial'}: email '
                                  'dan kata sandi tidak diatur di MIXÉRA.',
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.secondaryText,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Text('Email login', style: AppTextStyles.description),
                        const SizedBox(height: 8),
                        Text(
                          p?.email ?? '—',
                          style: AppTextStyles.description.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Email baru', style: AppTextStyles.description),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: profileC.emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            hintText: pendingEmail != null
                                ? 'Email baru (opsional, ganti tujuan OTP)'
                                : 'nama@email.com',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          final busy = profileC.isEmailChangeBusy.value;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: busy
                                    ? null
                                    : () => profileC.requestEmailChangeOtp(),
                                child: busy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Kirim OTP'),
                              ),
                              if (pendingEmail != null)
                                TextButton(
                                  onPressed: busy
                                      ? null
                                      : () => profileC.resendEmailChangeOtp(),
                                  child: const Text('Kirim ulang OTP'),
                                ),
                            ],
                          );
                        }),
                        if (pendingEmail != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.warmCream,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'OTP dikirim ke $pendingEmail. '
                              'Masukkan kode di bawah untuk menyelesaikan pergantian email.',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.secondaryText,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Kode OTP (4 digit)', style: AppTextStyles.description),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: profileC.emailChangeOtpController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            buildCounter: (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) =>
                                null,
                            decoration: const InputDecoration(
                              hintText: '0000',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() {
                            final busy = profileC.isEmailChangeBusy.value;
                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: busy
                                        ? null
                                        : () => profileC.confirmEmailChangeOtp(),
                                    child: busy
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Konfirmasi email'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: busy
                                      ? null
                                      : () => profileC.cancelEmailChangeRequest(),
                                  child: const Text('Batal'),
                                ),
                              ],
                            );
                          }),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Kata sandi', style: AppTextStyles.description),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                RouteNames.changePassword,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Ubah',
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warmCream,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border, width: 1.4),
                          ),
                          child: Text('••••••••', style: AppTextStyles.description),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text('Phone Number', style: AppTextStyles.description),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: profileC.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(hintText: '+1 555 000-0000'),
                      ),
                    ],
                  );
                }),
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
