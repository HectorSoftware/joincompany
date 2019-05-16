import 'dart:async';
import 'package:joincompany/models/Marker.dart';

class TaskBloc{
  List<Place> _listMarker = new List<Place>();

  final _taskcontroller = StreamController<List<Place>>();
 // Sink<List<Place>> get _inTask => _taskcontroller.sink;
  Stream<List<Place>> get outTask => _taskcontroller.stream;

  TaskBloc(){
    getPLace();
  }

  void getPLace(){

    List<Place> listMarkerLocal = new List<Place>();
    Place marker = Place(id: 1, customer: 'cliente 1', address: 'direccion 1',latitude: -33.4544232,longitude: -70.6308331, status: 0);
    listMarkerLocal.add(marker);
    marker = Place(id: 2, customer: 'cliente 2', address: 'direccion 2',latitude: -33.4568714,longitude: -70.6297065, status: 0);
    listMarkerLocal.add(marker);
    marker = Place(id: 3, customer: 'cliente 3', address: 'direccion 3',latitude: -33.4548931,longitude: -70.6323136, status: 1);
    listMarkerLocal.add(marker);
    marker = Place(id: 4, customer: 'cliente 4', address: 'direccion 4',latitude: -33.4544232,longitude: -70.6261232, status: 2);
    listMarkerLocal.add(marker);
    marker = Place(id: 5, customer: 'cliente 5', address: 'direccion 5',latitude: -33.4531271,longitude: -70.5612654, status: 1);
    listMarkerLocal.add(marker);

    _listMarker = listMarkerLocal;
    _taskcontroller.add(_listMarker);

  }

  @override
  void dispose() {
    _taskcontroller.close();
  }
}