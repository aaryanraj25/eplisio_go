import 'package:eplisio_go/features/profile/data/repo/profile_repo.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileRepository(apiClient: Get.find()));
    Get.lazyPut(() => ProfileController(Get.find()));
  }
}