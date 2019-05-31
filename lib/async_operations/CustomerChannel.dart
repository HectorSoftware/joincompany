import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/services/CustomerService.dart';

class CustomerChannel {
  
  CustomerChannel();
  
  static void createCustomersInBothLocalAndServer() async {
    // CustomerModel customer = CustomerModel(
    //   name : 'Test test test', 
    //   code : '32154654', 
    //   email : "test@test.com", 
    //   phone : "798798", 
    //   contactName : "name conact", 
    //   details : "nota" 
    // );

    // var response = await DatabaseProvider.db.CreateCustomer(customer);


    String customer = '';
    String authorization = '';

    // Create Local To Server    
    List<CustomerModel> customersLocal = await DatabaseProvider.db.ReadCustomersBySyncState(SyncState.created);

    customersLocal.forEach((customerLocal) async {
      var createCustomerResponseServer = await createCustomer(customerLocal, customer, authorization);
      if (createCustomerResponseServer.statusCode==200) {
        CustomerModel customerServer = CustomerModel.fromJson(createCustomerResponseServer.body);
        // Cambiar el SyncState Local
        // Actualizar el id local o usar otro campo para guardar el id del recurso en el servidor
        // DatabaseProvider.db.UpdateCustomer(customerLocal.id, customerServer, SyncState.synchronized);
      }
    });

    // Create Server To Local
    var customersServerResponse = await getAllCustomers(customer, authorization);
    CustomersModel customersServer = CustomersModel.fromJson(customersServerResponse.body);

    Set idsCustomersServer = new Set();
    customersServer.data.forEach((customerServer) async {
      idsCustomersServer.add(customerServer.id);
    });

    Set idsCustomersLocal = new Set.from([1,2,3]); //método de albert

    Set idsToCreate = idsCustomersServer.difference(idsCustomersLocal);

    customersServer.data.forEach((customerServer) async {
      if (idsToCreate.contains(customerServer.id)) {
        // Cambiar el SyncState Local
        DatabaseProvider.db.CreateCustomer(customerServer, SyncState.synchronized);
      }
    });
  }

  static void deleteCustomersInBothLocalAndServer() async {
    String customer = '';
    String authorization = '';

    //Delete Local To Server
    List<CustomerModel> customersLocal = await DatabaseProvider.db.ReadCustomersBySyncState(SyncState.deleted);

    customersLocal.forEach((customerLocal) async {
      var deleteCustomerResponseServer = await deleteCustomer(customerLocal.id.toString(), customer, authorization);
      if (deleteCustomerResponseServer.statusCode==200) {
        DatabaseProvider.db.DeleteCustomerById(customerLocal.id);
      }
    });

    // Delete Server To Local
    var customersServerResponse = await getAllCustomers(customer, authorization);
    CustomersModel customersServer = CustomersModel.fromJson(customersServerResponse.body);

    Set idsCustomersServer = new Set();
    customersServer.data.forEach((customerServer) async {
      idsCustomersServer.add(customerServer.id);
    });

    Set idsCustomersLocal = new Set.from(await DatabaseProvider.db.RetrieveAllCustomerIds()); //método de albert

    Set idsToDelete = idsCustomersLocal.difference(idsCustomersServer);

    idsToDelete.forEach((idToDelete) {
      DatabaseProvider.db.DeleteCustomerById(idToDelete);
    });
  }

  static void updateCustomersInBothLocalAndServer() async {
    String customer = '';
    String authorization = '';
    
    var customersServerResponse = await getAllCustomers(customer, authorization);
    CustomersModel customersServer = CustomersModel.fromJson(customersServerResponse.body);

    customersServer.data.forEach((customerServer) async {

      CustomerModel customerLocal = await DatabaseProvider.db.ReadCustomerById(customerServer.id);
      DateTime updateDateLocal  = DateTime.parse(customerLocal.updatedAt); 
      DateTime updateDateServer = DateTime.parse(customerServer.updatedAt);
      int  diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;
      
      if (diffInMilliseconds > 0) { // Actualizar Server
        var updateCustomerServerResponse = await updateCustomer(customerLocal.id.toString(), customerLocal, customer, authorization);
        if (updateCustomerServerResponse.statusCode == 200) {
          CustomerModel customerServerUpdated = CustomerModel.fromJson(updateCustomerServerResponse.body);
          //Cambiar el sycn state
          // Actualizar fecha de actualización local con la respuesta del servidor para evitar un ciclo infinito
          // DatabaseProvider.db.UpdateCustomer(customerServerUpdated.id, customerServerUpdated, SyncState.synchronized);
        }
      } else if ( diffInMilliseconds < 0) { // Actualizar Local
        // DatabaseProvider.db.UpdateCustomer(customerServerUpdated.id, customerServerUpdated, SyncState.synchronized);
      }
    });
  } 
}