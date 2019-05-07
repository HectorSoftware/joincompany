import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class taskHomeMap extends StatefulWidget {
  _MytaskPageMapState createState() => _MytaskPageMapState();
}

class _MytaskPageMapState extends State<taskHomeMap> {

  GoogleMapController mapController;

  @override
  Future initState() {
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

    );
  }
}