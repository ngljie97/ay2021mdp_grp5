import 'package:android_remote/states/ArenaGrid.dart';
import 'package:android_remote/states/MyHomePage.dart';
import 'package:android_remote/states/SettingsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class App extends StatefulWidget {
  final String title;
  App({Key key, this.title}) : super(key: key);

  _AppState createState() => _AppState();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: App(title: 'Robot Controller'),
    );
  }
}

class _AppState extends State<App> {
  PageController _myPage;
  var selectedPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _buildLayout(),
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
          _buildTopLayout()
          ,_buildBottomLayout()
          ,

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
          Container(
            //Top Left Drawer Button
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(Icons.menu),
              color: Colors.black45,
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new SettingsPage()));
              },
            ),
          ),
        ],
      ),
    );
        }
  Widget _buildBottomLayout() {
    return Expanded(
      flex:1,
      child: Container(
        color: Colors.blueAccent,
        alignment: Alignment.bottomCenter,
        child:
        Row(
          children: [
           Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*2*/
                  Container(
                      padding: const EdgeInsets.only(bottom: 8,top:5,left:5),
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

                      )

                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 8,top:5,left:5),
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
