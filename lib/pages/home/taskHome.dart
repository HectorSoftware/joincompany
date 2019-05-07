import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';

class taskHomePage extends StatefulWidget {
  _MytaskPageState createState() => _MytaskPageState();
}

class _MytaskPageState extends State<taskHomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: PrimaryColor,
        title: new Text('Distancia maxima $kmActual Km'),
        bottom: getTabBar(),
      ),
      body: getTabBarView(),
    );

  }
  TabBar getTabBar(){
    return TabBar(
      tabs: <Tab>[
        Tab(icon: Icon(Icons.directions_car)),
        Tab(icon: Icon(Icons.bookmark)),
        Tab(icon: Icon(Icons.attach_money)),
        Tab(icon: Icon(Icons.star)),
      ],
      controller: _controller,
    );
  }

  TabBarView getTabBarView(){
    return TabBarView(
      children: <Widget>[
        marcador_distancia(mapController: widget.mapController, markerMap: widget.markerMap,kmActual: kmActual,tiposGasActual: tipoGasActual,MelatLng: MelatLng,),
        marcador_marca(mapController: widget.mapController, markerMap: widget.markerMap,kmActual: kmActual,MelatLng: MelatLng,TipoGasActual: tipoGasActual,),
        marcador_precio(mapController: widget.mapController, markerMap: widget.markerMap,kmActual: kmActual,MelatLng: MelatLng,tgActual: tipoGasActual,),
        marcador_fav(mapController: widget.mapController, markerMap: widget.markerMap,kmActual: kmActual,MelatLng: MelatLng,),
      ],
      controller: _controller,
    );
  }

}