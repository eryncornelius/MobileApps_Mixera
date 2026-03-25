import 'package:get/get.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';

Future<void> initDependencies() async {
  Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
}
