import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: "Settings",
              onPressed: (){Navigator.pushReplacementNamed(context, "/setup");},
            ),
          ],
          centerTitle: true,
          title: Text("Hear AI"),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.card_giftcard),),
              Tab(icon: Icon(Icons.card_giftcard),),
              Tab(icon: Icon(Icons.card_giftcard),),
              Tab(icon: Icon(Icons.card_giftcard),),
              Tab(icon: Icon(Icons.card_giftcard),),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Text("TAB 1"),
            Text("TAB 2"),
            Text("TAB 3"),
            Text("TAB 4"),
            Text("TAB 5"),
          ],
        ),
      ),
    );
  }
}