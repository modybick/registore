import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

// 音声再生とバイブレーションを管理するサービスクラス
class SoundService {
  // AudioPlayerのインスタンスを生成
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 成功時の効果音とバイブレーションを再生する
  Future<void> playSuccessSound() async {
    try {
      // デバイスがバイブレーションをサポートしているか確認
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // 短いバイブレーションを実行
        Vibration.vibrate(duration: 100);
      }

      // 'assets/sounds/success.mp3' を再生
      // AssetSourceを使うことで、pubspec.yamlで指定したアセットフォルダからファイルを読み込む
      await _audioPlayer.play(
        AssetSource('sounds/success.mp3'),
      );
    } catch (e) {
      // エラーが発生した場合、コンソールに出力
      // (例: ファイルが見つからない、再生権限がないなど)
      //print("Success sound playback error: $e");
    }
  }

  // 失敗時の効果音とバイブレーションを再生する
  Future<void> playErrorSound() async {
    try {
      // デバイスがバイブレーションをサポートしているか確認
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // 少し長めのバイブレーションを実行して、成功時との違いを明確にする
        Vibration.vibrate(duration: 500);
      }

      // 'assets/sounds/error.mp3' を再生
      await _audioPlayer.play(
        AssetSource('sounds/error.mp3'),
      );
    } catch (e) {
      // エラーハンドリング
      //print("Error sound playback error: $e");
    }
  }

  // AudioPlayerのリソースを解放するメソッド
  // アプリケーションのライフサイクル管理で必要に応じて呼び出す
  void dispose() {
    _audioPlayer.dispose();
  }
}
