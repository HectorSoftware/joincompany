import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:http/http.dart' as http;

class TaskChannel {
  static void _createTasksInBothLocalAndServer(String customer, String authorization, String userId) async {
    List<TaskModel> tasksFromLocal = await DatabaseProvider.db.ReadTasksBySyncState(SyncState.created);

    await Future.forEach(tasksFromLocal, (taskFromLocal) async {
      taskFromLocal.customSections = null;
      Map<String,String> map = Map<String,String>();
      taskFromLocal.customValues.forEach ((c){
        map[c.fieldId.toString()] = (c.imageBase64 == null || c.imageBase64 == "") ? c.value.toString() : c.imageBase64;
      });
      taskFromLocal.customValuesMap = map;
      taskFromLocal.customValues = null;
      // taskFromLocal.id = null; 
      // taskFromLocal.createdAt = null;
      // taskFromLocal.updatedAt = null;
      // taskFromLocal.deletedAt = null;
      // taskFromLocal.createdById = null;
      // taskFromLocal.updatedById = null;
      // taskFromLocal.deletedById = null;
      
      taskFromLocal.form = null;
      taskFromLocal.address = null;
      taskFromLocal.customer = null;
      taskFromLocal.responsible = null;

      taskFromLocal.status = null;
      var createTaskInServerRes = await createTaskFromServer(taskFromLocal, customer, authorization);
      if (createTaskInServerRes.statusCode == 200) {
        TaskModel createdTask = TaskModel.fromJson(treatBodyRes(createTaskInServerRes.body));
        await DatabaseProvider.db.UpdateTask(taskFromLocal.id, createdTask, SyncState.synchronized);
      }
    });

    http.Response requestedTasksFromServer = await getAllTasksFromServer(customer, authorization, responsibleId: userId, perPage: 100000.toString());
    TasksModel tasksFromServer = TasksModel.fromJson(requestedTasksFromServer.body);
    
    Set<int> idsOfTasksFromServer = new Set<int>();
    tasksFromServer.data.forEach((taskFromServer) {
      idsOfTasksFromServer.add(taskFromServer.id);
    });

    Set<int> idsOfTasksFromLocal = new Set<int>.from(await DatabaseProvider.db.RetrieveAllTaskIds());
    Set<int> idsOfTasksToCreate = idsOfTasksFromServer.difference(idsOfTasksFromLocal);

    await Future.forEach(tasksFromServer.data, (taskToCreate) async {
      if (idsOfTasksToCreate.contains(taskToCreate.id)) {
        http.Response individualTaskFromServerRes = await getTaskFromServer(taskToCreate.id.toString(), customer, authorization);

        if (individualTaskFromServerRes == null)
          return;

        TaskModel individualTask = TaskModel.fromJson(individualTaskFromServerRes.body);
        if (individualTask != null)
          await DatabaseProvider.db.CreateTask(individualTask, SyncState.synchronized);
      }
    });
  }

  static void _updateTaskInBothLocalAndServer(String customer, String authorization) async {
    http.Response tasksFromServerRes = await getAllTasksFromServer(customer, authorization, perPage: '10000');
    TasksModel tasksFromServer = TasksModel.fromJson(tasksFromServerRes.body);
    
    if (tasksFromServer.data != null) {
      await Future.forEach(tasksFromServer.data, (taskFromServerData) async {
        dynamic taskFromServerRes = await getTaskFromServer(taskFromServerData.id.toString(), customer, authorization);
        TaskModel taskFromServer = TaskModel.fromJson(taskFromServerRes.body);
        TaskModel taskFromLocal = await DatabaseProvider.db.ReadTaskById(taskFromServer.id);

        if (taskFromLocal != null) {
          DateTime updateDateFromLocal  = DateTime.parse(taskFromLocal.updatedAt); 
          DateTime updateDateFromServer = DateTime.parse(taskFromServer.updatedAt);
          int  diffInMilliseconds = updateDateFromLocal.difference(updateDateFromServer).inMilliseconds;
        
          if (diffInMilliseconds > 0) {
            var updateTaskInServerRes = await updateTaskFromServer(taskFromLocal.id.toString(), taskFromLocal, customer, authorization);
            if (updateTaskInServerRes.statusCode == 200) {
              TaskModel updatedTaskFromServer = TaskModel.fromJson(treatBodyRes(updateTaskInServerRes.body));
              await DatabaseProvider.db.UpdateTask(updatedTaskFromServer.id, updatedTaskFromServer, SyncState.synchronized);
            }
          } else if ( diffInMilliseconds < 0) {
            await DatabaseProvider.db.UpdateTask(taskFromServer.id, taskFromServer, SyncState.synchronized);
          }
        }
      });
    }
  }

  static void _deleteTaskInBothLocalAndServer(String customer, String authorization) async {
    http.Response tasksFromServerRes = await getAllTasksFromServer(customer, authorization, perPage: '10000');
    TasksModel tasksFromServer = TasksModel.fromJson(tasksFromServerRes.body);

    List<int> taskIdsFromServer = tasksFromServer.listTasksIds();
    List<int> taskIdsFromLocal = await DatabaseProvider.db.RetrieveAllTaskIds();

    Set<int> setOfTaskIdsFromServer = Set<int>.from(taskIdsFromServer);
    Set<int> setOfTaskIdsFromLocal = Set<int>.from(taskIdsFromLocal);
    Set<int> setOfTaskIdsToDeleteWith = setOfTaskIdsFromLocal.difference(setOfTaskIdsFromServer);

    await Future.forEach(setOfTaskIdsToDeleteWith, (id) async {
      await DatabaseProvider.db.DeleteTaskById(id);
    });

    List<TaskModel> tasksToDelete = await DatabaseProvider.db.ReadTasksBySyncState(SyncState.deleted);
    
    if (tasksToDelete != null) {
      await Future.forEach(tasksToDelete, (taskToDelete) async {
        http.Response deleteTaskRes = await deleteTaskFromServer(taskToDelete.id.toString(), customer, authorization);
        if (deleteTaskRes.statusCode == 200 || deleteTaskRes.statusCode != 201) {
          await DatabaseProvider.db.DeleteTaskById(taskToDelete.id);
        }
      });
    }
  }

  static Future syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;
    String id = user.id.toString();

    await TaskChannel._createTasksInBothLocalAndServer(customer, authorization, id);
    await TaskChannel._deleteTaskInBothLocalAndServer(customer, authorization);
    await TaskChannel._updateTaskInBothLocalAndServer(customer, authorization);
  }
}
