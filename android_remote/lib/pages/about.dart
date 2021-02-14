import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topContent = Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10.0),
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/robot.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );

    final bottomContent = Container(
      // height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      // color: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
                'This application is collaboratively developed by Group 5 of AY20/21 Semester 2 to control the Maze Exploration robot for the module CE/CZ3004 Multi-disciplinary Project.'),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[topContent, bottomContent],
      ),
    );
  }
}
