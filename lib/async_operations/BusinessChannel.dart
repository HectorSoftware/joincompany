import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/BusinessService.dart';
import '../main.dart';


class BusinessChannel {
  
  BusinessChannel();
  
  static Future _createBusinessesInBothLocalAndServer(String customer, String authorization) async {
    try{
      // Create Local To Server
      List<BusinessModel> businessesLocal = await DatabaseProvider.db.ReadBusinessesBySyncState(SyncState.created);

      await Future.forEach(businessesLocal, (businessLocal) async {
        var createBusinessResponseServer = await createBusinessFromServer(businessLocal, customer, authorization);
        if ((createBusinessResponseServer.statusCode==200 || createBusinessResponseServer.statusCode==201) && createBusinessResponseServer.body!='Cliente no existe') {
          BusinessModel businessServer = BusinessModel.fromJson(createBusinessResponseServer.body);
          // Cambiar el SyncState Local
          // Actualizar el id local o usar otro campo para guardar el id del recurso en el servidor
          await DatabaseProvider.db.UpdateBusiness(businessLocal.id, businessServer, SyncState.synchronized);
        }
      });

      // Create Server To Local
      var businessesServerResponse = await getAllBusinessesFromServer(customer, authorization, perPage: '10000');
      BusinessesModel businessesServer = BusinessesModel.fromJson(businessesServerResponse.body);

      Set idsBusinessesServer = new Set();
      await Future.forEach(businessesServer.data, (businessServer) async {
        idsBusinessesServer.add(businessServer.id);
      });

      Set idsBusinessesLocal = new Set.from(await DatabaseProvider.db.RetrieveAllBusinessIds()); //método de albert

      Set idsToCreate = idsBusinessesServer.difference(idsBusinessesLocal);

      await Future.forEach(businessesServer.data, (businessServer) async {
        if (idsToCreate.contains(businessServer.id)) {
          // Cambiar el SyncState Local
          await DatabaseProvider.db.CreateBusiness(businessServer, SyncState.synchronized);
        }
      });
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return;
    }

  }

  static Future _deleteBusinessesInBothLocalAndServer(String customer, String authorization) async {
    try{
      //Delete Local To Server
      List<BusinessModel> businessesLocal = await DatabaseProvider.db.ReadBusinessesBySyncState(SyncState.deleted);

      await Future.forEach(businessesLocal, (businessLocal) async {
        var deleteBusinessResponseServer = await deleteBusinessFromServer(businessLocal.id.toString(), customer, authorization);
        if (deleteBusinessResponseServer.statusCode==200) {
          await DatabaseProvider.db.DeleteBusinessById(businessLocal.id);
        }
      });

      // Delete Server To Local
      var businessesServerResponse = await getAllBusinessesFromServer(customer, authorization, perPage: '10000');
      BusinessesModel businessesServer = BusinessesModel.fromJson(businessesServerResponse.body);

      Set idsBusinessesServer = new Set();
      await Future.forEach(businessesServer.data, (businessServer) async {
        idsBusinessesServer.add(businessServer.id);
      });

      Set idsBusinessesLocal = new Set.from(await DatabaseProvider.db.RetrieveAllBusinessIds()); //método de albert

      Set idsToDelete = idsBusinessesLocal.difference(idsBusinessesServer);

      await Future.forEach(idsToDelete, (idToDelete) async{
        await DatabaseProvider.db.DeleteBusinessById(idToDelete);
      });
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return;
    }

  }

  static Future _updateBusinessesInBothLocalAndServer(String customer, String authorization) async {
    try{
      var businessesServerResponse = await getAllBusinessesFromServer(customer, authorization, perPage: '10000');
      BusinessesModel businessesServer = BusinessesModel.fromJson(businessesServerResponse.body);

      await Future.forEach(businessesServer.data, (businessServer) async {

        BusinessModel businessLocal = await DatabaseProvider.db.ReadBusinessById(businessServer.id);
        if (businessLocal != null) {
          DateTime updateDateLocal  = DateTime.parse(businessLocal.updatedAt);
          DateTime updateDateServer = DateTime.parse(businessServer.updatedAt);
          int  diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;

          if (diffInMilliseconds > 0) { // Actualizar Server
            var updateBusinessServerResponse = await updateBusinessFromServer(businessLocal.id.toString(), businessLocal, customer, authorization);
            if (updateBusinessServerResponse.statusCode == 200) {
              BusinessModel businessServerUpdated = BusinessModel.fromJson(updateBusinessServerResponse.body);
              //Cambiar el sycn state
              // Actualizar fecha de actualización local con la respuesta del servidor para evitar un ciclo infinito
              await DatabaseProvider.db.UpdateBusiness(businessServerUpdated.id, businessServerUpdated, SyncState.synchronized);
            }
          } else if ( diffInMilliseconds < 0) { // Actualizar Local
            await DatabaseProvider.db.UpdateBusiness(businessServer.id, businessServer, SyncState.synchronized);
          }
        }
      });
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return;
    }
  } 

  static Future syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;

    await BusinessChannel._createBusinessesInBothLocalAndServer(customer, authorization);
    await BusinessChannel._updateBusinessesInBothLocalAndServer(customer, authorization);
    await BusinessChannel._deleteBusinessesInBothLocalAndServer(customer, authorization);
  }

}
