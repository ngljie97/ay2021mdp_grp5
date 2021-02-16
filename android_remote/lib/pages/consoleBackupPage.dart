import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:android_remote/globals.dart' as globals;
class ConsoleBackupPage extends StatelessWidget {
  ItemScrollController consoleLogController;
  @override

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
          child:
          Padding( 
            padding: EdgeInsets.all(20),
            child:new ScrollablePositionedList.builder(
              itemScrollController: consoleLogController,
            itemCount: globals.BackupstrArr.length,
            itemBuilder: (context, index) {
              return new Padding(
                  padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
                  child:Text(globals.BackupstrArr[index],
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),

              ));
            },
          ),),
        ),
      ),
    );


  }
}
