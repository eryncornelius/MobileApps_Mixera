import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileC = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: profileC.usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: profileC.emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: profileC.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profileC.isSaving.value
                      ? null
                      : () async {
                          final success = await profileC.saveProfile();
                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                  child: Text(
                    profileC.isSaving.value ? 'Saving...' : 'Save Changes',
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
