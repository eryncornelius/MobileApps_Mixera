import 'package:flutter/material.dart';

import '../../data/models/dashboard_model.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';

enum HomeStatus { initial, loading, success, error }

class HomeController extends ChangeNotifier {
  final GetDashboardUseCase _getDashboardUseCase;

  HomeController(this._getDashboardUseCase);

  HomeStatus _status = HomeStatus.initial;
  DashboardModel? _dashboard;
  String? _errorMessage;

  HomeStatus get status => _status;
  DashboardModel? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == HomeStatus.loading;
  bool get hasData => _status == HomeStatus.success && _dashboard != null;
  bool get hasError => _status == HomeStatus.error;

  Future<void> loadDashboard() async {
    if (_status == HomeStatus.loading) return;

    _status = HomeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _getDashboardUseCase();
      _status = HomeStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = HomeStatus.error;
    }

    notifyListeners();
  }
}
