import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/TaskService.dart';


class blocListTask {

  List<TaskModel> _listTask = List<TaskModel>();

  var _tasksController = StreamController<List<TaskModel>>.broadcast();
  Stream<List<TaskModel>> get outListTaks => _tasksController.stream;
  Sink<List<TaskModel>> get inListTaks => _tasksController.sink;

  Future updateListTask(List<DateTime> fechaCalendario) async {
    _listTask = List<TaskModel>();
    inListTaks.add(_listTask);

    var hasta = new DateTime.now();
    var desde = new DateTime.now().add(Duration(days: -15));
    String diadesde = '';
    String hastadesde = '';
    if(fechaCalendario.length == 0){
      diadesde = desde.year.toString() + '-' + desde.month.toString() + '-' + desde.day.toString() + ' 00:00:00';
      hastadesde = hasta.year.toString() + '-' + hasta.month.toString() + '-' + hasta.day.toString() + ' 23:59:59';
    }else{
      if(fechaCalendario.length == 1){
        diadesde = DateTime.parse(fechaCalendario[0].toString()).year.toString() + '-' + DateTime.parse(fechaCalendario[0].toString()).month.toString() + '-' + DateTime.parse(fechaCalendario[0].toString()).day.toString() + ' 00:00:00';
        hastadesde = DateTime.parse(fechaCalendario[0].toString()).year.toString() + '-' + DateTime.parse(fechaCalendario[0].toString()).month.toString() + '-' + DateTime.parse(fechaCalendario[0].toString()).day.toString() + ' 23:59:59';
      }else{
        diadesde = DateTime.parse(fechaCalendario[0].toString()).year.toString() + '-' + DateTime.parse(fechaCalendario[0].toString()).month.toString() + '-' + DateTime.parse(fechaCalendario[0].toString()).day.toString() + ' 00:00:00';
        hastadesde = DateTime.parse(fechaCalendario[1].toString()).year.toString() + '-' + DateTime.parse(fechaCalendario[1].toString()).month.toString() + '-' + DateTime.parse(fechaCalendario[1].toString()).day.toString() + ' 23:59:59';
      }
    }

    UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
    //var getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate: diadesde,endDate: hastadesde,responsibleId: UserActiv.idUserCompany.toString());
    var getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,endDate: hastadesde,responsibleId: UserActiv.idUserCompany.toString());
    TasksModel tasks = TasksModel.fromJson(getAllTasksResponse.body);

    while(true){
      for(int i = 0; i < tasks.data.length; i++ ){
        TaskModel task;
        task = new TaskModel(
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
        getAllTasksResponse = await getAllTasks(UserActiv.company, UserActiv.token,beginDate: diadesde, endDate: hastadesde, urlPage: tasks.nextPageUrl,responsibleId: UserActiv.idUserCompany.toString());
        tasks = TasksModel.fromJson(getAllTasksResponse.body);
      } else break;
    }
    inListTaks.add(_listTask);
  }

  @override
  void dispose() {
    _tasksController.close();
  }

  blocListTask(List<DateTime> fechaCalendario) {
    updateListTask(fechaCalendario);
  }
}

//final blocTaskListTask = blocListTask();