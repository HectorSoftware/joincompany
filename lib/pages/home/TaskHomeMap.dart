import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/api/rutahttp.dart';
import 'package:joincompany/blocs/blocListTaskCalendar.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/Marker.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/FormTaskNew.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:sentry/sentry.dart';
import 'package:flutter/services.dart';
class TaskHomeMap extends StatefulWidget {
  _MytaskPageMapState createState() => _MytaskPageMapState();

  TaskHomeMap({this.blocListTaskCalendarResMapwidget,this.dateActualRes});

  final BlocListTaskCalendarMap blocListTaskCalendarResMapwidget;
  final DateTime dateActualRes;
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

class _MytaskPageMapState extends State<TaskHomeMap> {
  SentryClient sentry;

  GoogleMapController mapController;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  static const kGoogleApiKeyy = kGoogleApiKey;
  BlocListTaskCalendarMap blocListTaskCalendarResMap;
  DateTime dateActual;
  List<DateTime> listCalendar = new List<DateTime>();

  @override
  void initState() {
    dateActual = widget.dateActualRes;
    _getUserLocation();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose(){
    _polyLines;
    _markers;
    blocListTaskCalendarResMap.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    double por = 0.7;
    if (mediaQueryData.orientation == Orientation.portrait) {
      por = 0.807;
    }

    blocListTaskCalendarResMap = widget.blocListTaskCalendarResMapwidget;
    try{
      if (this.mounted){
        setState((){
          // ignore: cancel_subscriptions
          StreamSubscription streamSubscriptionCalendar = blocListTaskCalendarResMap.outTaksCalendarMap.listen((onData)
          => setState((){
            listplace.clear();
            _addMarker(onData);
          }));
        });
      }
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
              child: buttonListClient(),
            ),
          ],
        )
      );
  }

  void _onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
  }

  static CameraPosition _kGooglePlex = CameraPosition(target: _initialPosition, zoom: 12);

  void onMapCreated(controller) {
    mapController = controller;
    _addMarker(dateActual);
  }

  Future _getUserLocation() async{
    try{
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    }catch(error, stackTrace) {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }

  List<Place> listplace = new List<Place>();

  Future _addMarker(DateTime hasta) async {
    try{
      List<Place> _listMarker = new List<Place>();

      String diadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 00:00:00';
      String hastadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 23:59:59';

      UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
      var getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate : diadesde ,endDate : hastadesde, responsibleId: UserActiv.idUserCompany.toString());
      TasksModel tasks = TasksModel.fromJson(getAllTasksResponse.body);
      status sendStatus = status.cliente;
      for(int i=0; i < tasks.data.length;i++){
        Place marker;
        String valadde = 'N/A';
        DateTime dateTask;
        if(tasks.data[i].planningDate != null){
          dateTask = DateTime.parse(tasks.data[i].planningDate);
        }else{
          dateTask = DateTime.parse(tasks.data[i].createdAt);
        }

        if(tasks.data[i].address != null && ((dateTask.day == hasta.day)&&(dateTask.month == hasta.month)&&(dateTask.year == hasta.year)
        )){
          valadde = tasks.data[i].address.address;
          if(tasks.data[i].status == 'done'){sendStatus = status.culminada;}
          if(tasks.data[i].status == 'working' || tasks.data[i].status == 'pending'){sendStatus = status.planificado;}
          marker = Place(id: tasks.data[i].id, customer: tasks.data[i].name, address: valadde,latitude: tasks.data[i].address.latitude,longitude: tasks.data[i].address.longitude, statusTask: sendStatus, customerAddress: null);
          _listMarker.add(marker);
        }
      }
      var customersWithAddressResponse = await getAllCustomersWithAddress(UserActiv.company,UserActiv.token);
      CustomersWithAddressModel customersWithAddress = CustomersWithAddressModel.fromJson(customersWithAddressResponse.body);
      for(int y = 0; y < customersWithAddress.data.length; y++){
        Place marker;
        String valadde = 'N/A';
        if(customersWithAddress.data[y].address != null){
          valadde = customersWithAddress.data[y].address;
          bool noExiste = true;
          for(Place value in _listMarker) {
            if((value.latitude == customersWithAddress.data[y].latitude) &&
                (value.longitude == customersWithAddress.data[y].longitude)){
              noExiste = false;
            }
          }
          if(_listMarker.length == 0 || noExiste) {
            marker = Place(id: customersWithAddress.data[y].id, customer: customersWithAddress.data[y].name, address: valadde,latitude: customersWithAddress.data[y].latitude,longitude: customersWithAddress.data[y].longitude, statusTask: status.cliente,customerAddress: customersWithAddress.data[y]);
            _listMarker.add(marker);
          }

        }
      }

      if (this.mounted){

          listplace = _listMarker;
          await allmark(listplace);
          await allsrutes(listplace);

      }
    }catch(error, stackTrace) {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future allsrutes(List<Place> listPlaces) async {
    List<Place> newPl = new List<Place>();

    Place oldPlace;
    _polyLines.clear();
    bool init = false;

    for(Place mark in listPlaces){
      if(mark.statusTask == status.planificado || mark.statusTask == status.culminada){
        newPl.add(mark);
      }
    }
    for(int x = newPl.length; x > 0; x--){
      if(!init){
        init = !init;
        oldPlace = newPl[x-1];
      }else{
        LatLng destination = LatLng(oldPlace.latitude, oldPlace.longitude);
        await createRoute(newPl[x-1],destination);
        oldPlace = newPl[x-1];
      }
    }
  }

  allmark(List<Place> listPlaces) async {
    try{
      _markers.clear();
      int cantPl = 0;
      for(Place mark in listPlaces){
        if(mark.statusTask != status.cliente){
          cantPl++;
        }
      }

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
                              builder: (context) => FormTask(directionClient:mark.customerAddress,taskmodelres: null,toListTask: false,)));
                    }
                  }
              ),
              onTap: (){ },
              icon: await colorMarker(mark,cantPl)
          ),
        );

        if(mark.statusTask != status.cliente){
          cantPl--;
        }
      }
    setState(() => _markers);
    }catch(error, stackTrace) {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future createRoute(Place mark,LatLng oldPosition) async {
    try{
      LatLng destination = LatLng(mark.latitude, mark.longitude);
      String route = await _googleMapsServices.getRouteCoordinates(oldPosition, destination,kGoogleApiKeyy);

      _polyLines.add(
          Polyline(polylineId: PolylineId(destination.toString()),
              width: 10,
              points: convertToLatLng(decodePoly(route)),
              color: Colors.red[200]
          )
      );
      setState(() {});
    }catch(error, stackTrace) {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<BitmapDescriptor> colorMarker(Place mark, int number) async {
    switch(mark.statusTask){
      case status.cliente:{
          return await BitmapDescriptor.fromAssetImage(createLocalImageConfiguration(context), "assets/images/cliente.png");
      }
      case status.planificado:{
            return await BitmapDescriptor.fromAssetImage(createLocalImageConfiguration(context), "assets/images/pinmap/pinmapRojo$number.png");
      }
      case status.culminada:{
        return await BitmapDescriptor.fromAssetImage(createLocalImageConfiguration(context), "assets/images/pinmap/pinmapVerde$number.png");
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

  FloatingActionButton buttonListClient(){
    return FloatingActionButton.extended(
      onPressed: listViewListClients,
      icon: Icon(Icons.place),
      label: Text("Tareas"),
      backgroundColor: PrimaryColor,
      shape: RoundedRectangleBorder(),
    );
  }

  Future listViewListClients() async {
    await showDialog(
        context: context,
        // ignore: deprecated_member_use
        child: SimpleDialog(
            title: Text('Tareas planificadas :'),
            children: <Widget>[
              ListClientes(),
            ]
        )
    );
  }

  // ignore: non_constant_identifier_names
  ListClientes(){
    List<Place> listToDo = new List<Place>();
    for(int x = (listplace.length -1); x >= 0; x--){
      if(listplace[x].statusTask == status.planificado){
        listToDo.add(listplace[x]);
      }
    }

    if(listToDo.length != 0){
      return new Container(
        width: MediaQuery.of(context).size.width ,
        height: MediaQuery.of(context).size.height *0.7,
        child: Container(
          child: ListView.builder(
            itemCount: listToDo.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(listToDo[index].customer,style: TextStyle(fontSize: 18),),
                subtitle: Text(listToDo[index].address,style: TextStyle(fontSize: 12),),
//                leading: Icon(Icons.location_on,color: Colors.red,),
                leading: Image.asset('assets/images/pinmap/pinmapRojo${index+1}.png',width: 30,),
                onTap: (){
                  var center = LatLng(listToDo[index].latitude, listToDo[index].longitude);
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
          Text('No existen tareas planificadas'),
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