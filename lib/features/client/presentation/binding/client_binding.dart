import 'package:eplisio_go/features/client/data/repo/client_repo.dart';
import 'package:eplisio_go/features/client/presentation/controller/client_controller.dart';
import 'package:get/get.dart';

class ClientsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientsRepository(apiClient: Get.find()));
    Get.lazyPut(() => ClientsController(Get.find()));
  }
}