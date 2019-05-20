import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/Marker.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/TaskService.dart';

class TaskBloc{
  List<Place> _listMarker = new List<Place>();

  final _taskcontroller = StreamController<List<Place>>();
 // Sink<List<Place>> get _inTask => _taskcontroller.sink;
  Stream<List<Place>> get outTask => _taskcontroller.stream;

  TaskBloc(){
    getPLace();
  }

  Future getPLace() async {

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

    /*UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
    var getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token);
    Tasks tasks = Tasks.fromJson(getAllTasksResponse.body);
    print(tasks.data[0].name);
    print(tasks.data[0].responsibleId);*/


    _listMarker = listMarkerLocal;
    _taskcontroller.add(_listMarker);

  }

  @override
  void dispose() {
    _taskcontroller.close();
  }
}