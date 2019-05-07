import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';

class taskHomePage extends StatefulWidget {
  _MytaskPageState createState() => _MytaskPageState();
}

class _MytaskPageState extends State<taskHomePage> with SingleTickerProviderStateMixin{
  TabController _controller;

  @override
  Future initState() {
    _controller = TabController(length: 2, vsync:this );
    super.initState();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: PrimaryColor,
        title: new Text(' '),
        bottom: getTabBar(),
      ),
      body: getTabBarView(),
    );

  }
  TabBar getTabBar(){
    return TabBar(
      tabs: <Tab>[
        Tab(text: "Tareas"),
        Tab(text: "Mapa"),
      ],
      controller: _controller,
    );
  }

  TabBarView getTabBarView(){
    return TabBarView(
      children: <Widget>[
        null,
        null
      ],
      controller: _controller,
    );
  }

}