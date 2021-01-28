import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class ArenaGrid extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<ArenaGrid> {
  List<List<String>> gridState = [
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['P1', 'P1', 'P1', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['P1', 'P1', 'P1', '', '', '', '', '', '', '', '', '', '', '', ''],
    ['P1', 'P1', 'P1', '', '', '', '', '', '', '', '', '', '', '', ''],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildGameBody(),
    );
  }

  Widget _buildGameBody() {
    int gridStateLength = gridState.length;
    return Column(children: <Widget>[
      LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            print(constraints.maxWidth);
            print(MediaQuery.of(context).size.width);
            print(MediaQuery.of(context).size.height);
            print(MediaQuery.of(context).size.aspectRatio);
            print(MediaQuery.of(context).devicePixelRatio);

            return _buildPhoneContainer();

          } else {
            print(constraints.maxWidth);
            print(MediaQuery.of(context).size.width);
            print(MediaQuery.of(context).size.height);
            print(MediaQuery.of(context).size.aspectRatio);
            print(MediaQuery.of(context).devicePixelRatio);
            return _buildTabletContainer();
          }
        }),

    ]);
  }

  Widget _buildGridItems(BuildContext context, int index) {
    int gridStateLength = gridState.length;
    int x, y = 0;
    x = (index / 15).floor();
    y = (index % 15);
    return GestureDetector(
      // onTap: () => showDialog(
      //   context: context,
      //   builder: (BuildContext context) => _buildPopupDialog(context, x, y),
      // ),
      child: GridTile(
        child: Container(
          decoration: BoxDecoration(

              border: Border.all(color: Colors.blueGrey, width: 0.1)),
          child: Center(
            child: _buildGridItem(x, y),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(int x, int y) {
    switch (gridState[x][y]) {
      case '':
        return Text('');
        break;
      case 'P1':
        return Container(
          color: Colors.blue,
        );
        break;
      case 'P2':
        return Container(
          color: Colors.yellow,
        );
        break;
      case 'T':
        return Icon(
          Icons.terrain,
          size: 40.0,
          color: Colors.red,
        );
        break;
      case 'B':
        return Icon(Icons.remove_red_eye, size: 40.0);
        break;
      default:
        return Text('');
        break;
    }
  }

  Widget _buildTabletContainer() {
    return
      AspectRatio(

        aspectRatio: MediaQuery.of(context).devicePixelRatio/(MediaQuery.of(context).devicePixelRatio+(MediaQuery.of(context).devicePixelRatio*(MediaQuery.of(context).size.aspectRatio/10))),

    child:Center(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 15,
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / 2),
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemBuilder: _buildGridItems,
          itemCount: 15 * 20,
        ),
      ),
    ),);
  }
  Widget _buildPhoneContainer() {
    return
      AspectRatio(
        aspectRatio: MediaQuery.of(context).devicePixelRatio/(MediaQuery.of(context).devicePixelRatio+(MediaQuery.of(context).devicePixelRatio*(MediaQuery.of(context).size.aspectRatio))),
        child:Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 15,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 2),
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
              itemBuilder: _buildGridItems,
              itemCount: 15 * 20,
            ),
          ),
        ),);
  }

}

Widget _buildPopupDialog(BuildContext context, int x, int y) {
  return new AlertDialog(
    title: const Text('Selected Position'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('x = $x, y = $y'),
      ],
    ),
    actions: <Widget>[
      new FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        textColor: Theme.of(context).primaryColor,
        child: const Text('Close'),
      ),
    ],
  );
}
