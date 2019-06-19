import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/api/rutahttp.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/DirectionSModel.dart' as direct;
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:sentry/sentry.dart';
import "package:google_maps_webservice/places.dart";
import '../../main.dart';

class SearchAddressWithClient extends StatefulWidget {
  _SearchAddressState createState() => _SearchAddressState();
}

/*
* ANDROID
* https://github.com/alfianlosari/flutter_placez.git
* IOS
* AIzaSyA0t37sy5FEo5QWzA16hzxX2AWfF3eYz4M
* */

class _SearchAddressState extends State<SearchAddressWithClient> {

  GoogleMapController mapController;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  SentryClient sentry;
  bool llenadoListaEncontrador = false;
  static const kGoogleApiKeyy = kGoogleApiKey;
  List<CustomerWithAddressModel> _listAddress;
  List<CustomerWithAddressModel> _listAddressGoogle;
  ListWidgets ls = ListWidgets();

  @override
  void initState() {
    _listAddress = new List<CustomerWithAddressModel>();
    _listAddressGoogle = new List<CustomerWithAddressModel>();
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
            botonbuscar(),
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
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
   // List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Container botonbuscar(){
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

          listPlacemark.clear();
          listAndressGoogleInt.clear();
          _listAddressGoogle.clear();

          //LISTAR TAREAS DE BASE DE DATOS
          if(_listAddress.length != 0){
            for(int cost= 0; cost < _listAddress.length; cost++){
              if(ls.createState().checkSearchInText(_listAddress[cost].address, text) && (text.length != 0)) {
                _listAddressGoogle.add(_listAddress[cost]);
              }
            }
          }

          //BUSCAR DIRECCIONES DE MAPA
          GoogleMapsSearchPlace _googleMapsServices = GoogleMapsSearchPlace();
          direct.DirectionsModel directions = new direct.DirectionsModel();
          directions = await _googleMapsServices.getSearchPlace(_initialPosition,kGoogleApiKeyy,text);
          if(directions.status == 'OK'){
            for(var value in directions.candidates){
              CustomerWithAddressModel AuxAddressModel = new CustomerWithAddressModel(
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
              if (existe == false) {
                listAndressGoogleInt.add(_listAddressGoogle.length);
                _listAddressGoogle.add(AuxAddressModel);
              }
            }
          }


          List<CustomerWithAddressModel> _listAddressGoogleAux = _listAddressGoogle;
          if (_listAddressGoogleAux.length != 0) {
            for(var valu in _listAddressGoogleAux){
              listPlacemark.add(valu);
            }
            setState(() {
              listPlacemark;
              llenadoListaEncontrador = true;
            });
          }

          if(_listAddressGoogle.length == 0){
            setState(() {
              llenadoListaEncontrador=false;
            });
          }






        },
      ),
    );
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

  List<CustomerWithAddressModel> listPlacemark = new List<CustomerWithAddressModel>();
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
              Container(child: IconButton(icon: Icon(Icons.add), onPressed: (){
                Navigator.of(context).pop(listPlacemark[index]);
              })) ,
            ],
          ),
        );
      },
    );
  }

  getListAnddress() async {

    //DIRECCIONES LOCALES
    UserDataBase userActivity = await ClientDatabaseProvider.db.getCodeId('1');
    var customersWithAddressResponse = await getAllCustomersWithAddress(userActivity.company, userActivity.token);
    CustomersWithAddressModel customersWithAddress = CustomersWithAddressModel.fromJson(customersWithAddressResponse.body);
    if(customersWithAddressResponse.statusCode == 200){
      for(int cantAddress = 0; cantAddress < customersWithAddress.data.length; cantAddress++){
        if(customersWithAddress.data[cantAddress].address != null){
          _listAddress.add(customersWithAddress.data[cantAddress]);
        }
      }
      setState(() {
        _listAddress;
      });
    }

  }
}