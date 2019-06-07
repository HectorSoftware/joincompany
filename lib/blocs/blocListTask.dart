import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/TaskService.dart';


class blocListTask {

  List<TaskModel> _listTaskModellocal = List<TaskModel>();

  var _tasksController = StreamController<List<TaskModel>>.broadcast();
  Stream<List<TaskModel>> get outListTaks => _tasksController.stream;
  Sink<List<TaskModel>> get inListTaks => _tasksController.sink;


  Future getdatalist(DateTime hastaf,DateTime desdef,int pageTasks) async {
    String diaDesde =   desdef.year.toString()  + '-' + desdef.month.toString()  + '-' + desdef.day.toString() + ' 00:00:00';
    String diaHasta = hastaf.year.toString()  + '-' + hastaf.month.toString()  + '-' + hastaf.day.toString() + ' 23:59:59';

    UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');

    TasksModel tasks = new TasksModel();
    var getAllTasksResponse;
    List<TaskModel> _listTask = new List<TaskModel>();
    try{
      DateTime FechaNueva = DateTime.parse('1990-05-05');
      for(int contar_pag = 1; contar_pag <= pageTasks;contar_pag++){
        getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate: diaDesde,endDate: diaHasta,responsibleId: UserActiv.idUserCompany.toString(), perPage: '5',page: contar_pag.toString());
        if(getAllTasksResponse.statusCode == 200){
          tasks = TasksModel.fromJson(getAllTasksResponse.body);

          //if(tasks)
          for(int i = 0; i < tasks.data.length; i++ ){
            DateTime Fechatask = DateTime.parse(tasks.data[i].createdAt);
            int c = 0;
            for(int countPasar = 0; countPasar < _listTaskModellocal.length; countPasar++){
              if(_listTaskModellocal[countPasar].id == tasks.data[i].id){
                c++;
              }
            }
            if(c < 2){
              if((tasks.data.length == 1)||
                  ((FechaNueva.day != Fechatask.day) ||
                      (FechaNueva.month != Fechatask.month) ||
                      (FechaNueva.year != Fechatask.year))){
                _listTaskModellocal.add(tasks.data[i]);
                FechaNueva = Fechatask;
              }
              _listTaskModellocal.add(tasks.data[i]);
            }
          }
        }
      }
    }catch(e){}

    inListTaksTotal.add(tasks.total);
    inListTaks.add(_listTaskModellocal);
  }

  var _tasksTotalController = StreamController<int>.broadcast();
  Stream<int> get outListTaksTotal => _tasksTotalController.stream;
  Sink<int> get inListTaksTotal => _tasksTotalController.sink;


  @override
  void dispose() {
    _tasksController.close();
    _tasksTotalController.close();
  }

  blocListTask(DateTime hastaf,DateTime desdef,int pageTasks) {
    getdatalist(hastaf,desdef,pageTasks);
  }
}

//final blocTaskListTask = blocListTask();