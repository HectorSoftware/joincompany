import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/TaskService.dart';

const Map<String, int> HttpCode = {
  "Okay": 200,
};

class TaskChannel {
  static void createTasksInBothLocalAndServer() async {
    UserModel lastLoggedUser = await DatabaseProvider.db.RetrieveLastLoggedUser();

    List<TaskModel> tasksFromLocal = await DatabaseProvider.db.ReadTasksBySyncState(SyncState.created);
    tasksFromLocal.forEach((task) async {
      var createTaskInServerRes = await createTask(task, null /*lastLoggedUser.company*/, lastLoggedUser.rememberToken);
      if (createTaskInServerRes.statusCode == HttpCode["Okay"]) {
        TaskModel createdTask = TaskModel.fromJson(createTaskInServerRes.body);
        DatabaseProvider.db.UpdateTask(task.id, createdTask, SyncState.synchronized);
      }
    });

    var requestedTasksFromServer = await getAllTasks(null /*lastLoggedUser.company*/, lastLoggedUser.rememberToken, responsibleId: lastLoggedUser.id.toString());
    TasksModel tasksFromServer = TasksModel.fromJson(requestedTasksFromServer.body);

    Set idsOfTasksFromServer = new Set();
    tasksFromServer.data.forEach((taskFromServer) async =>
      idsOfTasksFromServer.add(taskFromServer.id));

    Set idsOfTasksFromLocal = new Set.from(await DatabaseProvider.db.RetrieveAllTaskIds());
    Set idsOfTasksToCreate = idsOfTasksFromServer.difference(idsOfTasksFromLocal);

    tasksFromServer.data.forEach((taskToCreate) async {
      if (idsOfTasksToCreate.contains(taskToCreate.id)) {
        DatabaseProvider.db.CreateTask(taskToCreate, SyncState.synchronized);
      }
    });
  }

  static void deleteFormsInBothLocalAndServer() async {
    UserModel lastLoggedUser = await DatabaseProvider.db.RetrieveLastLoggedUser();

    List<TaskModel> tasksFromLocal = await DatabaseProvider.db.ReadTasksBySyncState(SyncState.deleted);
    tasksFromLocal.forEach((task) async {
      var deleteTaskInServerRes = await deleteTask(task.id.toString(), null /*lastLoggedUser.company*/, lastLoggedUser.rememberToken);
      if (deleteTaskInServerRes.statusCode == HttpCode["Okay"])
        DatabaseProvider.db.DeleteTaskById(task.id);
    });

    var requestedTasksFromServer = await getAllTasks(null /*lastLoggedUser.company*/, lastLoggedUser.rememberToken, responsibleId: lastLoggedUser.id.toString());
    TasksModel tasksFromServer = TasksModel.fromJson(requestedTasksFromServer.body);

    Set idsOfTasksFromServer = new Set();
    tasksFromServer.data.forEach((taskFromServer) async =>
        idsOfTasksFromServer.add(taskFromServer.id));

    Set idsOfTasksFromLocal = new Set.from(await DatabaseProvider.db.RetrieveAllTaskIds());
    Set idsOfTasksToDelete = idsOfTasksFromLocal.difference(idsOfTasksFromServer);

    idsOfTasksToDelete.forEach((taskToDelete) {
      DatabaseProvider.db.DeleteTaskById(taskToDelete);
    });
  }

  static void updateFormsInBothLocalAndServer() async {
    UserModel lastLoggedUser = await DatabaseProvider.db.RetrieveLastLoggedUser();

    var requestedTasksFromServer = await getAllTasks(null /*lastLoggedUser.company*/, lastLoggedUser.rememberToken, responsibleId: lastLoggedUser.id.toString());
    TasksModel tasksFromServer = TasksModel.fromJson(requestedTasksFromServer.body);

    tasksFromServer.data.forEach((taskFromServer) async {
      TaskModel taskFromLocal = await DatabaseProvider.db.ReadTaskById(taskFromServer.id);
      DateTime updateDateLocal  = DateTime.parse(taskFromLocal.updatedAt);
      DateTime updateDateServer = DateTime.parse(taskFromServer.updatedAt);
      int diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;

      if ( diffInMilliseconds < 0 ) {
        DatabaseProvider.db.UpdateTask(taskFromServer.id, taskFromServer, SyncState.synchronized);
      }
    });
  }


}