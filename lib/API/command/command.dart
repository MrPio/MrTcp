import 'package:mr_tcp/API/web_socket_manager.dart';

abstract class Command {
  execute(Map<String, dynamic> cmd) {
    WebSocketManager.getInstance().currentCommand = null;
  }
}
