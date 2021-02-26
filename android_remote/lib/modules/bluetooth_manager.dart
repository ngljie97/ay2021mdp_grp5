import 'dart:convert';
import 'dart:typed_data';

import 'package:android_remote/main.dart';
import 'package:android_remote/model/queueSystem.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../globals.dart';

class BluetoothController {
  static final clientID = 0;
  BluetoothDevice selectedDevice;
  BluetoothConnection connection;
  bool isConnecting = false;
  bool isDisconnecting = false;
  bool isReconnecting = false;
  BluetoothDevice server;
  bool isConnected = false;
  List<_Message> messages = List<_Message>();

  // ignore: unused_field
  String _messageBuffer = '';

  BluetoothController();

  void init() {
    print("Checking is connected...");
    print(isConnected);

    if (isConnecting) {
      BluetoothConnection.toAddress(server.address).then((_connection) {
        streamController.add('Successfully connected to ' + server.name);
        isConnected = true;
        print('Connected to the device');
        print(server.bondState.stringValue);

        connection = _connection;

        isConnecting = false;
        isDisconnecting = false;

        connection.input.listen(_onDataReceived).onDone(() {
          lastDevice = server;
          if (isDisconnecting) {
            print('Disconnecting locally!');
            streamController.add('Disconnecting locally!');
            this.disconnect();
          } else {
            this.isReconnecting = true;
            streamController.add('Disconnecting remotely!');
            streamController.add('Retrying in 3 seconds.');
            this.disconnect();
            new Future.delayed(
                const Duration(seconds: 3), () => this.reconnect());
            if (isConnected) isReconnecting = false;
          }
        });
      }).catchError((error) async {
        print(error);
        print('Cannot connect, exception occurred');
        streamController.add('Cannot connect, Socket not opened..');
        this.disconnect();
        if (isReconnecting) {
          streamController.add('Retrying in 3 seconds.');
          new Future.delayed(
              const Duration(seconds: 3), () => this.reconnect());
          if (isConnected) isReconnecting = false;
        }
      });
    }
  }

  void reconnect() {
    this.isConnecting = true;
    this.server = lastDevice;
    init();
  }

  void disconnect() {
    sendMessage('Disconnecting from remote host...');

    if (isConnected) {
      isDisconnecting = true;
      isConnected = false;
      try {
        this.connection.output.close();
        this.connection.finish();
      } catch (e) {
        connection = null;
      }
    }
  }

  Future _onDataReceived(Uint8List data) async {
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

    if (sdataString.contains(':')) QueueSys.queueTask(sdataString);

    streamController.add('Message Received from [$name]: [$sdataString]');
  }

  Future sendMessage(String text) async {
    text = text.trim();

    messages.add(_Message(clientID, text));

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text));
        await connection.output.allSent;

        messages.add(_Message(clientID, text));

        streamController.add('Message sent to Bluetooth device: [$text]');
      } catch (e) {
        // Ignore error, but notify state
        streamController.add('Disconnected remotely!');

        //this.disconnect();
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
