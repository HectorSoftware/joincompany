import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:joincompany/models/TaskModel.dart';

import 'clientes.dart';

enum type{
  POSS,
  CLIENT,
  CONTACT,
  DATE,
  MOUNT,
}

class FormBusiness extends StatefulWidget {
  @override
  _FormBusinessState createState() => _FormBusinessState();
}

class _FormBusinessState extends State<FormBusiness> {
  List<TaskModel> task = List<TaskModel>();

  TextEditingController name,code,cargo,tlfF,tlfM,email,note;
  String errorTextFieldName,errorTextFieldCode,errorTextFieldNote;

  Future<TaskModel> getTask() async{
    return showDialog<TaskModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Cliente(true);
      },
    );
  }//TODO

  Widget customTextField(String title, type t, int maxLines){
    return Container(
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5
            )
          ]
      ),
      //color: Colors.grey.shade300,
      child: TextField(
        controller: getController(t),
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none,
          errorText: getErrorText(t),
          contentPadding: EdgeInsets.all(12.0),
        ),
        onChanged: _onChanges(t),
      ),
    );
  }

  String getErrorText(type t){
    switch(t){
      case type.POSS:
        // TODO: Handle this case.
        break;
      case type.CLIENT:
        // TODO: Handle this case.
        break;
      case type.CONTACT:
        // TODO: Handle this case.
        break;
      case type.DATE:
        // TODO: Handle this case.
        break;
      case type.MOUNT:
        // TODO: Handle this case.
        break;
    }
    return "";
  }

  _onChanges(type t){
    switch(t){
      case type.POSS:
        // TODO: Handle this case.
        break;
      case type.CLIENT:
        // TODO: Handle this case.
        break;
      case type.CONTACT:
        // TODO: Handle this case.
        break;
      case type.DATE:
        // TODO: Handle this case.
        break;
      case type.MOUNT:
        // TODO: Handle this case.
        break;
    }
  }

  void initController(){
    name = TextEditingController();
    code = TextEditingController();
    tlfF = TextEditingController();
    tlfM = TextEditingController();
    email = TextEditingController();
    note = TextEditingController();
  }

  void disposeController(){
    name.dispose();
    code.dispose();
    tlfF.dispose();
    tlfM.dispose();
    email.dispose();
    note.dispose();
  }

  TextEditingController getController(type t){
    switch (t){
      case type.POSS:
        // TODO: Handle this case.
        break;
      case type.CLIENT:
        // TODO: Handle this case.
        break;
      case type.CONTACT:
        // TODO: Handle this case.
        break;
      case type.DATE:
        // TODO: Handle this case.
        break;
      case type.MOUNT:
        // TODO: Handle this case.
        break;
    }
    return null;
  }

  ListView getClientBuilder() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: task.length,
        itemBuilder: (context, int index) {
          return Container(
            child: ListTile(
              leading: const Icon(Icons.account_box,
                  size: 25.0),
              title: Text(task[index].name),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                setState(() {
                  task.remove(task[index]);
                });
              }),
            ),
          );
        }
    );
  }

  @override
  void initState() {
    initController();
    super.initState();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Negocio"),
        automaticallyImplyLeading: true,
      ),
      body:SingleChildScrollView(
        child: Column(
          children: <Widget>[
            customTextField('Posicionamiento cliente',type.POSS,1),
            customTextField('Cliente B',type.CLIENT,1),
            customTextField('Primer Contacto',type.CONTACT,1),
            customTextField('Fecha',type.DATE,1),
            customTextField('Monto',type.MOUNT,1),
            Container(
                margin: EdgeInsets.all(12.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Tarea o Nota"),
                    Row(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: ()async{
//                              var t = await getTask();
//                              if (t != null){
//                                setState(() {
//                                  task.add(t);
//                                });
//                              }
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: (){
//                              getTask();
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                )
            ),
            Container(
              child: task.isNotEmpty ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * (0.1 * task.length),
                  child:getClientBuilder()): Container() ,
            ),
          ],
        ),
      ),
    );
  }
}
