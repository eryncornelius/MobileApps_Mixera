import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class OrderStatusInfo {
  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  const OrderStatusInfo({
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  static OrderStatusInfo from(String status) {
    switch (status) {
      case 'pending':
        return OrderStatusInfo(
          label: 'Pending',
          color: AppColors.secondaryText,
          background: AppColors.border,
        );
      case 'paid':
        return OrderStatusInfo(
          label: 'Paid',
          color: AppColors.success,
          background: const Color(0xFFEDF7F4),
        );
      case 'processing':
        return OrderStatusInfo(
          label: 'Processing',
          color: AppColors.blushPink,
          background: AppColors.roseMist,
        );
      case 'shipped':
        return OrderStatusInfo(
          label: 'Shipped',
          color: AppColors.blushPink,
          background: AppColors.roseMist,
          icon: Icons.local_shipping_outlined,
        );
      case 'completed':
        return OrderStatusInfo(
          label: 'Delivered',
          color: AppColors.success,
          background: const Color(0xFFEDF7F4),
          icon: Icons.check_circle_rounded,
        );
      case 'cancelled':
        return OrderStatusInfo(
          label: 'Cancelled',
          color: AppColors.error,
          background: const Color(0xFFFDF0F0),
          icon: Icons.cancel_rounded,
        );
      default:
        return OrderStatusInfo(
          label: status,
          color: AppColors.secondaryText,
          background: AppColors.border,
        );
    }
  }
}

enum OrderTab { ongoing, delivered, cancelled }

extension OrderTabLabel on OrderTab {
  String get label {
    switch (this) {
      case OrderTab.ongoing:
        return 'Ongoing';
      case OrderTab.delivered:
        return 'Delivered';
      case OrderTab.cancelled:
        return 'Cancelled';
    }
  }

  bool matchesStatus(String status) {
    switch (this) {
      case OrderTab.ongoing:
        return ['pending', 'paid', 'processing', 'shipped'].contains(status);
      case OrderTab.delivered:
        return status == 'completed';
      case OrderTab.cancelled:
        return status == 'cancelled';
    }
  }
}
