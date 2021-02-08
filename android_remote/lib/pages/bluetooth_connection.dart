
import 'dart:async';

import 'package:android_remote/states/BluetoothDeviceListEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../globals.dart';
import 'ChatPage.dart';

class ConnectionPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const ConnectionPage({this.checkAvailability = true});

  @override
  _ConnectionPage createState() => new _ConnectionPage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _ConnectionPage extends State<ConnectionPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  String _address = "...";
  String _name = "...";
  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>();

  // Availability
  StreamSubscription<BluetoothDiscoveryResult> _discoveryStreamSubscription;
  bool _isDiscovering;

  _ConnectionPage();

  @override
  void initState() {
    super.initState();

    //added
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });
    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });


    //end


    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {

    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
            device,
            widget.checkAvailability
                ? _DeviceAvailability.maybe
                : _DeviceAvailability.yes,
          ),
        )
            .toList();
      });
    });
  }

  void _restartDiscovery() async{

    Navigator.pop(context);
    // Navigator.of(context).push(
    //   PageRouteBuilder(pageBuilder: (_, __, ___) => SelectBondedDevicePage(checkAvailability: false),
    //     transitionDuration: Duration(seconds: 0),),
    //
    // );
    selectedDevice =
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ConnectionPage(checkAvailability: false);
        },
      ),
    );


    setState(() {
      _isDiscovering = false;
    });

  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<BluetoothDeviceListEntry> list = devices.map((_device) => BluetoothDeviceListEntry(
      device: _device.device,
      rssi: _device.rssi,
      enabled: _device.availability == _DeviceAvailability.yes,
      onTap: () {

        Navigator.of(context).pop(_device.device);
      },
    ))
        .toList();
    return Scaffold(
        appBar: AppBar(
          title: Text('Select device'),

          actions: <Widget>[
            _isDiscovering
                ? FittedBox(
              child: Container(
                margin: new EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ),
            )
                : IconButton(
              icon: Icon(Icons.replay),
              onPressed: _restartDiscovery,
            )
          ],
        ),
        body:
        Container(
            child:
            Column(

                children:<Widget>[
                  SwitchListTile(
                    title: const Text('Bluetooth Status'),
                    value: _bluetoothState.isEnabled,
                    onChanged: (bool value) {
                      // Do the request and update with the true value then
                      future() async {
                        // async lambda seems to not working
                        if (value)
                          await FlutterBluetoothSerial.instance.requestEnable();
                        else{
                          await FlutterBluetoothSerial.instance.requestDisable();
                        }
                      }

                      future().then((_) {
                        setState(() {
                          _restartDiscovery();
                        });
                      });
                    },
                  ),
                  Expanded( // wrap in Expanded
                    child:

                    ListView(children: list),
                  ),
                ]
            )
        )
      // This trailing comma makes auto-formatting nicer for build methods.

    );
  }
}
void _startChat(BuildContext context, BluetoothDevice server) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return ChatPage(server: server);
      },
    ),
  );
}