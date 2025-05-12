import 'package:eplisio_go/features/home/presentation/binding/home_binding.dart';
import 'package:eplisio_go/features/meetings/presentation/binding/meeting_binding.dart';
import 'package:eplisio_go/features/orders/presentation/binding/orders_binding.dart';
import 'package:eplisio_go/features/profile/presentation/binding/profile_binding.dart';
import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());

    HomeBinding().dependencies();
    OrdersBinding().dependencies();
    MeetingsBinding().dependencies();
    ProfileBinding().dependencies();



  }
}