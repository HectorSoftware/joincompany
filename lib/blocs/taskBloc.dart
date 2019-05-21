import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/Marker.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:joincompany/services/TaskService.dart';

class TaskBloc{
  List<Place> _listMarker = new List<Place>();

  final _taskcontroller = StreamController<List<Place>>();
  Sink<List<Place>> get _inTask => _taskcontroller.sink;
  Stream<List<Place>> get outTask => _taskcontroller.stream;

  TaskBloc(){
    getPLace();
  }

  Future getPLace() async {
    var hasta = new DateTime.now();
    String diadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 00:00:00';
    String hastadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 23:59:59';

    UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');

    var getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate : diadesde ,endDate : hastadesde, );
    TasksModel tasks = TasksModel.fromJson(getAllTasksResponse.body);
    int sendStatus = 0;

    for(int i=0; i < tasks.data.length;i++){
      Place marker;
      String valadde = 'N/A';
      if(tasks.data[i].address != null){
        valadde = tasks.data[i].address.address;
        if(tasks.data[i].status == 'done'){sendStatus = 2;}
        if(tasks.data[i].status == 'working' || tasks.data[i].status == 'pending'){sendStatus = 1;}
        marker = Place(id: i+1, customer: tasks.data[i].name, address: valadde,latitude: tasks.data[i].address.latitude,longitude: tasks.data[i].address.longitude, status: sendStatus);
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
        marker = Place(id: customersWithAddress.data[y].id, customer: customersWithAddress.data[y].name, address: valadde,latitude: customersWithAddress.data[y].latitude,longitude: customersWithAddress.data[y].longitude, status: 0);
        _listMarker.add(marker);
      }
    }

    _taskcontroller.add(_listMarker);
  }

  @override
  void dispose() {
    _taskcontroller.close();
  }
}