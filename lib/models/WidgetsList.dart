import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:joincompany/blocs/blocTaskForm.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/FieldModel.dart';

enum Method{
  CAMERA,
  GALLERY
}
class ListWidgets extends StatefulWidget {


  @override
  _ListWidgetsState createState() => new _ListWidgetsState();

}

class _ListWidgetsState extends State<ListWidgets> {

@override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return null;
  }

  DateTime _date = new DateTime.now();

  TimeOfDay _time = new TimeOfDay.now();
  File image;
  List<String> elementsNew = List<String>();
  String pivot;
  List<Offset> _points = <Offset>[];


// Changeable in demo


  Widget tab(List<FieldOptionModel> data,BuildContext contex){
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(12),
        width: MediaQuery.of(contex).size.width,
        height: MediaQuery.of(contex).size.height * 0.4,
        child: ListView(
          // This next line does the trick.
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Container(
              width: MediaQuery.of(contex).size.width * 0.5,
              color: Colors.grey[200],
              child: Column(
                children: <Widget>[
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Divider(
                    height: 20,
                    color: Colors.black,
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(contex).size.width * 0.5,
              color: Colors.green[100],
              child: Column(
                children: <Widget>[
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Divider(
                    height: 20,
                    color: Colors.black,
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(contex).size.width * 0.5,
              color: Colors.red[50],
              child: Column(
                children: <Widget>[
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Divider(
                    height: 20,
                    color: Colors.black,
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(contex).size.width * 0.5,
              color: Colors.blue[50],
              child: Column(
                children: <Widget>[
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Divider(
                    height: 20,
                    color: Colors.black,
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                  Card(
                    child:
                    TextField(
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        ,
      ),
    );
  }
/*Widget dateTime(){
    return  DateTimePickerFormField(
      inputType: inputType,
      format: formats[inputType],
      editable: editable,
      decoration: InputDecoration(
          labelText: 'Date/Time', hasFloatingPlaceholder: false),
      onChanged: (dt) => setState(() => date = dt),
    ),
}*/

  Widget label(string){
    //------------------------------------LABEL----------------------------
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(string,style: TextStyle(
          fontSize: 20,
      ),
      ),
    );
  }

  Future<Null> selectTime(BuildContext context )async{
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: _time,
    );
         }

Future<Null> selectDate(context )async{
  final DateTime picked = await showDatePicker(
      context: context.inheritFromWidgetOfExactType(Widget),
      initialDate: _date,
      firstDate: new DateTime(2000),
      lastDate: new DateTime(2020)
  );

  if (picked != null && picked != _date){
    setState(() {
      _date = picked;
    });

  }

}

Widget date(BuildContext context, String string){
  //------------------------------DATE--------------------------
  return Row(
    children: <Widget>[
      Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 1,left: 16),
                child: Text(string),
              ),
            ],
          ),

        ],

      ),
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: RaisedButton(
          child: Text('${_date.toString().substring(0,10)}'),
          onPressed: (){selectDate(context.ancestorInheritedElementForWidgetOfExactType(Widget));},
        ),
      ),
    ],
  );
  }

Widget timeWidget(BuildContext context, String string){
  //------------------------------DATE--------------------------
  return Row(
    children: <Widget>[
      Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 1,left: 16),
                child: Text(string),
              ),
            ],
          ),

        ],

      ),
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: RaisedButton(
          child: Text(string),
          onPressed: (){selectTime(context);},
        ),
      ),
    ],
  );
}

  Widget textArea(BuildContext context,placeholder, TextEditingController nameController){
    return
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(

            width: MediaQuery.of(context).size.width,
            height: 150,
            padding: EdgeInsets.only(
                top: 4,left: 16, right: 16, bottom: 4
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(10)
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5
                  )
                ]
            ),
            child: TextField(
              maxLines: 4,
              controller: nameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholder,
              ),
            ),
          ),

        );


  }

  Widget text( BuildContext context,placeholder, TextEditingController nameController){
    //-----------------------------------------INPUT----------------------------------
    TextEditingController public = nameController;
    return  Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: 40,
          padding: EdgeInsets.only(
              top: 4,left: 16, right: 16, bottom: 4
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                  Radius.circular(10)
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5
                )
              ]
          ),
          child: TextField(
            maxLines: 1,
            controller: nameController,
            decoration: InputDecoration(

              border: InputBorder.none,

              hintText: placeholder,
            ),
          ),
      ),
    );
  }
  Widget number(BuildContext context,placeholder, TextEditingController nameController){
    return  Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width:  40,
        height: 40,
        padding: EdgeInsets.only(
            top: 4,left: 16, right: 16, bottom: 4
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(10)
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5
              )
            ]

        ),
        child: TextField(

          keyboardType: TextInputType.number,
          maxLines: 1,
          controller: nameController,
          decoration: InputDecoration(
            border: InputBorder.none,

            hintText: placeholder,
          ),
        ),
      ),
    );
  }

  pickerImage(Method m) async {

        File img = await ImagePicker.pickImage(source: ImageSource.gallery);
        if (img != null) {
          setState(() {
            image = img;
          });
      }
  }
  Widget imageImage(BuildContext context, String string){
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 5,left: 10),
                  child: RaisedButton(
                    onPressed: (){
                        pickerImage(Method.GALLERY);
                      },
                    child: Text(''),
                    color: PrimaryColor,
                  ),
                ),
              ],
            ),

          ],

        ),
        Container(
          width: MediaQuery.of(context).size.width* 0.5,
          child: new Center(
            child: image == null
                ? new Text(string)
                : new Image.file(image),

          ),
        )
      ],
    );
  }


  pickerPhoto(Method m) async {

    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if (img != null) {
      setState(() {
        image = img;
      });
    }
  }
  Widget imagePhoto(BuildContext context, String string){
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10,left: 5),
                  child: RaisedButton(
                    onPressed: (){
                      pickerPhoto(Method.CAMERA);
                    },
                    child: Text(string),
                    color: PrimaryColor,
                  ),
                ),
              ],
            ),

          ],

        ),
        Container(
          width: MediaQuery.of(context).size.width* 0.5,
          child: new Center(
            child: image == null
                ? new Text('')
                : new Image.file(image),

          ),
        )
      ],
    );
  }


  Widget loadingTask(String string) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(string),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }


  List<String> dropdownMenuItems = List<String>();
  String dropdownValue = null ;
  Widget combo(List<FieldOptionModel> elements, String string)
  {
    for(FieldOptionModel v in elements) dropdownMenuItems.add(v.name);

    return  Padding(
      padding: const EdgeInsets.only(left: 20,right: 10,bottom: 10,top: 10),
      child: DropdownButton<String>(
        isDense: false,
        icon: Icon(Icons.arrow_drop_down),
        elevation: 10,
        value: dropdownValue,
        hint: Text(string),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
          });
          },
        items: dropdownMenuItems.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget newFirm(BuildContext context){
    return IconButton(
      onPressed: (){
        Navigator.of(context).pushReplacementNamed('/firma');


      },
      icon: Icon(Icons.filter_list),
    );
  }
@override
  void setState(fn) {
  dropdownValue ;
    super.setState(fn);
  }
}



