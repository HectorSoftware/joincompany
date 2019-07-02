import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/AddressesModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/AddressService.dart';


class AddressChannel {
  
  AddressChannel();
  
  static Future _createAddressesInBothLocalAndServer(String customer, String authorization) async {

    // Create Local To Server    
    List<AddressModel> addressesLocal = await DatabaseProvider.db.ReadAddressesBySyncState(SyncState.created);

    await Future.forEach(addressesLocal, (addressLocal) async {
      var createAddressResponseServer = await createAddressFromServer(addressLocal, customer, authorization);
      if (createAddressResponseServer.statusCode==200) {
        AddressModel addressServer = AddressModel.fromJson(createAddressResponseServer.body);
        // Cambiar el SyncState Local
        // Actualizar el id local o usar otro campo para guardar el id del recurso en el servidor
        await DatabaseProvider.db.UpdateAddress(addressLocal.id, addressServer, SyncState.synchronized);
      }
    });

    // Create Server To Local
    var addressesServerResponse = await getAllAddressesFromServer(customer, authorization);
    AddressesModel addressesServer = AddressesModel.fromJson(addressesServerResponse.body);

    Set idsAddressesServer = new Set();
    await Future.forEach(addressesServer.data, (addressServer) async {
      idsAddressesServer.add(addressServer.id);
    });

    Set idsAddressesLocal = new Set.from(await DatabaseProvider.db.RetrieveAllAddressIds()); //método de albert

    Set idsToCreate = idsAddressesServer.difference(idsAddressesLocal);



    await Future.forEach(addressesServer.data, (addressServer) async {
      if (idsToCreate.contains(addressServer.id)) {
        // Cambiar el SyncState Local
        await DatabaseProvider.db.CreateAddress(addressServer, SyncState.synchronized);

      }
    });
  }

  static Future _deleteAddressesInBothLocalAndServer(String customer, String authorization) async {

    //Delete Local To Server
    List<AddressModel> addressesLocal = await DatabaseProvider.db.ReadAddressesBySyncState(SyncState.deleted);

    await Future.forEach(addressesLocal, (addressLocal) async {
      var deleteAddressResponseServer = await deleteAddressFromServer(addressLocal.id.toString(), customer, authorization);
      if (deleteAddressResponseServer.statusCode==200) {
        await DatabaseProvider.db.DeleteAddressById(addressLocal.id);
      }
    });

    // Delete Server To Local
    var addressesServerResponse = await getAllAddressesFromServer(customer, authorization);
    AddressesModel addressesServer = AddressesModel.fromJson(addressesServerResponse.body);

    Set idsAddressesServer = new Set();
    await Future.forEach(addressesServer.data, (addressServer) async {
      idsAddressesServer.add(addressServer.id);
    });

    Set idsAddressesLocal = new Set.from(await DatabaseProvider.db.RetrieveAllAddressIds()); //método de albert

    Set idsToDelete = idsAddressesLocal.difference(idsAddressesServer);

    await Future.forEach(idsToDelete, (idToDelete) async {
      await DatabaseProvider.db.DeleteAddressById(idToDelete);
    });
  }

  static Future _updateAddressesInBothLocalAndServer(String customer, String authorization) async {
    
    var addressesServerResponse = await getAllAddressesFromServer(customer, authorization);
    AddressesModel addressesServer = AddressesModel.fromJson(addressesServerResponse.body);

    await Future.forEach(addressesServer.data, (addressServer) async {

      AddressModel addressLocal = await DatabaseProvider.db.ReadAddressById(addressServer.id);
      if (addressLocal != null) {

        DateTime updateDateLocal  = DateTime.parse(addressLocal.updatedAt); 
        DateTime updateDateServer = DateTime.parse(addressServer.updatedAt);
        int  diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;
        
        if (diffInMilliseconds > 0) { // Actualizar Server
          var updateAddressServerResponse = await updateAddressFromServer(addressLocal.id.toString(), addressLocal, customer, authorization);
          if (updateAddressServerResponse.statusCode == 200) {
            AddressModel addressServerUpdated = AddressModel.fromJson(updateAddressServerResponse.body);
            //Cambiar el sycn state
            // Actualizar fecha de actualización local con la respuesta del servidor para evitar un ciclo infinito
            await DatabaseProvider.db.UpdateAddress(addressServerUpdated.id, addressServerUpdated, SyncState.synchronized);
          }
        } else if ( diffInMilliseconds < 0) { // Actualizar Local
          await DatabaseProvider.db.UpdateAddress(addressServer.id, addressServer, SyncState.synchronized);
        }
      }
    });
  }

  static Future syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;

    await AddressChannel._createAddressesInBothLocalAndServer(customer, authorization);
    await AddressChannel._updateAddressesInBothLocalAndServer(customer, authorization);
    await AddressChannel._deleteAddressesInBothLocalAndServer(customer, authorization);
  }
}