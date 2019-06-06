import 'dart:async';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/Marker.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:joincompany/services/TaskService.dart';

class TaskBloc{
  List<Place> _listMarker = new List<Place>();

  final _taskcontroller = StreamController<List<Place>>.broadcast();
  Sink<List<Place>> get _inTask => _taskcontroller.sink;
  Stream<List<Place>> get outTask => _taskcontroller.stream;

  TaskBloc(){
    getPLace();
  }

  Future getPLace() async {
    var hasta = new DateTime.now();
    String diadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 00:00:00';
    String hastadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 23:59:59';

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    var getAllTasksResponse = await getAllTasks(user.company, user.rememberToken, beginDate : diadesde ,endDate : hastadesde, );
    TasksModel tasks = TasksModel.fromJson(getAllTasksResponse.body);
    status sendStatus = status.cliente;

    for(int i=0; i < tasks.data.length;i++){
      Place marker;
      String valadde = 'N/A';
      if(tasks.data[i].address != null){
        valadde = tasks.data[i].address.address;
        if(tasks.data[i].status == 'done'){sendStatus = status.culminada;}
        if(tasks.data[i].status == 'working' || tasks.data[i].status == 'pending'){sendStatus = status.planificado;}
        marker = Place(id: tasks.data[i].id, customer: tasks.data[i].name, address: valadde,latitude: tasks.data[i].address.latitude,longitude: tasks.data[i].address.longitude, statusTask: sendStatus,customerAddress: null);
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

    _taskcontroller.add(_listMarker);
  }

  @override
  void dispose() {
    _taskcontroller.close();
  }
}