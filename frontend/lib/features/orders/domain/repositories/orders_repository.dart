import '../../../checkout/data/models/order_model.dart';

abstract class OrdersRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderDetail(int id);
}
