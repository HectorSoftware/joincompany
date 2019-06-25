import 'dart:convert';

import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/ContactService.dart';
import 'package:joincompany/services/CustomerService.dart';

class CustomerContactsChannel {
  
  CustomerContactsChannel();
  
  static Future _relateCustomerContactsInBothLocalAndServer(String customer, String authorization) async {

    // Create Local To Server    
    // List<Map> customerContactsLocal = await DatabaseProvider.db.ReadCustomerContactsBySyncState(SyncState.created);
    List <Map> customerContactsLocal;

    await Future.forEach(customerContactsLocal, (customerContactLocal) async {
      var relateCustomerContactResponseServer = await relateCustomerContactFromServer(customerContactLocal["customer_id"], customerContactLocal["contact_id"], customer, authorization);
      if (relateCustomerContactResponseServer.statusCode==200) {
        Map<String, dynamic> jsonResponse = json.decode(relateCustomerContactResponseServer.body);
        // Cambiar el SyncState Local
        // Actualizar el id local o usar otro campo para guardar el id del recurso en el servidor
        // await DatabaseProvider.db.UpdateCustomerContact(customerContactLocal["id"], null, null, null, customerContactLocal["customer_id"], customerContactLocal["contact_id"], SyncState.synchronized);
      }
    });

    // Create Server To Local
    var getAllContactsResponse = await getAllContactsFromServer(customer, authorization);
    ContactsModel contact = ContactsModel.fromJson(getAllContactsResponse.body);

    Map<String, int> customersContactsServerIds = new Map<String, int>();

    Set customersContactsServer = new Set();
    await Future.forEach(contact.data, (contact) async {
      if (contact.customerId != null && contact.id != null){
        String customerContactIds = "${contact.customerId}-${contact.id}";
        customersContactsServerIds[customerContactIds] = contact.id;
        customersContactsServer.add(customerContactIds);
      }
    });

    // Set customersContactsLocal = new Set.from( await DatabaseProvider.db.RetrieveAllCustomerContactRelations() ); //método de albert
    var customersContactsLocal;
    Set customersContactsToCreate = customersContactsServer.difference(customersContactsLocal);

    await Future.forEach(customersContactsToCreate, (customerContactToCreate) async {
      var customerContactIds = customerContactToCreate.split("-");
    	int customerId = int.parse(customerContactIds[0]);
    	int contactId = int.parse(customerContactIds[1]);
      // Cambiar el SyncState Local
      // await DatabaseProvider.db.CreateCustomerContact(null, null, null, null, customerId, contactId, SyncState.synchronized);
    });
  }

  static Future _unrelateCustomerContactsInBothLocalAndServer(String customer, String authorization) async {

    //Delete Local To Server
    // List<Map> customerAdressesLocal = await DatabaseProvider.db.ReadCustomerContactsBySyncState(SyncState.deleted);
    var customerAdressesLocal;

    await Future.forEach(customerAdressesLocal, (customerContactLocal) async {
      var unrelateCustomerContactResponseServer = await unrelateCustomerContactFromServer(customerContactLocal["customer_id"], customerContactLocal["contact_id"], customer, authorization);
      if (unrelateCustomerContactResponseServer.statusCode==200) {
        // await DatabaseProvider.db.DeleteCustomerContactById(customerContactLocal["customer_id"], customerContactLocal["contact_id"]);
      }
    });

    // Delete Server To Local
    var contactsResponse = await getAllContactsFromServer(customer, authorization);
    ContactsModel contacts = ContactsModel.fromJson(contactsResponse.body);

    Set customersContactsServer = new Set();
    await Future.forEach(contacts.data, (contact) async {
  	  // Set server = new Set.from([ "419-345", "419-346" ]);
      customersContactsServer.add("${contact.customerId}-${contact.id}");
    });

    // Set customersContactsLocal = new Set.from( await DatabaseProvider.db.RetrieveAllCustomerContactRelations() ); //método de albert
    var customersContactsLocal;

    Set customersContactsToDelete = customersContactsLocal.difference(customersContactsServer);

    await Future.forEach(customersContactsToDelete, (customerContactToDelete) async {
      var customerContactIds = customerContactToDelete.split("-");
    	int customerId = int.parse(customerContactIds[0]);
    	int contactId = int.parse(customerContactIds[1]);
      // sobrecargar método para eliminar con los parámetros customerId, contactId
      // await DatabaseProvider.db.DeleteCustomerContactById(customerId, contactId);
    });
  }

  static Future syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;
    
    await CustomerContactsChannel._unrelateCustomerContactsInBothLocalAndServer(customer, authorization);
    await CustomerContactsChannel._relateCustomerContactsInBothLocalAndServer(customer, authorization);
  }
}