import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() async{
    Get.put(GetStorage());

    // Initialize ApiClient
    Get.put(ApiClient());
    
  }
}