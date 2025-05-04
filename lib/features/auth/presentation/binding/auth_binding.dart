import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/auth/data/repo/auth_repo.dart';
import 'package:eplisio_go/features/auth/presentation/controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository(
      apiClient: Get.find<ApiClient>(),
      storage: GetStorage(),
    ));
    Get.put(AuthController(repository: Get.find<AuthRepository>()));
  }
}