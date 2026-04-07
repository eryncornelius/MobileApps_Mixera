import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../checkout/data/models/order_model.dart';
import '../controllers/orders_controller.dart';
import '../widgets/order_status_chip.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  OrderModel? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final c = Get.find<OrdersController>();
      final order = await c.fetchDetail(widget.orderId);
      if (mounted) setState(() => _order = order);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'MIXÉRA',
              style: AppTextStyles.logo.copyWith(
                color: AppColors.blushPink,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blushPink.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with back button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 20, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, size: 28),
                            color: AppColors.primaryText,
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              'Order Details',
                              style: AppTextStyles.headline,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blushPink, strokeWidth: 2),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: AppTextStyles.description, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _load,
                child: Text('Retry',
                    style: AppTextStyles.description.copyWith(color: AppColors.blushPink)),
              ),
            ],
          ),
        ),
      );
    }
    if (_order == null) return const SizedBox.shrink();
    return _OrderContent(order: _order!, fmt: _fmt, formatDate: _formatDate);
  }
}

class _OrderContent extends StatelessWidget {
  const _OrderContent({
    required this.order,
    required this.fmt,
    required this.formatDate,
  });

  final OrderModel order;
  final String Function(int) fmt;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    final addr = order.addressSnapshot;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order info card
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: AppTextStyles.section.copyWith(color: AppColors.blushPink),
                    ),
                    OrderStatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(formatDate(order.createdAt), style: AppTextStyles.small),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Items
          Text('Items', style: AppTextStyles.section),
          const SizedBox(height: 10),
          ...order.items.map((item) => _ItemCard(item: item, fmt: fmt)),

          const SizedBox(height: 16),

          // Shipping + Payment in a row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping info
              Expanded(
                child: _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shipping', style: AppTextStyles.type),
                      const SizedBox(height: 8),
                      if (addr != null) ...[
                        Text(
                          addr['recipient_name']?.toString() ?? '',
                          style: AppTextStyles.productName,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            addr['street_address'],
                            addr['city'],
                            addr['state'],
                            addr['postal_code'],
                          ].where((v) => v != null && v.toString().isNotEmpty).join(', '),
                          style: AppTextStyles.small,
                        ),
                        if (addr['phone_number'] != null &&
                            addr['phone_number'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(addr['phone_number'].toString(), style: AppTextStyles.small),
                        ],
                      ] else
                        Text('No address', style: AppTextStyles.small),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Payment info
              Expanded(
                child: _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment', style: AppTextStyles.type),
                      const SizedBox(height: 8),
                      Text(
                        order.paymentMethod == 'wallet' ? 'E-Wallet' : 'Credit Card',
                        style: AppTextStyles.productName,
                      ),
                      const Divider(height: 16, color: AppColors.border),
                      _PayRow(label: 'Subtotal', value: fmt(order.subtotal)),
                      const SizedBox(height: 4),
                      _PayRow(label: 'Shipping', value: fmt(order.deliveryFee)),
                      if (order.discountTotal > 0) ...[
                        const SizedBox(height: 4),
                        _PayRow(
                          label: 'Discount',
                          value: '- ${fmt(order.discountTotal)}',
                          valueColor: AppColors.success,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.roseMist,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: AppTextStyles.type
                                    .copyWith(fontWeight: FontWeight.w700)),
                            Text(
                              fmt(order.total),
                              style: AppTextStyles.type.copyWith(
                                color: AppColors.blushPink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.fmt});

  final OrderItemModel item;
  final String Function(int) fmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.primaryImage.isNotEmpty
                ? Image.network(
                    item.primaryImage,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imgPlaceholder(),
                  )
                : _imgPlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: AppTextStyles.productName),
                if (item.variantSize.isNotEmpty)
                  Text('Size: ${item.variantSize}', style: AppTextStyles.small),
                if (item.quantity > 1)
                  Text('Qty: ${item.quantity}', style: AppTextStyles.small),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    RouteNames.productDetail,
                    arguments: item.productSlug,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Item',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.blushPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 14, color: AppColors.blushPink),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            fmt(item.lineTotal),
            style: AppTextStyles.description.copyWith(
              color: AppColors.blushPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.roseMist,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_outlined, color: AppColors.blushPink, size: 24),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.small),
        Text(
          value,
          style: AppTextStyles.small.copyWith(
            color: valueColor ?? AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
