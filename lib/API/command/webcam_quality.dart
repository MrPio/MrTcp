import 'package:mr_tcp/API/command/command.dart';
import '../../method_channelling/yuv_chanelling.dart';

class WebcamQuality extends Command {
  @override
  execute(Map<String, dynamic> cmd) {
    super.execute(cmd);
    if (cmd['value'] is int) {
      YuvChannelling.jpegQuality = cmd['value'];
    }
  }
}
