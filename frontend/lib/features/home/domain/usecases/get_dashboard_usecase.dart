import '../../data/models/dashboard_model.dart';
import '../repositories/home_repository.dart';

class GetDashboardUseCase {
  final HomeRepository _repository;

  GetDashboardUseCase(this._repository);

  Future<DashboardModel> call() => _repository.getDashboard();
}
