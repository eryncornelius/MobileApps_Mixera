import '../../domain/repositories/home_repository.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/models/dashboard_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<DashboardModel> getDashboard() {
    return _remoteDataSource.getDashboard();
  }
}
