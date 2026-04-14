import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/notification_item_model.dart';

class NotificationsRemoteDatasource {
  NotificationsRemoteDatasource()
      : _dio = createAuthenticatedDio(
          baseUrl: ApiBaseUrl.module('users'),
        );

  final Dio _dio;

  String _err(DioException e) {
    final d = e.response?.data;
    if (d is Map && d['detail'] != null) return d['detail'].toString();
    return 'Permintaan gagal.';
  }

  Future<List<NotificationItemModel>> getNotifications() async {
    try {
      final res = await _dio.get('/notifications/');
      final list = res.data as List;
      return list
          .map((e) => NotificationItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get('/notifications/unread-count/');
      return (res.data as Map)['count'] as int? ?? 0;
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<void> markRead({bool all = false, int? id}) async {
    try {
      await _dio.post(
        '/notifications/read/',
        data: all ? {'all': true} : {'id': id},
      );
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<void> registerFcmToken(String token) async {
    try {
      await _dio.post(
        '/fcm-token/',
        data: {'token': token, 'platform': 'android'},
      );
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }
}
