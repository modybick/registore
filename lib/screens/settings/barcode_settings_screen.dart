import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/radio_group.dart' as rg;

class BarcodeSettingsScreen extends StatelessWidget {
  const BarcodeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('バーコード読み取り設定')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- バーコード読み取り間隔 ---
              const ListTile(
                leading: Icon(Icons.timer_outlined),
                title: Text(
                  'バーコード連続読み取り間隔',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: settings.scanInterval,
                        min: 0.1,
                        max: 5.0,
                        divisions: 49,
                        label:
                            '${settings.scanInterval.toStringAsFixed(1)} 秒',
                        onChanged: (value) {
                          settings.updateScanInterval(
                            value,
                          );
                        },
                      ),
                    ),
                    Text(
                      '${settings.scanInterval.toStringAsFixed(1)} 秒',
                    ),
                  ],
                ),
              ),
              const Divider(height: 30),
              // --- バーコード種別設定 ---
              rg.RadioGroup<BarcodeScanType>(
                title: '読み取り対象バーコード',
                icon: Icons.barcode_reader,
                groupValue: settings.barcodeScanType,
                onChanged: (BarcodeScanType? value) {
                  if (value != null) {
                    settings.updateBarcodeScanType(value);
                  }
                },
                options: const [
                  rg.RadioOption(
                    title: '1次元バーコードのみ (JANコードなど)',
                    value: BarcodeScanType.oneD,
                  ),
                  rg.RadioOption(
                    title: '2次元バーコードのみ (QRコードなど)',
                    value: BarcodeScanType.twoD,
                  ),
                  rg.RadioOption(
                    title: '両方を読み取る',
                    value: BarcodeScanType.both,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
