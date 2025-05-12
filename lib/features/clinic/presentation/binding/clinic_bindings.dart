import 'package:eplisio_go/features/clinic/data/repo/clinic_repo.dart';
import 'package:eplisio_go/features/clinic/presentation/controller/clinic_controller.dart';
import 'package:get/get.dart';

class HospitalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HospitalsRepository(apiClient: Get.find()));
    Get.lazyPut(() => HospitalsController(Get.find()));
  }
}