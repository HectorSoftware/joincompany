
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/FormService.dart';

class FormChannel {
  
  FormChannel();

  static Future _createFormsInBothLocalAndServer(String customer, String authorization) async {

    // Create Server To Local
    var formsServerResponse = await getAllFormsFromServer(customer, authorization);
    FormsModel formsServer = FormsModel.fromJson(formsServerResponse.body);

    Set idsFormsServer = new Set();
    formsServer.data.forEach((formServer) async {
      idsFormsServer.add(formServer.id);
    });

    Set idsFormsLocal = new Set.from(await DatabaseProvider.db.RetrieveAllFormIds()); //método de albert

    Set idsToCreate = idsFormsServer.difference(idsFormsLocal);

    formsServer.data.forEach((formServer) async {
      if (idsToCreate.contains(formServer.id)) {
        // Cambiar el SyncState Local
        var getFormResponse = await getFormFromServer(formServer.id.toString(), customer, authorization);
        FormModel form = FormModel.fromJson(getFormResponse.body);

        await DatabaseProvider.db.CreateForm(form, SyncState.synchronized);
      }
    });
  }

  static Future _deleteFormsInBothLocalAndServer(String customer, String authorization) async {

    // Delete Server To Local
    var formsServerResponse = await getAllFormsFromServer(customer, authorization);
    FormsModel formsServer = FormsModel.fromJson(formsServerResponse.body);

    Set idsFormsServer = new Set();
    formsServer.data.forEach((formServer) async {
      idsFormsServer.add(formServer.id);
    });

    Set idsFormsLocal = new Set.from( await DatabaseProvider.db.RetrieveAllFormIds() ); //método de albert

    Set idsToDelete = idsFormsLocal.difference(idsFormsServer);

    idsToDelete.forEach((idToDelete) async{
      await DatabaseProvider.db.DeleteFormById(idToDelete);
    });
  }

  static Future _updateFormsInBothLocalAndServer(String customer, String authorization) async {
    
    var formsServerResponse = await getAllFormsFromServer(customer, authorization);
    FormsModel formsServer = FormsModel.fromJson(formsServerResponse.body);

    formsServer.data.forEach((formServer) async {

      FormModel formLocal = await DatabaseProvider.db.ReadFormById(formServer.id);
      if (formLocal != null) {

        DateTime updateDateLocal  = DateTime.parse(formLocal.updatedAt); 
        DateTime updateDateServer = DateTime.parse(formServer.updatedAt);
        int  diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;
        
        if ( diffInMilliseconds < 0 ) { // Actualizar Local
          await DatabaseProvider.db.UpdateForm(formServer.id, formServer, SyncState.synchronized);
        }
      }
    });
  }

  static Future syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;

    await FormChannel._deleteFormsInBothLocalAndServer(customer, authorization);
    await FormChannel._updateFormsInBothLocalAndServer(customer, authorization);
    await FormChannel._createFormsInBothLocalAndServer(customer, authorization);
  }


}