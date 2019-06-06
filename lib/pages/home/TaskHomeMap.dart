import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:joincompany/api/rutahttp.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/blocs/blocListTaskCalendar.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/Marker.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:joincompany/widgets/FormTaskNew.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_picker_saver/image_picker_saver.dart';

class taskHomeMap extends StatefulWidget {
  _MytaskPageMapState createState() => _MytaskPageMapState();

  taskHomeMap({this.blocListTaskCalendarReswidget,this.listCalendarRes});

  final blocListTaskCalendar blocListTaskCalendarReswidget;
  final List<DateTime> listCalendarRes;
}

/*
* ANDROID
* AIzaSyA0t37sy5FEo5QWzA16hzxX2AWfF3eYz4M
* IOS
* AIzaSyA0t37sy5FEo5QWzA16hzxX2AWfF3eYz4M
* */

enum markersId {
  none,
  markerRed,
}

class _MytaskPageMapState extends State<taskHomeMap> {

  GoogleMapController mapController;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  static const kGoogleApiKeyy = kGoogleApiKey;
  StreamSubscription streamSubscription;
  blocListTaskCalendar blocListTaskCalendarRes;
  DateTime FechaActual = DateTime.now();
  List<DateTime> listCalendar = new List<DateTime>();

  @override
  Future initState() {
    _getUserLocation();
    listCalendar = widget.listCalendarRes;
    FechaActual = listCalendar[1];
    super.initState();
  }

  @override
  void dispose(){
    blocListTaskCalendarRes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    double por = 0.7;
    if (mediaQueryData.orientation == Orientation.portrait) {
      por = 0.807;
    }

    blocListTaskCalendarRes = widget.blocListTaskCalendarReswidget;
    try{
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscriptionCalendar = blocListTaskCalendarRes.outTaksCalendarMap.listen((onData)
      => setState((){
        listplace.clear();
        _addMarker(onData[0]);
      }));
    }catch(e){}

    return _initialPosition == null ?
    Container(
      alignment: Alignment.center,
      child: Center(
        child: CircularProgressIndicator(),
      ),) :
    Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Stack(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * por,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: onMapCreated,
              myLocationEnabled: true,
              compassEnabled: true,
              zoomGesturesEnabled: true,
              onCameraMove: _onCameraMove,
              markers: _markers,
              polylines: _polyLines,
            ),
          ),
          Positioned(
            right: 15.0,
            bottom: 10.0,
            child: ButtonListCLient(),
          ),
        ],
      )
    );
  }

  void _onCameraMove(CameraPosition position) {
    //setState(() {
      _lastPosition = position.target;
    //});
  }

  static CameraPosition _kGooglePlex = CameraPosition(target: _initialPosition, zoom: 15);

  void onMapCreated(controller) {
    //setState(() {
      mapController = controller;
    //});
    _addMarker(FechaActual);
  }

  void _getUserLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    //setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    //});
  }

  List<Place> listplace = new List<Place>();
  Future _addMarker(DateTime hasta) async {

    List<Place> _listMarker = new List<Place>();

    String diadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 00:00:00';
    String hastadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 23:59:59';

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    var getAllTasksResponse = await getAllTasks(user.company, user.rememberToken, beginDate : diadesde, endDate : hastadesde, responsibleId: user.id.toString());
    TasksModel tasks = TasksModel.fromJson(getAllTasksResponse.body);
    status sendStatus = status.cliente;
    for(int i=0; i < tasks.data.length;i++){
      Place marker;
      String valadde = 'N/A';
      if(tasks.data[i].address != null){
        valadde = tasks.data[i].address.address;
        if(tasks.data[i].status == 'done'){sendStatus = status.culminada;}
        if(tasks.data[i].status == 'working' || tasks.data[i].status == 'pending'){sendStatus = status.planificado;}
        marker = Place(id: tasks.data[i].id, customer: tasks.data[i].name, address: valadde,latitude: tasks.data[i].address.latitude,longitude: tasks.data[i].address.longitude, statusTask: sendStatus, customerAddress: null);
        _listMarker.add(marker);
      }
    }
    var customersWithAddressResponse = await getAllCustomersWithAddress(user.company, user.rememberToken);
    CustomersWithAddressModel customersWithAddress = customersWithAddressResponse.body;
    for(int y = 0; y < customersWithAddress.data.length; y++){
      Place marker;
      String valadde = 'N/A';
      if(customersWithAddress.data[y].address != null){
        valadde = customersWithAddress.data[y].address;
        marker = Place(id: customersWithAddress.data[y].id, customer: customersWithAddress.data[y].name, address: valadde,latitude: customersWithAddress.data[y].latitude,longitude: customersWithAddress.data[y].longitude, statusTask: status.cliente,customerAddress: customersWithAddress.data[y]);
        _listMarker.add(marker);
      }
    }

    setState(() {
      listplace = _listMarker;
      allmark(listplace);
    });

  }

  allmark(List<Place> listPlaces) async {
    
    //Image.network('https://raw.githubusercontent.com/Concept211/Google-Maps-Markers/master/images/marker_red1.png');

    _markers.clear();

    for(Place mark in listPlaces){
      _markers.add(
        Marker(
            markerId: MarkerId(mark.id.toString()),
            position: LatLng(mark.latitude, mark.longitude),
            infoWindow: InfoWindow(
                title: (mark.customer + '             ') ,
                snippet: mark.address,
                onTap: (){
                  if(mark.statusTask == status.cliente){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) => FormTask(directioncliente:mark.customerAddress )));
                  }
                }
            ),
            onTap: (){ },
          icon: await colorMarker(mark,listPlaces.indexOf(mark))
        ),
      );
    }
//    //setState((){
//    _markers;
//    _polyLines;
//    //});
  }
  Future createRoute(Place mark) async {
    LatLng destination = LatLng(mark.latitude, mark.longitude);
    String route = await _googleMapsServices.getRouteCoordinates(_initialPosition, destination,kGoogleApiKeyy);

    _polyLines.add(Polyline(polylineId: PolylineId(_lastPosition.toString()),
        width: 10,
        points: convertToLatLng(decodePoly(route)),
        color: Colors.red[200]));
  }
  Future<BitmapDescriptor> colorMarker(Place mark, int number) async {
    ImageConfiguration imageConfig = ImageConfiguration(size: Size(32, 32));//Alto y Ancho del Icono
    number = number +1;

    switch(mark.statusTask){
      case status.cliente:{
          var data = await getNetworkImageData(
              'https://raw.githubusercontent.com/Concept211/Google-Maps-Markers/master/images/marker_blue' +
                  number.toString() + '.png', useCache: true);
          //var path = await ImagePickerSaver.saveFile(fileData: data);

          BitmapDescriptor bit;
          setState(() {
             bit = BitmapDescriptor.fromBytes(data);
          });

          return bit;// fromAssetImage(imageConfig, path);
          //return await BitmapDescriptor.fromAssetImage(createLocalImageConfiguration(context), "assets/images/cliente.png");
      }
      case status.planificado:{
        //var data = await getNetworkImageData('https://raw.githubusercontent.com/Concept211/Google-Maps-Markers/master/images/marker_red'+number.toString()+'.png', useCache: true);
        //return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
//        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        break;
      }

      case status.culminada:
        {
          //var data = await getNetworkImageData('https://raw.githubusercontent.com/Concept211/Google-Maps-Markers/master/images/marker_greem'+number.toString()+'.png', useCache: true);
          //return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
          return BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen);
//        createRoute(mark);
//      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
        }
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

  FloatingActionButton ButtonListCLient(){
    return FloatingActionButton.extended(
      onPressed: ListarListClientes,
      icon: Icon(Icons.place),
      label: Text("Tareas"),
      backgroundColor: PrimaryColor,
      shape: RoundedRectangleBorder(),
    );
  }

  Future ListarListClientes() async {
    await showDialog(
        context: context,
        // ignore: deprecated_member_use
        child: SimpleDialog(
            title: Text('Tareas no realizadas :'),
            children: <Widget>[
              ListClientes(),
            ]
        )
    );
  }


  // ignore: non_constant_identifier_names
  ListClientes(){

    List<Place> listas_porhacer = new List<Place>();
    for(Place p in listplace){
      if(p.statusTask == status.planificado){
        listas_porhacer.add(p);
      }else{
      }
    }

    if(listas_porhacer.length != 0){
      return new Container(
        width: MediaQuery.of(context).size.width ,
        height: MediaQuery.of(context).size.height *0.7,
        child: Container(
          child: ListView.builder(
            itemCount: listas_porhacer.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(listas_porhacer[index].customer /*+ ' ' + listas_porhacer[index].id.toString()*/),
                subtitle: Text(listas_porhacer[index].address),
                leading: Icon(Icons.location_on,color: Colors.red,),
                onTap: (){
                  var center = LatLng(listas_porhacer[index].latitude, listas_porhacer[index].longitude);
                  mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                      target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      );
    }else{
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text('No existen Tareas no realizadas'),
          Center(
            child: Icon(
              Icons.not_listed_location,
              size: 150,
              color: Colors.grey[300],
            ),
          ),
        ],
      );
    }
  }
}