import 'dart:async';
import 'dart:typed_data';
import 'package:mic_stream/mic_stream.dart';
import '../../API/web_socket_manager.dart';

class MicrophoneManager {
  static MicrophoneManager? _instance;

  WebSocketManager get _webSocketManager => WebSocketManager.getInstance();
  Stream<Uint8List>? microphoneStream;
  StreamSubscription<Uint8List>? microphoneStreamSubscription;
  int pkgSent = 0;

  MicrophoneManager._();

  static MicrophoneManager getInstance() {
    _instance ??= MicrophoneManager._();
    return _instance!;
  }

  close() async {
    await microphoneStreamSubscription?.cancel();
  }

  open() async {
    pkgSent = 0;
    microphoneStream = await MicStream.microphone(
      sampleRate: 44100,
      audioFormat: AudioFormat.ENCODING_PCM_16BIT,
      audioSource: AudioSource.MIC,
      channelConfig: ChannelConfig.CHANNEL_IN_MONO,
    );
    microphoneStreamSubscription = microphoneStream?.listen((samples) {
      print(pkgSent*samples.lengthInBytes);
      _webSocketManager.sendBytes(samples);
      ++pkgSent;
    });
  }
}
