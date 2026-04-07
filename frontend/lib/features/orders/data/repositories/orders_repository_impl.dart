import '../../../checkout/data/models/order_model.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._ds);

  final OrdersRemoteDatasource _ds;

  @override
  Future<List<OrderModel>> getOrders() => _ds.getOrders();

  @override
  Future<OrderModel> getOrderDetail(int id) => _ds.getOrderDetail(id);
}
