// lib/features/meetings/presentation/bindings/meetings_binding.dart

import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/core/utils/location_services.dart'; // Make sure this path is correct
import 'package:eplisio_go/features/meetings/data/repo/meeting_repo.dart';
import 'package:eplisio_go/features/meetings/presentation/controller/meeting_controller.dart';
import 'package:get/get.dart';

class MeetingsBinding extends Bindings {
  @override
  void dependencies() {
    // Register ApiClient if not already registered
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient());
    }

    if (!Get.isRegistered<LocationService>()) {
      Get.put(LocationService());
    }

    // Register Repository
    Get.lazyPut<MeetingsRepository>(
      () => MeetingsRepository(Get.find<ApiClient>()),
    );

    // Register Controller
    Get.lazyPut<MeetingsController>(
      () => MeetingsController(Get.find<MeetingsRepository>()),
    );
  }
}
