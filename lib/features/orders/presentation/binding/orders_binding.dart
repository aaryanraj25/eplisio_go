import 'package:eplisio_go/features/orders/data/repo/orders_repo.dart';
import 'package:eplisio_go/features/orders/presentation/controller/orders_controller.dart';
import 'package:get/get.dart';
import '../../../../core/constants/api_client.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersRepository>(
      () => OrdersRepository(apiClient: Get.find<ApiClient>()),
    );
    
    Get.lazyPut<OrdersController>(
      () => OrdersController(repository: Get.find<OrdersRepository>()),
    );
  }
}