import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/CustomerService.dart';


class CustomerChannel {
  
  CustomerChannel();
  
  static Future _createCustomersInBothLocalAndServer(String customer, String authorization) async {

    // Create Local To Server    
    List<CustomerModel> customersLocal = await DatabaseProvider.db.ReadCustomersBySyncState(SyncState.created);

    await Future.forEach(customersLocal, (customerLocal) async {
      var createCustomerResponseServer = await createCustomerFromServer(customerLocal, customer, authorization);
      if (createCustomerResponseServer.statusCode==200) {
        CustomerModel customerServer = CustomerModel.fromJson(createCustomerResponseServer.body);
        // Cambiar el SyncState Local
        // Actualizar el id local o usar otro campo para guardar el id del recurso en el servidor
        await DatabaseProvider.db.UpdateCustomer(customerLocal.id, customerServer, SyncState.synchronized);
      }
    });

    // Create Server To Local
    var customersServerResponse = await getAllCustomersFromServer(customer, authorization);
    CustomersModel customersServer = CustomersModel.fromJson(customersServerResponse.body);

    Set idsCustomersServer = new Set();
    await Future.forEach(customersServer.data, (customerServer) async {
      idsCustomersServer.add(customerServer.id);
    });

    Set idsCustomersLocal = new Set.from(await DatabaseProvider.db.RetrieveAllCustomerIds()); //método de albert

    Set idsToCreate = idsCustomersServer.difference(idsCustomersLocal);

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    await Future.forEach(customersServer.data, (customerServer) async {
      if (idsToCreate.contains(customerServer.id)) {
        // Cambiar el SyncState Local
        await DatabaseProvider.db.CreateCustomer(customerServer, SyncState.synchronized);
        await DatabaseProvider.db.CreateCustomerUser(null, null, null, null, customerServer.id, user.id, SyncState.synchronized);
      }
    });
  }

  static Future _deleteCustomersInBothLocalAndServer(String customer, String authorization) async {

    //Delete Local To Server
    List<CustomerModel> customersLocal = await DatabaseProvider.db.ReadCustomersBySyncState(SyncState.deleted);

    await Future.forEach(customersLocal, (customerLocal) async {
      var deleteCustomerResponseServer = await deleteCustomerFromServer(customerLocal.id.toString(), customer, authorization);
      if (deleteCustomerResponseServer.statusCode==200) {
        await DatabaseProvider.db.DeleteCustomerById(customerLocal.id);
      }
    });

    // Delete Server To Local
    var customersServerResponse = await getAllCustomersFromServer(customer, authorization);
    CustomersModel customersServer = CustomersModel.fromJson(customersServerResponse.body);

    Set idsCustomersServer = new Set();
    await Future.forEach(customersServer.data, (customerServer) async {
      idsCustomersServer.add(customerServer.id);
    });

    Set idsCustomersLocal = new Set.from(await DatabaseProvider.db.RetrieveAllCustomerIds()); //método de albert

    Set idsToDelete = idsCustomersLocal.difference(idsCustomersServer);

    await Future.forEach(idsToDelete, (idToDelete) async{
      await DatabaseProvider.db.DeleteCustomerById(idToDelete);
    });
  }

  static Future _updateCustomersInBothLocalAndServer(String customer, String authorization) async {
    
    var customersServerResponse = await getAllCustomersFromServer(customer, authorization);
    CustomersModel customersServer = CustomersModel.fromJson(customersServerResponse.body);

    await Future.forEach(customersServer.data, (customerServer) async {

      CustomerModel customerLocal = await DatabaseProvider.db.ReadCustomerById(customerServer.id);
      if (customerLocal != null) {
        
        DateTime updateDateLocal  = DateTime.parse(customerLocal.updatedAt); 
        DateTime updateDateServer = DateTime.parse(customerServer.updatedAt);
        int  diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;
        
        if (diffInMilliseconds > 0) { // Actualizar Server
          var updateCustomerServerResponse = await updateCustomerFromServer(customerLocal.id.toString(), customerLocal, customer, authorization);
          if (updateCustomerServerResponse.statusCode == 200) {
            CustomerModel customerServerUpdated = CustomerModel.fromJson(updateCustomerServerResponse.body);
            //Cambiar el sycn state
            // Actualizar fecha de actualización local con la respuesta del servidor para evitar un ciclo infinito
            await DatabaseProvider.db.UpdateCustomer(customerServerUpdated.id, customerServerUpdated, SyncState.synchronized);
          }
        } else if ( diffInMilliseconds < 0) { // Actualizar Local
          await DatabaseProvider.db.UpdateCustomer(customerServer.id, customerServer, SyncState.synchronized);
        }
      }
    });
  } 

  static Future syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;

    await CustomerChannel._createCustomersInBothLocalAndServer(customer, authorization);
    await CustomerChannel._updateCustomersInBothLocalAndServer(customer, authorization);
    await CustomerChannel._deleteCustomersInBothLocalAndServer(customer, authorization);
  }

}