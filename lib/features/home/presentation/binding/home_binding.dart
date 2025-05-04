import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/home/data/repo/home_repo.dart';
import 'package:eplisio_go/features/home/presentation/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeRepository(
      apiClient: Get.find<ApiClient>(),
      storage: Get.find<GetStorage>(),
    ));
    Get.put(HomeController(repository: Get.find<HomeRepository>()));
  }
}