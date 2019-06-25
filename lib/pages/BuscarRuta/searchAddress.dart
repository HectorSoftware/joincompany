import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/api/rutahttp.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/AddressesModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/services/AddressService.dart';
import 'package:sentry/sentry.dart';
import 'package:joincompany/models/DirectionSModel.dart' as direct;

import '../../main.dart';

class SearchAddress extends StatefulWidget {
  _SearchAddressState createState() => _SearchAddressState();
}

/*
* ANDROID
* https://github.com/alfianlosari/flutter_placez.git
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
  bool llenadoListaEncontrador = false;
  static const kGoogleApiKeyy = kGoogleApiKey;
  List<AddressModel> _listAddress;
  ListWidgets ls = ListWidgets();

  @override
  void initState() {
    _listAddress = new List<AddressModel>();
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
            botonSearch(),
            mapView(),
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
    try{
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    }on Exception{
      setState(() {
        _initialPosition = LatLng(0, 0);
      });
    }

  }

  Container botonSearch(){
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
        onChanged: (text) async {
          //await Future.delayed(Duration(seconds: 2, milliseconds: 0));

          List<AddressModel> _listAddressBD = new List<AddressModel>();
          List<AddressModel> _listAddressGoogle= new List<AddressModel>();

          setState(() {
            listPlacemark.clear();
            listAndressGoogleInt.clear();
          });

          //LISTAR TAREAS DE BASE DE DATOS
          if(_listAddress.length != 0){
            for(int cost= 0; cost < _listAddress.length; cost++){
              bool existe = true;
              if(ls.createState().checkSearchInText(_listAddress[cost].address, text) && (text.length != 0)) {
                for (int cost1 = 0; cost1 < _listAddressBD.length; cost1++) {
                  if ((_listAddressBD[cost1].latitude == _listAddress[cost].latitude)&&
                      _listAddressBD[cost1].longitude == _listAddress[cost].longitude) {
                    existe = false;
                  }
                }
                for (int cost2 = 0; cost2 < listPlacemark.length; cost2++) {
                  if ((listPlacemark[cost2].latitude == _listAddress[cost].latitude)&&
                      listPlacemark[cost2].longitude == _listAddress[cost].longitude) {
                    existe = false;
                  }
                }
                if(existe){
                  _listAddressBD.add(_listAddress[cost]);
                }
              }
            }
            for(var valu in _listAddressBD){
              listPlacemark.add(valu);
            }
            setState(() {
              _listAddressBD;
            });
          }

          //BUSCAR DIRECCIONES DE MAPA
          try{
            _listAddressGoogle = await SearchDirectionGooogle(text);
          }catch(e){ }

          if (_listAddressGoogle.length != 0 || _listAddressBD.length != 0) {
            setState(() {
              listPlacemark;
              listAndressGoogleInt;
              llenadoListaEncontrador = true;
            });
          }

          if(_listAddressGoogle.length == 0 && _listAddressBD.length == 0){
            setState(() {
              listPlacemark.clear();
              listAndressGoogleInt.clear();
              llenadoListaEncontrador=false;
            });
          }
        },
      ),
    );
  }

  int conteo = 0;
  Future<List<AddressModel>> SearchDirectionGooogle(String text) async {
    List<AddressModel> _listAddressGoogle= new List<AddressModel>();
    GoogleMapsSearchPlace _googleMapsServices = GoogleMapsSearchPlace();
    direct.DirectionsModel directions = new direct.DirectionsModel();
    directions = await _googleMapsServices.getSearchPlace(_initialPosition,kGoogleApiKeyy,text);
    if(directions.status == 'OK'){
      for(var value in directions.candidates){
        AddressModel AuxAddressModel = new AddressModel(
            address: value.formattedAddress + ',' + value.name,
            latitude: value.geometry.location.lat,
            longitude: value.geometry.location.lng,
            googlePlaceId: value.id
        );
        bool existe = false;
        for (int cost = 0; cost < _listAddress.length; cost++) {
          if ((_listAddress[cost].latitude == AuxAddressModel.latitude)&&
              _listAddress[cost].longitude == AuxAddressModel.longitude) {
            existe = true;
          }
        }

        for (int cost = 0; cost < listPlacemark.length; cost++) {
          if ((listPlacemark[cost].latitude == AuxAddressModel.latitude)&&
              listPlacemark[cost].longitude == AuxAddressModel.longitude) {
            existe = true;
          }
        }

        if (existe == false) {
          listAndressGoogleInt.add(listPlacemark.length);
          _listAddressGoogle.add(AuxAddressModel);
          listPlacemark.add(AuxAddressModel);
        }
      }
      setState(() {
        listAndressGoogleInt;
        _listAddressGoogle;
        listPlacemark;
      });
    }
    return _listAddressGoogle;
  }

  List<PlacesSearchResult> places = [];
  List<int> listAndressGoogleInt = new List<int>();
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

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

  mapView(){
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

  List<AddressModel> listPlacemark = new List<AddressModel>();

  // 0 : name - 1 : lat - 2 : log - 3 : direccion
  listaLugaresEncontrados(){
    return ListView.builder(
      itemCount: listPlacemark.length,
      itemBuilder: (context, index) {

        bool isGoogle = false;
        for(int value in listAndressGoogleInt){
          if(index == value){
            isGoogle = true;
          }
        }
        return Card(
          margin: EdgeInsets.only(bottom: 0,top: 2,left: 5,right: 5),
          child: Row(
            children: <Widget>[
              Container(child: isGoogle ? Icon(Icons.map) : Icon(Icons.dns)),
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
              /*isGoogle ?  Container() : */Container(child: IconButton(icon: Icon(Icons.add), onPressed: (){
                Navigator.of(context).pop(listPlacemark[index]);
              })),
            ],
          ),
        );
      },
    );
  }

  getListAnddress() async {
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    var addressResponse = await getAllAddresses(user.company, user.rememberToken);
    AddressesModel address = AddressesModel.fromJson(addressResponse.body);
    if(addressResponse.statusCode == 200){
      for(int cantAddress = 0; cantAddress < address.data.length; cantAddress++){
        if(address.data[cantAddress].address != null){
          _listAddress.add(address.data[cantAddress]);
        }
      }

      setState(() {
        _listAddress;
      });
    }



  }
}