import '../../../checkout/data/models/order_model.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailUsecase {
  GetOrderDetailUsecase(this._repository);

  final OrdersRepository _repository;

  Future<OrderModel> call(int id) => _repository.getOrderDetail(id);
}
