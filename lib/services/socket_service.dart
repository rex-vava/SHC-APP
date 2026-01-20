import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;

  void connect(String userId) {
    socket = IO.io(
      'http://192.168.X.X:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      print('Socket connected');
      socket!.emit('join', userId);
    });

    socket!.onDisconnect((_) {
      print('Socket disconnected');
    });
  }

  void onAppointmentUpdated(Function(dynamic) callback) {
    socket?.on('appointmentUpdated', callback);
  }

  void disconnect() {
    socket?.disconnect();
  }
}
