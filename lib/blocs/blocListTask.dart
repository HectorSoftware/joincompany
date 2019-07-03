import 'dart:async';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/TaskService.dart';


class BlocListTask {

  List<TaskModel> _listTaskModellocal = List<TaskModel>();

  var _tasksController = StreamController<List<TaskModel>>.broadcast();
  Stream<List<TaskModel>> get outListTaks => _tasksController.stream;
  Sink<List<TaskModel>> get inListTaks => _tasksController.sink;


  Future getdatalist(DateTime hastaf,DateTime desdef,int pageTasks) async {
    String diaDesde =   desdef.year.toString()  + '-' + desdef.month.toString()  + '-' + desdef.day.toString() + ' 00:00:00';
    String diaHasta = hastaf.year.toString()  + '-' + hastaf.month.toString()  + '-' + hastaf.day.toString() + ' 23:59:59';

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    TasksModel tasks = new TasksModel();
    var getAllTasksResponse;
    try{
      DateTime dateNew = DateTime.parse('1990-05-05');
      for(int countPage = 1; countPage <= pageTasks;countPage++){
        getAllTasksResponse = await getAllTasks(user.company,user.rememberToken,beginDate: diaDesde,endDate: diaHasta,responsibleId: user.id.toString(), perPage: '20',page: countPage.toString());
        if(getAllTasksResponse.statusCode == 200){
          tasks = getAllTasksResponse.body;
          //if(tasks)
          for(int i = 0; i < tasks.data.length; i++ ){

            DateTime dateTask;
            if(tasks.data[i].planningDate != null){
              dateTask = DateTime.parse(tasks.data[i].planningDate);
            }else{
              dateTask = DateTime.parse(tasks.data[i].createdAt);
            }

            int c = 0;
            for(int countPasar = 0; countPasar < _listTaskModellocal.length; countPasar++){
              if(_listTaskModellocal[countPasar].id == tasks.data[i].id){
                c++;
              }
            }
            if(c < 2){
              if((tasks.data.length == 1)||
                  ((dateNew.day != dateTask.day) ||
                      (dateNew.month != dateTask.month) ||
                      (dateNew.year != dateTask.year))){
                _listTaskModellocal.add(tasks.data[i]);
                dateNew = dateTask;
              }
              _listTaskModellocal.add(tasks.data[i]);
            }
          }
        }
      }
    } catch(e) {}

    inListTaksTotal.add(tasks !=null ? tasks.total : 0);
    inListTaks.add(_listTaskModellocal);
    _tasksController.close();
    _tasksTotalController.close();
  }

  var _tasksTotalController = StreamController<int>.broadcast();
  Stream<int> get outListTaksTotal => _tasksTotalController.stream;
  Sink<int> get inListTaksTotal => _tasksTotalController.sink;


  @override
  void dispose() {

  }

  BlocListTask(DateTime hastaf,DateTime desdef,int pageTasks) {
    getdatalist(hastaf,desdef,pageTasks);
  }
}

//final blocTaskListTask = blocListTask();