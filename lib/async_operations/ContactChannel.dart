import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/ContactService.dart';


class ContactChannel {
  
  ContactChannel();
  
  static Future _createContactsInBothLocalAndServer(String customer, String authorization) async {

    // Create Local To Server    
    List<ContactModel> contactsLocal = await DatabaseProvider.db.ReadContactsBySyncState(SyncState.created);

    await Future.forEach(contactsLocal, (contactLocal) async {
      var createContactResponseServer = await createContactFromServer(contactLocal, customer, authorization);
      if (createContactResponseServer.statusCode==200) {
        ContactModel contactServer = ContactModel.fromJson(createContactResponseServer.body);
        // Cambiar el SyncState Local
        // Actualizar el id local o usar otro campo para guardar el id del recurso en el servidor
        await DatabaseProvider.db.UpdateContact(contactLocal.id, contactServer, SyncState.synchronized);
      }
    });

    // Create Server To Local
    var contactsServerResponse = await getAllContactsFromServer(customer, authorization);
    ContactsModel contactsServer = ContactsModel.fromJson(contactsServerResponse.body);

    Set idsContactsServer = new Set();
    await Future.forEach(contactsServer.data, (contactServer) async {
      idsContactsServer.add(contactServer.id);
    });

    Set idsContactsLocal = new Set.from(await DatabaseProvider.db.RetrieveAllContactIds()); //método de albert

    Set idsToCreate = idsContactsServer.difference(idsContactsLocal);

    await Future.forEach(contactsServer.data, (contactServer) async {
      if (idsToCreate.contains(contactServer.id)) {
        // Cambiar el SyncState Local
        await DatabaseProvider.db.CreateContact(contactServer, SyncState.synchronized);
        await DatabaseProvider.db.CreateCustomerContact(null, null, null, null, contactServer.customerId, contactServer.id, SyncState.synchronized);
      }
    });
  }

  static Future _deleteContactsInBothLocalAndServer(String customer, String authorization) async {

    //Delete Local To Server
    List<ContactModel> contactsLocal = await DatabaseProvider.db.ReadContactsBySyncState(SyncState.deleted);

    await Future.forEach(contactsLocal, (contactLocal) async {
      var deleteContactResponseServer = await deleteContactFromServer(contactLocal.id.toString(), customer, authorization);
      if (deleteContactResponseServer.statusCode==200) {
        await DatabaseProvider.db.DeleteContactById(contactLocal.id);
      }
    });

    // Delete Server To Local
    var contactsServerResponse = await getAllContactsFromServer(customer, authorization);
    ContactsModel contactsServer = ContactsModel.fromJson(contactsServerResponse.body);

    Set idsContactsServer = new Set();
    await Future.forEach(contactsServer.data, (contactServer) async {
      idsContactsServer.add(contactServer.id);
    });

    Set idsContactsLocal = new Set.from(await DatabaseProvider.db.RetrieveAllContactIds()); //método de albert

    Set idsToDelete = idsContactsLocal.difference(idsContactsServer);

    await Future.forEach(idsToDelete, (idToDelete) async{
      await DatabaseProvider.db.DeleteContactById(idToDelete);
    });
  }

  static Future _updateContactsInBothLocalAndServer(String customer, String authorization) async {
    
    var contactsServerResponse = await getAllContactsFromServer(customer, authorization);
    ContactsModel contactsServer = ContactsModel.fromJson(contactsServerResponse.body);

    await Future.forEach(contactsServer.data, (contactServer) async {

      ContactModel contactLocal = await DatabaseProvider.db.ReadContactById(contactServer.id);
      if (contactLocal != null) {
        
        DateTime updateDateLocal  = DateTime.parse(contactLocal.updatedAt); 
        DateTime updateDateServer = DateTime.parse(contactServer.updatedAt);
        int  diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;
        
        if (diffInMilliseconds > 0) { // Actualizar Server
          var updateContactServerResponse = await updateContactFromServer(contactLocal.id.toString(), contactLocal, customer, authorization);
          if (updateContactServerResponse.statusCode == 200) {
            ContactModel contactServerUpdated = ContactModel.fromJson(updateContactServerResponse.body);
            //Cambiar el sycn state
            // Actualizar fecha de actualización local con la respuesta del servidor para evitar un ciclo infinito
            await DatabaseProvider.db.UpdateContact(contactServerUpdated.id, contactServerUpdated, SyncState.synchronized);
          }
        } else if ( diffInMilliseconds < 0) { // Actualizar Local
          await DatabaseProvider.db.UpdateContact(contactServer.id, contactServer, SyncState.synchronized);
        }
      }
    });
  } 

  static Future syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;

    await ContactChannel._deleteContactsInBothLocalAndServer(customer, authorization);
    await ContactChannel._updateContactsInBothLocalAndServer(customer, authorization);
    await ContactChannel._createContactsInBothLocalAndServer(customer, authorization);
  }

}