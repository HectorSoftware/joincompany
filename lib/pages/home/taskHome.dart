import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/pages/home/TaskHomeMap.dart';
import 'package:joincompany/pages/home/TaskHomeTask.dart';

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
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white,
      labelStyle: TextStyle(fontSize: 20),
      indicatorColor: Colors.lightBlue,
      tabs: <Tab>[
        Tab(text: "Tarea"),
        Tab(text: "Mapa"),
      ],
      controller: _controller,
    );
  }

  TabBarView getTabBarView(){
    return TabBarView(
      children: <Widget>[
        taskHomeTask(),
        taskHomeMap(),
      ],
      controller: _controller,
    );
  }

}