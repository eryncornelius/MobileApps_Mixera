import 'package:get/get.dart';

import '../../../checkout/data/models/order_model.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import '../../data/models/order_status_model.dart';

class OrdersController extends GetxController {
  final _ds = OrdersRemoteDatasource();

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final selectedTab = OrderTab.ongoing.obs;

  List<OrderModel> get filteredOrders =>
      orders.where((o) => selectedTab.value.matchesStatus(o.status)).toList();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      orders.assignAll(await _ds.getOrders());
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<OrderModel> fetchDetail(int id) => _ds.getOrderDetail(id);

  void selectTab(OrderTab tab) => selectedTab.value = tab;
}
