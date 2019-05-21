import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/addContact.dart';
import 'package:joincompany/models/CustomersModel.dart';
class ContactView extends StatefulWidget {
  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  Future<List<CustomersModel>> data(){ //TODO
    //CustomerService.getAllCustomers();
    return null;
  }

  Widget contactCard(String dataContacts) {//TODO: change String for Contacts
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: <Widget>[
          Container(
            margin: EdgeInsets.all(12.0),
            child: Align(alignment: Alignment.centerLeft,child: Text(dataContacts, style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),),),
          ),
          Container(
            margin: EdgeInsets.all(12.0),
            child: Align(alignment: Alignment.centerLeft,child: Text("empresa"),),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.mail
                ),
                onPressed: (){},
              ),

              IconButton(
                icon: Icon(
                    Icons.call
                ),
                onPressed: (){},
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
//      body: FutureBuilder<List<String>>(//TODO: change String for Contacts
//        future: null, //TODO: getAllContacts()
//        builder: (BuildContext contex, AsyncSnapshot<List<String>> snapshot){//TODO: change String for Contacts
//          if (snapshot.hasData) {
//            return ListView.builder(
//                itemCount: snapshot.data.length,
//                itemBuilder: (BuildContext contex, int index){
//                  String item = snapshot.data[index]; //TODO: change String for Contacts
//                  return contactCard(item);
//                }
//            );
//          }else{
//            return Center(child: CircularProgressIndicator());
//          }
//        },
//      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            contactCard("Contacto 1"),
            contactCard("Contacto 2"),
            contactCard("Contacto 3"),
            contactCard("Contacto 4"),
            contactCard("Contacto 5"),
            contactCard("Contacto 6"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed:(){
          Navigator.of(context).pop();
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new  AddContact()));
        },
      ),
    );
  }
}
