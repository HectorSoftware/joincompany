import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/AddressesModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/services/AddressService.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:sentry/sentry.dart';

import '../../main.dart';

class searchAddressWithClient extends StatefulWidget {
  _SearchAddressState createState() => _SearchAddressState();
}

/*
* ANDROID
* https://github.com/alfianlosari/flutter_placez.git
* IOS
* AIzaSyA0t37sy5FEo5QWzA16hzxX2AWfF3eYz4M
* */

class _SearchAddressState extends State<searchAddressWithClient> {

  GoogleMapController mapController;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  SentryClient sentry;
  bool llenadoListaEncontrador = false;
  static const kGoogleApiKeyy = kGoogleApiKey;
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKeyy);
  List<CustomerWithAddressModel> _ListAddress;
  ListWidgets ls = ListWidgets();

  @override
  void initState() {
    _ListAddress = new List<CustomerWithAddressModel>();
    _initialPosition = null;
    _getUserLocation();
    sentry = new SentryClient(dsn: 'https://3b62a478921e4919a71cdeebe4f8f2fc@sentry.io/1445102');

    getListAnddress();
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

    return Scaffold(
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
            Container(
              child: llenadoListaEncontrador ?
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: listaLugaresEncontrados()) :
              Container(child: Center(child: Text('No existe ubicación'),),) ,
            )
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
          icon: Container(margin: EdgeInsets.only(left: 20, top: 5), width: 10, height: 10, child: Icon(Icons.location_on),),
          hintText: "Buscar",
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
        ),
        onSubmitted: (value){
          //sendRequest2(value);
          //sendRequest(value);
        },
        onChanged: (text){
          if(_ListAddress.length != 0){
            listPlacemark = new List<CustomerWithAddressModel>();
            for(int cost= 0; cost < _ListAddress.length; cost++){
              if(ls.createState().checkSearchInText(_ListAddress[cost].address, text) && (text.length != 0)) {
                listPlacemark.add(_ListAddress[cost]);
              }
            }
            if(listPlacemark.length != 0){llenadoListaEncontrador = true;}else{llenadoListaEncontrador=false;}

            setState(() {
              listPlacemark;llenadoListaEncontrador;
            });
          }
        },
      ),
    );
  }

  List<PlacesSearchResult> places = [];


//  sendRequest2(String value) async {
//    final location = Location(_initialPosition.latitude, _initialPosition.longitude);
//    final result = await _places.searchNearbyWithRadius(location, 5000);
//
//    if (result.status == "OK") {
//      this.places = result.results;
//      String direccion = '';
//      result.results.forEach((f) {
//        direccion = f.name;
//        if(direccion.contains(value)){
//
//        }
//      });
//    } else {
//
//    }
//  }

//  sendRequest(String intendedLocation) async {
//    List<Placemark> placemark = await ObtenerDireccion(intendedLocation);
//    listPlacemark.clear();
//    _markers.clear();
//
//    var center = LatLng(_initialPosition.latitude, _initialPosition.longitude);
//    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//        target: center == null ? LatLng(0, 0) : center, zoom: 14.0)));
//
//    if(placemark !=null){
//      for(int i=0; i < placemark.length;i++){
//        double latitude = placemark[i].position.latitude;
//        double longitude = placemark[i].position.longitude;
//        LatLng destination = LatLng(latitude, longitude);
//        _addMarker(destination, intendedLocation);
//        llenadoListaEncontrador = true;
//        //listPlacemark.add(placemark[i]);
//      }
//      setState(() {
//        llenadoListaEncontrador;
//        listPlacemark;
//      });
//    }else{
//      setState(() {
//        llenadoListaEncontrador = false;
//      });
//    }
//  }

  Future<List<Placemark>> ObtenerDireccion(String Locatio)async{
    List<Placemark> placemark ;
    try{
      placemark = await Geolocator().placemarkFromAddress(Locatio);
    }catch(error, stackTrace) {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
    return placemark;
  }

  Future _addMarker(LatLng location, String address) async {
    _markers.clear();
    _markers.add(Marker(markerId: MarkerId(_lastPosition.toString()),
        position: location,
        infoWindow: InfoWindow(
          title: address,
        ),
        icon: await BitmapDescriptor.fromAssetImage(createLocalImageConfiguration(context), "assets/images/cliente.png"),
    ));
  }

  Mapa(){
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
        height: 200,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: onMapCreated,
          compassEnabled: true,
          myLocationEnabled: true,
          onCameraMove: _onCameraMove,
          markers: _markers,
          polylines: _polyLines,
        ),
      ),
    );
  }

  List<CustomerWithAddressModel> listPlacemark = new List<CustomerWithAddressModel>();
  // 0 : name - 1 : lat - 2 : log - 3 : direccion
  listaLugaresEncontrados(){
    return ListView.builder(
      itemCount: listPlacemark.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 0,top: 2,left: 5,right: 5),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(5),
                    child: RaisedButton(
                      onPressed: (){
                        var center = LatLng(listPlacemark[index].latitude, listPlacemark[index].longitude);
                        _addMarker(center,listPlacemark[index].address);
                        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                            target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
                      },
                      child: Text(listPlacemark[index].address),
                      color: Colors.transparent,
                      splashColor: Colors.transparent,
                      elevation: 0,
                    )
                ),
              ),
              Container(child: IconButton(icon: Icon(Icons.add), onPressed: (){
                Navigator.of(context).pop(listPlacemark[index]);
              })),
            ],
          ),
        );
      },
    );
  }

  getListAnddress() async {
    UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
//    var getAllAddressessResponse = await getAllAddresses(UserActiv.company,UserActiv.token);
//    AddressesModel AddresseS = AddressesModel.fromJson(getAllAddressessResponse.body);
//    if(getAllAddressessResponse.statusCode == 200){
//      for(int cantAddress = 0; cantAddress < AddresseS.data.length; cantAddress++){
//        if(AddresseS.data[cantAddress] != null){
//          _ListAddress.add(AddresseS.data[cantAddress]);
//        }
//      }
//    }

    var customersWithAddressResponse = await getAllCustomersWithAddress(UserActiv.company, UserActiv.token);
    CustomersWithAddressModel customersWithAddress = CustomersWithAddressModel.fromJson(customersWithAddressResponse.body);

    if(customersWithAddressResponse.statusCode == 200){
      for(int cantAddress = 0; cantAddress < customersWithAddress.data.length; cantAddress++){
        if(customersWithAddress.data[cantAddress].address != null){
          _ListAddress.add(customersWithAddress.data[cantAddress]);
        }
      }
    }
    setState(() {
      _ListAddress;
    });
  }
}