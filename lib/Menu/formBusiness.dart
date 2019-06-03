import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

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

  var DatepickedInit = (new DateTime.now()).add(new Duration(days: -14));
  var DatepickedEnd = new DateTime.now();
  String value;

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

  Widget customDropdownMenu(List<FieldOptionModel> elements, String title, String value){
//    List<String> dropdownMenuItems = List<String>();
//    for(FieldOptionModel v in elements){
//      dropdownMenuItems.add(v.name);
//    }

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
        child: DropdownButton<String>(
          isDense: false,
          icon: Icon(Icons.arrow_drop_down),
          elevation: 10,
          value: value,
          hint: Text(title),
          isExpanded: true,
          onChanged: (String newValue) {
            setState(() {
              value = newValue;
            });
          // ignore: strong_mode_invalid_cast_literal_list
          }, items: <DropdownMenuItem>[],
//        items: dropdownMenuItems.map<DropdownMenuItem<String>>((String value) {
//          return DropdownMenuItem<String>(
//            value: value,
//            child: Text(value),
//          );
//        }).toList(),
        ),
    );
  }

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

  Widget customForm(type t){
    switch(t){
      case type.POSS:
        return customTextField('Posicionamiento cliente',t,1);
      case type.CLIENT:
        return customDropdownMenu(null,' cliente B',value);
      case type.CONTACT:
        return customDropdownMenu(null,' Primer Contacto',value);
      case type.DATE:
        return ListTile(
          title: Text("fecha"),
          trailing: Icon(Icons.calendar_today),
          onTap: (){
            selectDate(context);
          },
        );
      case type.MOUNT:
        return customTextField('Monto',t,1);
    }
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

  List<DateTime> valueselectDate = new List<DateTime>();
  Future<Null> selectDate( context )async{
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: DatepickedInit,
        initialLastDate: DatepickedEnd,
        firstDate: new DateTime(1990),
        lastDate: new DateTime(2030)
    );
    if(picked != null){
      bool updateVarDataTime = false;
      if(picked.length == 1){
        if((DatepickedInit != picked[0])||(DatepickedEnd != picked[0])){
          updateVarDataTime = true; DatepickedInit = DatepickedEnd = picked[0];
        }
      }else{
        if((DatepickedInit != picked[0])||(DatepickedEnd != picked[1])){
          updateVarDataTime = true;
          DatepickedInit = picked[0];
          DatepickedEnd = picked[1];
        }
      }

      if(updateVarDataTime){
        setState(() =>
        valueselectDate = picked,
        );
        setState(() {
          DatepickedInit; DatepickedEnd;
          //blocListTaskRes;
        });
      }
    }
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
            customForm(type.POSS),
            customForm(type.CLIENT),
            customForm(type.CONTACT),
            customForm(type.DATE),
            customForm(type.MOUNT),
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
