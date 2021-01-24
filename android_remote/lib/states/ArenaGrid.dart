import 'package:flutter/material.dart';

class ArenaGrid extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}
class _MainPage extends State<ArenaGrid> {
  List<List<String>> gridState = [
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['','','','','','','','','','','','','','',''],
    ['P1','P1','P1','','','','','','','','','','','',''],
    ['P1','P1','P1','','','','','','','','','','','',''],
    ['P1','P1','P1','','','','','','','','','','','',''],
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _buildGameBody(),
    );
  }
  Widget _buildGameBody() {
    int gridStateLength = gridState.length;
    return Column(

        children: <Widget>[
          AspectRatio(
            aspectRatio: 15/21,

            child: LayoutBuilder(builder:(context, constraints)
            {
              if(constraints.maxWidth<600)
              {
                return _buildNormalContainer();
              }
              else{
                return _buildNormalContainer();
              }
            }),
          ),
        ]);
  }
  Widget _buildGridItems(BuildContext context, int index) {
    int gridStateLength = gridState.length;
    int x, y = 0;
    x = (index / 15).floor();
    y = (index % 15);
    return GestureDetector(
      onTap: () => _gridItemTapped(x, y),
      child: GridTile(
        child: Container(

          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.5)
          ),
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
        break;    case 'P1':
      return Container(
        color: Colors.blue,
      );
      break;    case 'P2':
      return Container(
        color: Colors.yellow,
      );
      break;    case 'T':
      return Icon(
        Icons.terrain,
        size: 40.0,
        color: Colors.red,
      );
      break;    case 'B':
      return Icon(Icons.remove_red_eye, size: 40.0);
      break;    default:
      return Text('');
      break;
    }
  }
  Widget _buildNormalContainer() {
    return Center(
      child: Container(
        padding: EdgeInsets.fromLTRB(0,0,0,0),
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(0,0,0,0),

        child: GridView.builder(

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
            crossAxisCount: 15,
            childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 2),
              crossAxisSpacing:0,
              mainAxisSpacing:0,
          ),
          itemBuilder: _buildGridItems,
          itemCount: 15*20,
        ),
      ),
    );
  }

  Widget _buildWideContainers() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 10,left:10,top:20),
        decoration: BoxDecoration(

            border: Border.all(color: Colors.black, width: 2.0)
        ),
        child: GridView.builder(

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
            crossAxisCount: 15,
            childAspectRatio: 0.5,
          ),
          itemBuilder: _buildGridItems,
          itemCount: 15*20,
        ),
      ),
    );
  }
}

class _gridItemTapped {
  _gridItemTapped(int x, int y);

}