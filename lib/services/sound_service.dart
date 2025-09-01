import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

// 音声再生とバイブレーションを管理するサービスクラス
class SoundService {
  // --- 1. シンプルで一般的なシングルトンパターンに修正 ---
  // 唯一のインスタンスを保持するstatic final変数
  static final SoundService instance =
      SoundService._internal();
  // プライベートなコンストラクタ
  SoundService._internal();
  // (オプション) SoundService()で常に同じインスタンスを返すfactoryコンストラクタ
  factory SoundService() {
    return instance;
  }

  final AudioPlayer _successPlayer = AudioPlayer(
    playerId: 'success',
  );
  final AudioPlayer _errorPlayer = AudioPlayer(
    playerId: 'error',
  );

  final AudioPlayer _checkoutPlayer = AudioPlayer(
    playerId: 'chekout',
  );

  final AudioPlayer _decrementPlayer = AudioPlayer(
    playerId: 'decrement',
  );

  /// アプリ起動時に一度だけ呼び出し、音声をメモリにロードする
  /// このメソッドはmain()関数から呼び出す
  Future<void> init() async {
    // PlayerModeを設定して、再生遅延を最小化する
    await _successPlayer.setPlayerMode(
      PlayerMode.lowLatency,
    );
    await _errorPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _checkoutPlayer.setPlayerMode(
      PlayerMode.lowLatency,
    );
    await _decrementPlayer.setPlayerMode(
      PlayerMode.lowLatency,
    );

    // 再生後に停止状態にする設定 (毎回最初から再生するため)
    await _successPlayer.setReleaseMode(ReleaseMode.stop);
    await _errorPlayer.setReleaseMode(ReleaseMode.stop);
    await _checkoutPlayer.setReleaseMode(ReleaseMode.stop);
    await _decrementPlayer.setReleaseMode(ReleaseMode.stop);

    // ボリューム設定
    await _successPlayer.setVolume(0.35);
    await _errorPlayer.setVolume(1.0);
    await _checkoutPlayer.setVolume(1.0);
    await _decrementPlayer.setVolume(0.5);

    // --- 3. 音声ファイルの事前ロード処理を追加 ---
    await _successPlayer.setSource(
      AssetSource('sounds/success.mp3'),
    );
    await _errorPlayer.setSource(
      AssetSource('sounds/error.mp3'),
    );
    await _checkoutPlayer.setSource(
      AssetSource('sounds/checkout.mp3'),
    );
    await _decrementPlayer.setSource(
      AssetSource('sounds/decrement.mp3'),
    );
  }

  // 成功時の効果音とバイブレーションを再生する
  Future<void> playSuccessSound() async {
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100);
      }
      // 事前ロード済みの音声を再生
      await _playSound(_successPlayer);
    } catch (e) {
      // print("Success sound playback error: $e");
    }
  }

  // 失敗時の効果音とバイブレーションを再生する
  Future<void> playErrorSound() async {
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 500);
      }
      // 事前ロード済みの音声を再生
      await _playSound(_errorPlayer);
    } catch (e) {
      // print("Error sound playback error: $e");
    }
  }

  Future<void> playCheckoutSound() async {
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 300);
      }
      // 事前ロード済みの音声を再生
      await _playSound(_checkoutPlayer);
    } catch (e) {
      // print("Error sound playback error: $e");
    }
  }

  Future<void> playDecrementSound() async {
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100);
      }
      // 事前ロード済みの音声を再生
      await _playSound(_decrementPlayer);
    } catch (e) {
      // print("Error sound playback error: $e");
    }
  }

  // 共通の再生ロジック
  Future<void> _playSound(AudioPlayer player) async {
    // もし再生中なら一度止めて、カーソルを先頭に戻す
    await player.stop();
    // 再生を開始する
    await player.resume();
  }

  // AudioPlayerのリソースを解放する (通常シングルトンでは不要だが念のため)
  void dispose() {
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _checkoutPlayer.dispose();
    _decrementPlayer.dispose();
  }
}
