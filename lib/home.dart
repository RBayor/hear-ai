import 'package:flutter/material.dart';
import 'package:hearai/cameraScreen.dart';



class Home extends StatefulWidget {
  var cameras;
  Home(this.cameras);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: (){
                Navigator.pushReplacementNamed(context, "/setup");
              },
            )
          ],
          centerTitle: true,
          title: Text("Hear AI"),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.camera),),
              Tab(icon: Icon(Icons.card_travel),),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            new CameraScreen(widget.cameras),
            new Icon(Icons.text_format),
          ],
        ),
      ),
    );
  }

}