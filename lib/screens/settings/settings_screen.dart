import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import 'barcode_settings_screen.dart'; // 新しい画面をインポート
import 'master_data_settings_screen.dart'; // 新しい画面をインポート

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('バーコード読み取り設定'),
            subtitle: const Text('スキャンの間隔や対象コードを編集します。'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const BarcodeSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('マスタ設定'),
            subtitle: const Text('商品や決済方法、データの入出力を管理します。'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MasterDataSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
