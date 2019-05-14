import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:joincompany/api/rutahttp.dart';
import 'package:joincompany/blocs/taskBloc.dart';
import 'package:joincompany/models/Marker.dart';

class taskHomeMap extends StatefulWidget {
  _MytaskPageMapState createState() => _MytaskPageMapState();
}

/*
* ANDROID
* AIzaSyA0t37sy5FEo5QWzA16hzxX2AWfF3eYz4M
* IOS
* AIzaSyA0t37sy5FEo5QWzA16hzxX2AWfF3eYz4M
* */

class _MytaskPageMapState extends State<taskHomeMap> {

  GoogleMapController mapController;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();

  @override
  Future initState() {
    _getUserLocation();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    double por = 0.7;
    if (mediaQueryData.orientation == Orientation.portrait) {
      por = 0.807;
    }
    return _initialPosition == null ?
    Container(
      alignment: Alignment.center,
      child: Center(
        child: CircularProgressIndicator(),
      ),) :
    Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * por,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: onMapCreated,
          myLocationEnabled: true,
          compassEnabled: true,
          onCameraMove: _onCameraMove,
          markers: _markers,
          polylines: _polyLines,
        ),
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(target: _initialPosition, zoom: 15);

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
    _addMarker();
  }

  void _getUserLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }
  List<Place> listplace = new List<Place>();
  Future _addMarker() {
    //*********************
    //EJEMPLOS PARA PRUEBAS
    //*********************
    //final TaskBloc _Bloc = BlocProvider.of<TaskBloc>(context);
    final TaskBloc _Bloc = new TaskBloc();
    //*********************
    //*********************

    // ignore: cancel_subscriptions
    StreamSubscription streamSubscription = _Bloc.outTask.listen((newVal)
    => setState(() {
      listplace = newVal;
      for(Place mark in listplace){
        _markers.add(
            Marker(
              markerId: MarkerId(mark.id.toString()),
              position: LatLng(mark.latitude, mark.longitude),
              infoWindow: InfoWindow(
                  title: mark.customer,
                  snippet: mark.address
              ),
              icon: ColorMarker(mark),
            ));
      }
      setState((){
        _markers;
        _polyLines;
      });

    }));
  }

  Future createRoute(Place mark) async {
    LatLng destination = LatLng(mark.latitude, mark.longitude);
    String route = await _googleMapsServices.getRouteCoordinates(_initialPosition, destination);

    _polyLines.add(Polyline(polylineId: PolylineId(_lastPosition.toString()),
        width: 10,
        points: convertToLatLng(decodePoly(route)),
        color: Colors.red[200]));
  }

  BitmapDescriptor ColorMarker(Place mark){
    if(mark.status == 0){ return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue); }
    if(mark.status == 2){ return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); }
    if(mark.status == 1){
      createRoute(mark);
    }
    return BitmapDescriptor.defaultMarker;
  }


  List<LatLng> convertToLatLng(List points){
    List<LatLng> result = <LatLng>[];
    for(int i = 0; i < points.length; i++){
      if(i % 2 != 0){
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List decodePoly(String poly){
    var list=poly.codeUnits;
    var lList=new List();
    int index=0;
    int len= poly.length;
    int c=0;
    do
    {
      var shift=0;
      int result=0;
      do
      {
        c=list[index]-63;
        result|=(c & 0x1F)<<(shift*5);
        index++;
        shift++;
      }while(c>=32);
      if(result & 1==1)
      {
        result=~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    }while(index<len);
    for(var i=2;i<lList.length;i++)
      lList[i]+=lList[i-2];

    return lList;
  }

}