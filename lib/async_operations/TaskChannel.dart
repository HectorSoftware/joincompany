// TODO: Crear tambien hijos y actualizarlos de ser necesario
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
      var createTaskInServerRes = await createTask(taskFromLocal, customer, authorization);
      if (createTaskInServerRes.statusCode == 200) {
        TaskModel createdTask = TaskModel.fromJson(createTaskInServerRes.body);
        await DatabaseProvider.db.UpdateTask(taskFromLocal.id, createdTask, SyncState.synchronized);
      }
    });

    http.Response requestedTasksFromServer = await getAllTasksFromServer(customer, authorization, responsibleId: userId);
    TasksModel tasksFromServer = TasksModel.fromJson(requestedTasksFromServer.body);
  
    Set<int> idsOfTasksFromServer = new Set<int>();
    tasksFromServer.data.forEach((taskFromServer) {
      idsOfTasksFromServer.add(taskFromServer.id);}
    );

    Set<int> idsOfTasksFromLocal = new Set<int>.from(await DatabaseProvider.db.RetrieveAllTaskIds());
    Set<int> idsOfTasksToCreate = idsOfTasksFromServer.difference(idsOfTasksFromLocal);

    await Future.forEach(tasksFromServer.data, (taskToCreate) async {
      if (idsOfTasksToCreate.contains(taskToCreate.id)) {
        await DatabaseProvider.db.CreateTask(taskToCreate, SyncState.synchronized);
      }
    });
  }

  static void _deleteTaskInBothLocalAndServer(String customer, String authorization) async {
    print("lol");
    http.Response tasksFromServerRes = await getAllTasksFromServer(customer, authorization);
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

    // await TaskChannel._createTasksInBothLocalAndServer(customer, authorization, id);
    await TaskChannel._deleteTaskInBothLocalAndServer(customer, authorization);
  }
}
