import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sentry/sentry.dart';

import '../../main.dart';

class SearchAddress extends StatefulWidget {
  _SearchAddressState createState() => _SearchAddressState();
}

/*
* ANDROID
* AIzaSyA0t37sy5FEo5QWzA16hzxX2AWfF3eYz4M
* IOS
* AIzaSyA0t37sy5FEo5QWzA16hzxX2AWfF3eYz4M
* */

class _SearchAddressState extends State<SearchAddress> {

  GoogleMapController mapController;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  SentryClient sentry;

  @override
  Future initState() {
    _getUserLocation();
    sentry = new SentryClient(dsn: 'https://3b62a478921e4919a71cdeebe4f8f2fc@sentry.io/1445102');
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
    Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          backgroundColor: PrimaryColor,
          title: new Text('Dirección'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(
            children: <Widget>[
              Botonbuscar(),
              Mapa(),
            ],
          ),
        ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(target: _initialPosition, zoom: 14);

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _getUserLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Container Botonbuscar(){
    return Container(
      height: 50.0,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey,
              offset: Offset(1.0, 5.0),
              blurRadius: 10,
              spreadRadius: 3)
        ],
      ),
      child: TextField(
        cursorColor: Colors.black,
        decoration: InputDecoration(
          icon: Container(margin: EdgeInsets.only(left: 20, top: 5), width: 10, height: 10, child: Icon(Icons.location_on, color: Colors.black,),),
          hintText: "Buscar . . .",
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
        ),
        onSubmitted: (value){
          sendRequest(value);
        },
        onChanged: (text){

        },
      ),
    );
  }

  Future<List<Placemark>> ObtenerDireccion(String Locatio)async{
    List<Placemark> placemark = null;
    try{
      placemark = await Geolocator().placemarkFromAddress(Locatio);
    }catch(e) {
      print(e.toString());
    }

    return placemark;
  }

  Future sendRequest(String intendedLocation) async {
    List<Placemark> placemark = await ObtenerDireccion(intendedLocation);
    if(placemark !=null){
      double latitude = placemark[0].position.latitude;
      double longitude = placemark[0].position.longitude;
      LatLng destination = LatLng(latitude, longitude);
      _addMarker(destination, intendedLocation);
    }

  }

  void _addMarker(LatLng location, String address){
    setState(() {
      _markers.add(Marker(markerId: MarkerId(_lastPosition.toString()),
          position: location,
          infoWindow: InfoWindow(
              title: address,
          ),
          icon: BitmapDescriptor.defaultMarker
      ));
    });
  }

  Card Mapa(){
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 200,
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
}