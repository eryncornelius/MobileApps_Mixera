import '../../../checkout/data/models/order_model.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUsecase {
  GetOrdersUsecase(this._repository);

  final OrdersRepository _repository;

  Future<List<OrderModel>> call() => _repository.getOrders();
}
