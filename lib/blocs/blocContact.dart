import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/ContactService.dart';


class ContactBloc{
  List<ContactModel> _listContacts = new List<ContactModel>();

  final _contactcontroller = StreamController<List<ContactModel>>();
  // ignore: unused_element
  Sink<List<ContactModel>> get _inContact => _contactcontroller.sink;
  Stream<List<ContactModel>> get outContact => _contactcontroller.stream;

  ContactBloc(){
    getContact();
  }

  Future getContact() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    var contactsAlls = await getAllContacts(user.company, user.rememberToken,excludeDeleted: true);
    ContactsModel contactsList = contactsAlls.body;
    _listContacts = contactsList.data;

    _listContacts.sort((a,b)=>a.name.compareTo(b.name));

    if(_listContacts != null){
      _listContacts.sort((a,b)=>a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _contactcontroller.add(_listContacts);
      _contactcontroller.close();
    }
  }
}
