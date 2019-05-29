import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/CustomerModel.dart';

class CustomerChannel {
  
  CustomerChannel();
  
  static void retrieveNewsCustomersLocal() async {
    CustomerModel customer = CustomerModel(
      name : 'Test test test', 
      code : '32154654', 
      email : "test@test.com", 
      phone : "798798", 
      contactName : "name conact", 
      details : "nota" 
    );

    // var response = await DatabaseProvider.db.CreateCustomer(customer);
    // var response = await DatabaseProvider.db.ReadCustomer(0);
    // var response = await DatabaseProvider.db.ReadUser(0);
    // var response = await DatabaseProvider.db.ReadTask(0);
    var response = await DatabaseProvider.db.ReadForm(0);
    print(response);
    print(response.toString());
  } 
}