import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/AddressesModel.dart';
import 'package:joincompany/services/AddressService.dart';

class AddressChannel {
  
  AddressChannel();
  
  static void createAddressesInBothLocalAndServer() async {

    String customer = '';
    String authorization = '';

    // Create Local To Server    
    List<AddressModel> addressesLocal = await DatabaseProvider.db.ReadAddressesBySyncState(SyncState.created);

    addressesLocal.forEach((addressLocal) async {
      var createAddressResponseServer = await createAddress(addressLocal, customer, authorization);
      if (createAddressResponseServer.statusCode==200) {
        AddressModel addressServer = AddressModel.fromJson(createAddressResponseServer.body);
        // Cambiar el SyncState Local
        // Actualizar el id local o usar otro campo para guardar el id del recurso en el servidor
        // var updateAddressLocalResponse = await DatabaseProvider.db.UpdateAddress(addressLocal.id, addressServer, SyncState.synchronized);
      }
    });

    // Create Server To Local
    var addressesServerResponse = await getAllAddresses(customer, authorization);
    AddressesModel addressesServer = AddressesModel.fromJson(addressesServerResponse.body);

    Set idsAddressesServer = new Set();
    addressesServer.data.forEach((addressServer) async {
      idsAddressesServer.add(addressServer.id);
    });

    Set idsAddressesLocal = new Set.from(await DatabaseProvider.db.RetrieveAllAddressIds()); //método de albert

    Set idsToCreate = idsAddressesServer.difference(idsAddressesLocal);

    addressesServer.data.forEach((addressServer) async {
      if (idsToCreate.contains(addressServer.id)) {
        // Cambiar el SyncState Local
        DatabaseProvider.db.CreateAddress(addressServer, SyncState.synchronized);
      }
    });
  }

  static void deleteAddressesInBothLocalAndServer() async {
    String customer = '';
    String authorization = '';

    //Delete Local To Server
    List<AddressModel> addressesLocal = await DatabaseProvider.db.ReadAddressesBySyncState(SyncState.deleted);

    addressesLocal.forEach((addressLocal) async {
      var deleteAddressResponseServer = await deleteAddress(addressLocal.id.toString(), customer, authorization);
      if (deleteAddressResponseServer.statusCode==200) {
        DatabaseProvider.db.DeleteAddressById(addressLocal.id);
      }
    });

    // Delete Server To Local
    var addressesServerResponse = await getAllAddresses(customer, authorization);
    AddressesModel addressesServer = AddressesModel.fromJson(addressesServerResponse.body);

    Set idsAddressesServer = new Set();
    addressesServer.data.forEach((addressServer) async {
      idsAddressesServer.add(addressServer.id);
    });

    Set idsAddressesLocal = new Set.from(await DatabaseProvider.db.RetrieveAllAddressIds()); //método de albert

    Set idsToDelete = idsAddressesLocal.difference(idsAddressesServer);

    idsToDelete.forEach((idToDelete) {
      DatabaseProvider.db.DeleteAddressById(idToDelete);
    });
  }

  static void updateAddressesInBothLocalAndServer() async {
    String customer = '';
    String authorization = '';
    
    var addressesServerResponse = await getAllAddresses(customer, authorization);
    AddressesModel addressesServer = AddressesModel.fromJson(addressesServerResponse.body);

    addressesServer.data.forEach((addressServer) async {

      AddressModel addressLocal = await DatabaseProvider.db.ReadAddressById(addressServer.id);
      DateTime updateDateLocal  = DateTime.parse(addressLocal.updatedAt); 
      DateTime updateDateServer = DateTime.parse(addressServer.updatedAt);
      int  diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;
      
      if (diffInMilliseconds > 0) { // Actualizar Server
        var updateAddressServerResponse = await updateAddress(addressLocal.id.toString(), addressLocal, customer, authorization);
        if (updateAddressServerResponse.statusCode == 200) {
          AddressModel addressServerUpdated = AddressModel.fromJson(updateAddressServerResponse.body);
          //Cambiar el sycn state
          // DatabaseProvider.db.UpdateAddress(addressLocal.id, SyncState.synchronized);

          // Actualizar fecha de actualización local con la respuesta del servidor para evitar un ciclo infinito
          // var updateAddressLocalResponse = await DatabaseProvider.db.UpdateAddress(addressServerUpdated);
        }
      } else if ( diffInMilliseconds < 0) { // Actualizar Local
        // DatabaseProvider.db.UpdateAddress(addressServer);
      }
    });
  } 
}