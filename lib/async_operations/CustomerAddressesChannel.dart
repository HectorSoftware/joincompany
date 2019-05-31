import 'dart:convert';

import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/services/CustomerService.dart';

class CustomerAddressesChannel {
  
  CustomerAddressesChannel();
  
  static void relateCustomerAddressesInBothLocalAndServer() async {

    String customer = '';
    String authorization = '';

    // Create Local To Server    
    List<Map> customerAddressesLocal = await DatabaseProvider.db.ReadCustomerAddressesBySyncState(SyncState.created);

    customerAddressesLocal.forEach((customerAddressLocal) async {
      var relateCustomerAddressResponseServer = await relateCustomerAddress(customerAddressLocal["customer_id"], customerAddressLocal["address_id"], customer, authorization);
      if (relateCustomerAddressResponseServer.statusCode==200) {
        Map<String, dynamic> jsonResponse = json.decode(relateCustomerAddressResponseServer.body);
        // Cambiar el SyncState Local
        // DatabaseProvider.db.ChangeSyncState(customerAddressLocal["id"], SyncState.synchronized);



        // Actualizar el id local o usar otro campo para guardar el id del recurso en el servidor
        // var updateCustomerAddressesLocalResponse = await DatabaseProvider.db.UpdateCustomerAddresses(customerAddressLocal["id"], jsonResponse);
      }
    });

    // Create Server To Local
    var customersWithAddressResponse = await getAllCustomersWithAddress(customer, authorization);
    CustomersWithAddressModel customersWithAddress = CustomersWithAddressModel.fromJson(customersWithAddressResponse.body);

    Set customersAddressesServer = new Set();
    customersWithAddress.data.forEach((customerWithAddress) async {
  	  // Set server = new Set.from([ "419-345", "419-346" ]);
      customersAddressesServer.add("${customerWithAddress.customerId}-${customerWithAddress.addressId}");
    });

    Set customersAddressesLocal = new Set.from( [ "419-345" ] ); //método de albert

    Set customersAddressesToCreate = customersAddressesServer.difference(customersAddressesLocal);

    customersAddressesToCreate.forEach((customerAddressToCreate) async {
      var customerAddressIds = customerAddressToCreate.split("-");
    	int customerId = customerAddressIds[0];
    	int addressId = customerAddressIds[1];
      var createCustomerAddressResponseLocal = await DatabaseProvider.db.CreateCustomerAdress(null, null, null, null, customerId, addressId, true);
      // Cambiar el SyncState Local
    });
  }

  static void unrelateCustomerAddressesInBothLocalAndServer() async {
    String customer = '';
    String authorization = '';

    //Delete Local To Server
    List<Map> customerAdressesLocal = await DatabaseProvider.db.ReadCustomerAddressesBySyncState(SyncState.deleted);

    customerAdressesLocal.forEach((customerAddressLocal) async {
      var unrelateCustomerAddressResponseServer = await unrelateCustomerAddress(customerAddressLocal["customer_id"], customerAddressLocal["address_id"], customer, authorization);
      if (unrelateCustomerAddressResponseServer.statusCode==200) {
        var deleteCustomerAddressesResponseLocal = await DatabaseProvider.db.DeleteCustomerAdress(customerAddressLocal["id"]);
      }
    });

    // Delete Server To Local
    var customersWithAddressResponse = await getAllCustomersWithAddress(customer, authorization);
    CustomersWithAddressModel customersWithAddress = CustomersWithAddressModel.fromJson(customersWithAddressResponse.body);

    Set customersAddressesServer = new Set();
    customersWithAddress.data.forEach((customerWithAddress) async {
  	  // Set server = new Set.from([ "419-345", "419-346" ]);
      customersAddressesServer.add("${customerWithAddress.customerId}-${customerWithAddress.addressId}");
    });

    Set customersAddressesLocal = new Set.from( [ "419-345" ] ); //método de albert

    Set customersAddressesToDelete = customersAddressesLocal.difference(customersAddressesServer);

    customersAddressesToDelete.forEach((customerAddressToDelete) async {
      var customerAddressIds = customerAddressToDelete.split("-");
    	int customerId = customerAddressIds[0];
    	int addressId = customerAddressIds[1];
      // sobrecargar método para eliminar con los parámetros customerId, addressId
      // var deleteCustomerAddressResponseLocal = await DatabaseProvider.db.DeleteCustomerAdress(customerId, addressId);
    });
  }
}