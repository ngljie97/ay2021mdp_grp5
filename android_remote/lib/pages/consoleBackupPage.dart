import 'package:android_remote/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ConsoleBackupPage extends StatefulWidget {
  ConsoleBackupPage();

  @override
  _ConsoleBackupPageState createState() => _ConsoleBackupPageState();
}

class _ConsoleBackupPageState extends State<ConsoleBackupPage> {
  ItemScrollController consoleLogController;

  @override
  void initState() {
    consoleLogController = ItemScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Console Logs'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: new CustomPaint(
        child: new Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Stack(children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: new ScrollablePositionedList.builder(
                itemScrollController: consoleLogController,
                itemCount: globals.BackupstrArr.length,
                itemBuilder: (context, index) {
                  return new Padding(
                      padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
                      child: Text(
                        globals.BackupstrArr[index],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ));
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: new SizedBox(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_downward,
                    size: 40.0,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    consoleLogController.scrollTo(
                        index: globals.BackupstrArr.length,
                        duration: Duration(milliseconds: 333),
                        curve: Curves.easeInOutCubic);
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
