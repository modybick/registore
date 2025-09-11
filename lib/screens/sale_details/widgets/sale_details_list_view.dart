// screens/sale_detail/widgets/sale_details_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/sale_detail_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/formatter.dart';

/// 販売詳細の商品リストを表示するウィジェット
class SaleDetailsListView extends StatelessWidget {
  final List<SaleDetail> details;

  const SaleDetailsListView({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.inverseSurface,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: details.length,
              separatorBuilder: (context, index) =>
                  const Divider(
                    height: 1,
                    indent: 8.0,
                    endIndent: 8.0,
                  ),
              itemBuilder: (context, index) {
                final item = details[index];
                return _buildListItem(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// リストのヘッダー部分
  Widget _buildHeader() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 5,
            child: Text('商品名', style: headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '数量',
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '小計',
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
        ],
      ),
    );
  }

  /// リストの各行
  Widget _buildListItem(
    BuildContext context,
    SaleDetail item,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return Text(
                  item.productName,
                  maxLines: settings.showFullName
                      ? null
                      : settings.productNameMaxLines,
                  overflow: settings.showFullName
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatCurrency(item.price * item.quantity),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
