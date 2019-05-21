import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/TaskService.dart';


class blocListTask {

  List<TaskModel> _listTask = List<TaskModel>();
  List<TaskModel> _listTask_ordenar = List<TaskModel>();

  var _tasksController = StreamController<List<TaskModel>>();
  Stream<List<TaskModel>> get outListTaks => _tasksController.stream;
  Sink<List<TaskModel>> get inListTaks => _tasksController.sink;

  Future updateListTask()
  async {

    var hasta = new DateTime.now();
    var desde = new DateTime.now().add(Duration(days: -15));
    String diadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 00:00:00';
    String hastadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 23:59:59';

    UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
    var getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate: diadesde,endDate: hastadesde);
    TasksModel tasks = TasksModel.fromJson(getAllTasksResponse.body);

    print(tasks.total);

    bool whilesalir = true;
    while(whilesalir){
      for(int i = 0; i < tasks.data.length; i++ ){
        TaskModel task = new TaskModel(
            id: tasks.data[i].id,
            createdAt:  tasks.data[i].createdAt,
            updatedAt: tasks.data[i].updatedAt,
            deletedAt: tasks.data[i].deletedAt,
            createdById: tasks.data[i].createdById,
            updatedById: tasks.data[i].updatedById,
            deletedById: tasks.data[i].updatedById,
            formId: tasks.data[i].formId,
            responsibleId: tasks.data[i].responsibleId,
            customerId: tasks.data[i].customerId,
            addressId: tasks.data[i].addressId,
            name: tasks.data[i].name,
            planningDate: tasks.data[i].planningDate,
            checkinDate: tasks.data[i].checkinDate,
            checkinLatitude: tasks.data[i].checkinLatitude,
            checkinLongitude: tasks.data[i].checkinLongitude,
            checkoutDistance: tasks.data[i].checkinDistance,
            checkoutDate: tasks.data[i].checkoutDate,
            checkoutLatitude: tasks.data[i].checkoutLatitude,
            checkoutLongitude: tasks.data[i].checkoutLongitude,
            checkinDistance: tasks.data[i].checkoutDistance,
            status: tasks.data[i].status,
            customSections: tasks.data[i].customSections,
            customValues: tasks.data[i].customValues,
            form: tasks.data[i].form,
            address: tasks.data[i].address,
            customer: tasks.data[i].customer,
            responsible: tasks.data[i].responsible);
        _listTask.add(task);
      }
      if(tasks.nextPageUrl != null){
        getAllTasksResponse = await getAllTasks(UserActiv.company, UserActiv.token, urlPage: tasks.nextPageUrl);
        tasks = TasksModel.fromJson(getAllTasksResponse.body);
      }else{ whilesalir = false; }
    }
    inListTaks.add(_listTask);
  }

  @override
  void dispose() {
    _tasksController.close();
  }

  blocListTask() {
    updateListTask();
  }
}