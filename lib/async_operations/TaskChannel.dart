import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/TaskService.dart';

class TaskChannel {
  static void createTasksInBothLocalAndServer() async {
    UserModel lastLoggedUser = await DatabaseProvider.db.RetrieveLastLoggedUser();

    List<TaskModel> tasksFromLocal = await DatabaseProvider.db.ReadTasksBySyncState(SyncState.created);
    
    await Future.forEach(tasksFromLocal, (taskFromLocal) async {
      var createTaskInServerRes = await createTask(taskFromLocal, lastLoggedUser.company, lastLoggedUser.rememberToken);
      if (createTaskInServerRes.statusCode == 200) {
        TaskModel createdTask = TaskModel.fromJson(createTaskInServerRes.body);
        await DatabaseProvider.db.UpdateTask(taskFromLocal.id, createdTask, SyncState.synchronized);
      }
    });

    var requestedTasksFromServer = await getAllTasks(lastLoggedUser.company, lastLoggedUser.rememberToken, responsibleId: lastLoggedUser.id.toString());
    TasksModel tasksFromServer = TasksModel.fromJson(requestedTasksFromServer.body);

    Set<int> idsOfTasksFromServer = new Set<int>();
    tasksFromServer.data.forEach((taskFromServer) {idsOfTasksFromServer.add(taskFromServer.id))});
    Set<int> idsOfTasksFromLocal = new Set<int>.from(await DatabaseProvider.db.RetrieveAllTaskIds());
    Set<int> idsOfTasksToCreate = idsOfTasksFromServer.difference(idsOfTasksFromLocal);

    await Future.forEach(tasksFromServer.data, (taskToCreate) async {
      if (idsOfTasksToCreate.contains(taskToCreate.id)) {
        await DatabaseProvider.db.CreateTask(taskToCreate, SyncState.synchronized);
      }
    });
  }

  static void deleteTaskInBothLocalAndServer() async {
    UserModel lastLoggedUser = await DatabaseProvider.db.RetrieveLastLoggedUser();

    List<TaskModel> tasksFromLocal = await DatabaseProvider.db.ReadTasksBySyncState(SyncState.deleted);
    await Future.forEach(tasksFromLocal, (task) async {
      var deleteTaskInServerRes = await deleteTask(task.id.toString(), lastLoggedUser.company, lastLoggedUser.rememberToken);
      if (deleteTaskInServerRes.statusCode == 200)
        await DatabaseProvider.db.DeleteTaskById(task.id);
    });

    var requestedTasksFromServer = await getAllTasks(null /*lastLoggedUser.company*/, lastLoggedUser.rememberToken, responsibleId: lastLoggedUser.id.toString());
    TasksModel tasksFromServer = TasksModel.fromJson(requestedTasksFromServer.body);

    Set<int> idsOfTasksFromServer = new Set<int>();
    tasksFromServer.data.forEach((taskFromServer) {idsOfTasksFromServer.add(taskFromServer.id))});
    Set<int> idsOfTasksFromLocal = new Set<int>.from(await DatabaseProvider.db.RetrieveAllTaskIds());
    Set<int> idsOfTasksToDelete = idsOfTasksFromLocal.difference(idsOfTasksFromServer);

    await Future.forEach(idsOfTasksToDelete, (taskToDelete) async {
      await DatabaseProvider.db.DeleteTaskById(taskToDelete);
    });
  }

  static void updateTaskInBothLocalAndServer() async {
    UserModel lastLoggedUser = await DatabaseProvider.db.RetrieveLastLoggedUser();

    dynamic requestedTasksFromServer = await getAllTasks(lastLoggedUser.company, lastLoggedUser.rememberToken, responsibleId: lastLoggedUser.id.toString());
    TasksModel tasksFromServer = TasksModel.fromJson(requestedTasksFromServer.body);

    await Future.forEach(tasksFromServer.data, (taskFromServer) async {
      TaskModel taskFromLocal = await DatabaseProvider.db.ReadTaskById(taskFromServer.id);
      // Looking for differences between local's and server's task
      DateTime updateDateLocal  = DateTime.parse(taskFromLocal.updatedAt);
      DateTime updateDateServer = DateTime.parse(taskFromServer.updatedAt);
      int diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;

      if (diffInMilliseconds > 0) {
        var jsonUpdateTaskInServer = await updateTask(task.id.toString(), task, lastLoggedUser.company, lastLoggedUser.rememberToken);
        if (jsonUpdateTaskInServer.statusCode == 200) {
          TaskModel updatedTaskFromServer = TaskModel.fromJson(updateTaskInServerRes.body);
          await DatabaseProvider.db.UpdateTask(task.id, updatedTaskFromServer, SyncState.synchronized);
        }
      } else if ( diffInMilliseconds < 0 ) {
        await DatabaseProvider.db.UpdateTask(taskFromServer.id, taskFromServer, SyncState.synchronized);
      }
    });
  }
}
