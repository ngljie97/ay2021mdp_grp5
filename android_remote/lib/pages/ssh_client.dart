import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:ssh/ssh.dart';
import 'package:synchronized/synchronized.dart';

bool isConnected = false;
final terminateChar = '\x03';

class SshTerminalPage extends StatefulWidget {
  const SshTerminalPage();

  @override
  _SshTerminal createState() => new _SshTerminal();
}

class _SshTerminal extends State<SshTerminalPage> {
  SSHClient client;
  final _scrollController = ItemScrollController();
  final terminalController = TextEditingController();
  final _lock = new Lock();
  List<String> historyLog = [
    '==========================================================='
  ];

  _SshTerminal();

  @override
  void initState() {
    super.initState();
    printLog('Connecting to RPi...');
    connectRpi();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    terminalController.dispose();
    client.disconnect();
    super.dispose();
  }

  void printLog(String command) {
    setState(() {
      historyLog.add(command);
      if (historyLog.length > 5)
        _scrollController.scrollTo(
            index: historyLog.length,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic);
    });
  }

  Future<void> connectRpi() async {
    client = new SSHClient(
      host: "192.168.5.5",
      port: 22,
      username: "pi",
      passwordOrKey: "MdpGroup5",
    );

    /*client = new SSHClient(
      host: "192.168.66.66",
      port: 22,
      username: "pi",
      passwordOrKey: "@dmin123",
    );*/

    try {
      String result = await client.connect();
      if (result == "session_connected") {
        result = await client.startShell(
            ptyType: "vanilla",
            callback: (dynamic res) async => await _callbackHandler(res));

        if (result == "shell_started") {
          isConnected = true;
        }
      }
    } on PlatformException catch (e) {
      printLog('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SSH Terminal'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.loop),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return new SshTerminalPage();
                  },
                ),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  child: new ScrollablePositionedList.builder(
                    itemScrollController: _scrollController,
                    itemCount: historyLog.length,
                    itemBuilder: (context, index) {
                      return new Padding(
                        padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
                        child: Text(historyLog[index]),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  (isConnected)? Text('${client.username}@${client.host}:~\$ '): Text('Not connected...'),
                  Expanded(
                    flex: 9,
                    child: TextField(
                      controller: terminalController,
                      decoration: InputDecoration(labelText: 'Enter commands'),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () =>
                          (isConnected && terminalController.text.isNotEmpty)
                              ? _sendCommand(terminalController.text)
                              : null,
                      icon: Icon(Icons.send),
                      enableFeedback: isConnected,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => startRpiServer(1),
                    child: Text('Start RPi Server'),
                  ),
                  TextButton(
                    onPressed: () async => await _sendCommand(terminateChar),
                    child: Text('CTRL-C'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendCommand(String command) async {
    terminalController.clear();
    await client.writeToShell(command + '\r\n');
    if (command.toUpperCase().trim() == 'EXIT') _disconnectRpi();
  }

  void _disconnectRpi() {
    client.closeShell();
    client.disconnect();
    isConnected = false;
    printLog('Successfully disconnected from RPi SSH.');
  }

  Future<void> _callbackHandler(String res) async {
    printLog(res + '\r\n');
  }

  void startRpiServer(int flag) async {
    List<String> commandList = [
      'cd ~/comm',
      'workon cv',
      'python3 nocam_noIR.py'
    ];

    for (int i = 0; i < commandList.length; i++) {
      await _lock.synchronized(() async => await _sendCommand(commandList[i]));
    }
  }
}
