import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/Helper.dart';

class FormChannel {
  
  FormChannel();

  static Future _createFormsInLocal(String customer, String authorization) async {

    var formsServerResponse = await getAllFormsFromServer(customer, authorization);
    FormsModel formsServer = FormsModel.fromJson(formsServerResponse.body);

    Set idsFormsServer = new Set();
    await Future.forEach(formsServer.data, (formServer) async {
      idsFormsServer.add(formServer.id);
    });

    Set<int> idsFormsLocal = new Set<int>.from(await DatabaseProvider.db.RetrieveAllFormIds()); 

    Set<int> idsToCreate = idsFormsServer.difference(idsFormsLocal);

    await Future.forEach(formsServer.data, (formServer) async {
      if (idsToCreate.contains(formServer.id)) {
        var getFormResponse = await getFormFromServer(formServer.id.toString(), customer, authorization);
        FormModel form = FormModel.fromJson(getFormResponse.body);

        await DatabaseProvider.db.CreateForm(form, SyncState.synchronized);
      }
    });
  }

  static Future _deleteFormsInLocal(String customer, String authorization) async {
    dynamic jsonFormsFromServer = await getAllFormsFromServer(customer, authorization);
    FormsModel formsFromServer = FormsModel.fromJson(jsonFormsFromServer.body);

    List<int> formsIdsFromServer = formsFromServer.listFormIds();
    List<int> formsIdsFromLocal = await DatabaseProvider.db.RetrieveAllFormIds();

    Set<int> setOfFormsIdsFromServer = Set<int>.from(formsIdsFromServer);
    Set<int> setOfFormsIdsFromLocal = Set<int>.from(formsIdsFromLocal);
    Set<int> formsToDelete = setOfFormsIdsFromLocal.difference(setOfFormsIdsFromServer);

    await Future.forEach(formsToDelete, (formToDelete) async {
      await DatabaseProvider.db.DeleteFormById(formToDelete);
    });

    if (formsFromServer.data != null)
      await Future.forEach(formsFromServer.data, (formFromServerInList) async {
        dynamic formFromServerResponse = await getFormFromServer(formFromServerInList.id.toString(), customer, authorization);
        FormModel formFromServer = FormModel.fromJson(formFromServerResponse.body);

        List<int> sectionsFromServer = formFromServer.listSectionIds();
        List<int> sectionsFromLocal = await DatabaseProvider.db.ListSectionIdsByForm(formFromServer.id);

        Set<int> setOfSectionsFromServer = Set<int>.from(sectionsFromServer);
        Set<int> setOfSectionsFromLocal = Set<int>.from(sectionsFromLocal);
        Set<int> sectionsToDelete = setOfSectionsFromLocal.difference(setOfSectionsFromServer);
        
        await Future.forEach(sectionsToDelete, (sectionToDelete) async {
          await DatabaseProvider.db.DeleteSectionById(sectionToDelete);
        });

        if (formFromServer.sections != null)
          await Future.forEach(formFromServer.sections, (sectionFromServer) async {
            List<int> fieldsFromServer = await sectionFromServer.listFieldIds();
            List<int> fieldsFromLocal = await DatabaseProvider.db.ListFieldIdsBySection(sectionFromServer.id);

            Set<int> setOfFieldsFromServer = Set<int>.from(fieldsFromServer);
            Set<int> setOfFieldsFromLocal = Set<int>.from(fieldsFromLocal);
            Set<int> fieldsToDelete = setOfFieldsFromLocal.difference(setOfFieldsFromServer);

            await Future.forEach(fieldsToDelete, (fieldToDelete) async {
              await DatabaseProvider.db.DeleteFieldById(fieldToDelete);
            });
          });
      });
  }

  static Future _updateFormsInLocal(String customer, String authorization) async {
    dynamic jsonFormsFromServer = await getAllFormsFromServer(customer, authorization);
    FormsModel formsFromServer = FormsModel.fromJson(jsonFormsFromServer.body);

    if(formsFromServer.data != null)
      await Future.forEach(formsFromServer.data, (formFromServerInList) async {
        dynamic formFromServerResponse = await getFormFromServer(formFromServerInList.id.toString(), customer, authorization);
        FormModel formFromServer = FormModel.fromJson(formFromServerResponse.body);

        bool isFormUpdated = false;

        FormModel formFromLocal = await DatabaseProvider.db.ReadFormById(formFromServer.id);
        if (formFromLocal == null) {
          await DatabaseProvider.db.CreateForm(formFromServer, SyncState.synchronized);
          isFormUpdated = true;
        } else if (formFromLocal.updatedAt != formFromServer.updatedAt) {
          await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
          isFormUpdated = true;
        }

        if (formFromServer.sections != null)
          await Future.forEach(formFromServer.sections, (sectionFromServer) async {
            if (!isFormUpdated) {
              SectionModel sectionFromLocal = await DatabaseProvider.db.ReadSectionById(sectionFromServer.id);
              if (sectionFromLocal == null) {
                await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
                isFormUpdated = true;
              } else if (sectionFromLocal.updatedAt != sectionFromServer.updatedAt) {
                await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
                isFormUpdated = true;
              }

              if (sectionFromServer.fields != null)
                await Future.forEach(sectionFromServer.fields, (fieldFromServer) async {
                  if (!isFormUpdated) {
                    FieldModel fieldFromLocal = await DatabaseProvider.db.ReadFieldById(fieldFromServer.id);
                    if (fieldFromLocal == null) {
                      await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
                      isFormUpdated = true;
                    } else if (fieldFromLocal.updatedAt != fieldFromServer.updatedAt) {
                      await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
                      isFormUpdated = true;
                    }
                  }
                });
            }
          });
      });
  }

  static Future syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;

    await FormChannel._deleteFormsInLocal(customer, authorization);
    await FormChannel._updateFormsInLocal(customer, authorization);
    // await FormChannel._createFormsInLocal(customer, authorization);
  }

}
