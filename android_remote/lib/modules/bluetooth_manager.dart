import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothController {
  static final clientID = 0;
  BluetoothDevice selectedDevice;
  BluetoothConnection connection;
  bool isConnecting = false;
  bool isDisconnecting = false;
  BluetoothDevice server;
  bool isConnected = false;
  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';
  Function callback;

  BluetoothController(this.callback);

  void init() {
    print("Checking is connected...");
    print(isConnected);

    if (isConnecting) {
      BluetoothConnection.toAddress(server.address).then((_connection) {
        callback(
            'addConsoleAndScroll', 'Successfully connected to ' + server.name);
        isConnected = true;
        print('Connected to the device');

        connection = _connection;

        isConnecting = false;
        isDisconnecting = false;

        connection.input.listen(_onDataReceived).onDone(() {
          if (isDisconnecting) {
            print('Disconnecting locally!');
            callback('addConsoleAndScroll', 'Disconnecting locally!');
            connection.dispose();
          } else {
            print('Disconnected remotely!');
            callback('addConsoleAndScroll', 'Disconnecting remotely!');
            connection.dispose();
          }
        });
      }).catchError((error) {
        print('Cannot connect, exception occurred');
        callback('addConsoleAndScroll', 'Cannot connect, Socket not opened');
        print(error);
      });
    }
  }

  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      try {
        connection.dispose();
      } catch (e) {
        // do nothing}
        connection = null;
      }
    }
  }

  void disconnect() {
    sendMessage('Disconnecting from remote host...');
    this.dispose();
    isConnecting = false;
    isConnected = false;
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    String name = this.server.name;

    String sdataString = dataString.trim();
    callback('addConsoleAndScroll',
        'Message Received from [$name]:\n[$sdataString]');
  }

  void sendMessage(String text) async {
    text = text.trim();

    messages.add(_Message(clientID, text));

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text));
        await connection.output.allSent;

        messages.add(_Message(clientID, text));
        callback('addConsoleAndScroll',
            'Message sent to Bluetooth device:\n[$text]');
      } catch (e) {
        // Ignore error, but notify state
        callback('addConsoleAndScroll',
            'Disconnected remotely!\nMessage was not sent to Bluetooth device. [$text]');
        this.disconnect();
      }
    }
  }
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);

  String getText() {
    return this.text;
  }
}
