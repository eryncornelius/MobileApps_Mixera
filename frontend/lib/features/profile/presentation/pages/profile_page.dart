import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../../../app/routes/route_names.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileC = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Obx(() {
        if (profileC.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = profileC.profile.value;
        if (user == null) {
          return Center(
            child: ElevatedButton(
              onPressed: profileC.fetchProfile,
              child: const Text('Retry'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: profileC.fetchProfile,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 42,
                child: Text(
                  user.username.isNotEmpty
                      ? user.username[0].toUpperCase()
                      : '?',
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.username,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Username'),
                      subtitle: Text(user.username),
                    ),
                    ListTile(
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                    ListTile(
                      title: const Text('Phone Number'),
                      subtitle: Text(user.phoneNumber ?? '-'),
                    ),
                    ListTile(
                      title: const Text('Auth Provider'),
                      subtitle: Text(user.authProvider),
                    ),
                    ListTile(
                      title: const Text('Email Verified'),
                      subtitle: Text(user.isEmailVerified ? 'Yes' : 'No'),
                    ),
                    ListTile(
                      title: const Text('Premium'),
                      subtitle: Text(user.isPremium ? 'Yes' : 'No'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.editProfile);
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
