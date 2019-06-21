import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/ContactService.dart';


class ContactBloc{
  List<ContactModel> _listContacts = new List<ContactModel>();

  final _contactcontroller = StreamController<List<ContactModel>>();
  Sink<List<ContactModel>> get _inContact => _contactcontroller.sink;
  Stream<List<ContactModel>> get outContact => _contactcontroller.stream;

  ContactBloc(){
    getContact();
  }

  Future getContact() async {

    UserDataBase user =  await ClientDatabaseProvider.db.getCodeId('1');

    var contactsAlls = await getAllContacts(user.company, user.token);
    ContactsModel contactsList = ContactsModel.fromJson(contactsAlls.body);
    _listContacts = contactsList.data;
    if(_listContacts != null){
      _contactcontroller.add(_listContacts);
    }
  }

  @override
  void dispose() {
    _contactcontroller.close();
  }
}
