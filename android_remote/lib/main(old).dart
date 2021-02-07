import 'package:android_remote/states/ArenaGrid.dart';
import 'package:flutter/material.dart';

import 'page_master.dart';
import 'router.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: CRouter.generateRoute,
      initialRoute: homeRoute,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: CustomTheme.themeColor,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class App extends StatefulWidget {
  final String title;

  App({Key key, this.title}) : super(key: key);

  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  PageController _myPage;
  var selectedPage;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        body: _buildLayout(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _myPage = PageController(initialPage: 1);
    selectedPage = 1;
  }

  Widget _buildLayout() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildTopLayout(),
          _buildBottomLayout(),
        ],
      ),
    );
  }

  Widget _buildTopLayout() {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            //Arena Layout
            child: ArenaGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLayout() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.blueAccent,
        alignment: Alignment.bottomCenter,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                    padding: const EdgeInsets.only(bottom: 8, top: 5, left: 5),
                    child: Row(
                      children: [
                        Text(
                          'STATUS ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.red[500],
                        ),
                        Text(
                          ' CONNECTION ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.red[500],
                        ),
                        Text(
                          ' WAYPOINT ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.red[500],
                        ),
                      ],
                    )),
                Container(
                  padding: const EdgeInsets.only(bottom: 8, top: 5, left: 5),
                  child: Text(
                    'Console Log',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            /*3*/
            Icon(
              Icons.star,
              color: Colors.red[500],
            ),
            Text('41'),
          ],
        ),
      ),
    );
  }
}
