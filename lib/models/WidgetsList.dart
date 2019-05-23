import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/pages/FirmTouch.dart';

enum Method{
  CAMERA,
  GALLERY
}

/// Signature of callbacks that have no arguments and return no data.
typedef VoidCallback = void Function();

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
  final formats = {
  InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
  InputType.date: DateFormat('yyyy-MM-dd'),
  InputType.time: DateFormat("HH:mm"),
};

  bool checkSearchInText(String text, filterText){

  text = text.toLowerCase();
  text = text.replaceAll('á', "a");
  text = text.replaceAll('é', "e");
  text = text.replaceAll('í', "i");
  text = text.replaceAll('ó', "o");
  text = text.replaceAll('ú', "u");

  return text.contains(filterText);
}

  // Changeable in demo
  InputType inputType = InputType.both;

  Widget tab(List<FieldOptionModel> data,BuildContext contex){
    //TARJETA DE CAA COLUMNA
    Card card(){
      return Card(
        child:
        TextField(
        ),
      );
    }
    //COLUMNAS
    Container columna(Color col,int intCard){
      List<Widget> ListCard = new List<Widget>();
      for(int i = 0; i < intCard; i++){
        ListCard.add(card());
      }
      return Container(
        width: MediaQuery.of(contex).size.width * 0.5,
        color: col,
        child: Column(
          children: <Widget>[
            card(),
            Divider(
              height: 20,
              color: Colors.black,
            ),
            Container(
              width: MediaQuery.of(contex).size.width * 0.5,
              height: MediaQuery.of(contex).size.height * 0.25,
              child: ListView.builder(
                itemCount: ListCard.length,
                itemBuilder: (contex,index){
                  return ListCard[index];
                },
              ),
            )
          ],
        ),
      );
    }
    //LISTA DE COLUMNAS
    List<Widget> ListColuma = new List<Widget>();
    ListColuma.add(columna(Colors.red[50],2));
    ListColuma.add(columna(Colors.blue[50],5));
    ListColuma.add(columna(Colors.grey[200],3));
    ListColuma.add(columna(Colors.green[100],1));
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(10),
        width: MediaQuery.of(contex).size.width,
        height: MediaQuery.of(contex).size.height * 0.4,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: ListColuma.length,
          itemBuilder: (contex,index){
            return ListColuma[index];
          },
          // This next line does the trick.
        )        ,
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

  Future<Null> selectDate(BuildContext context )async{
  final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: new DateTime(2000),
      lastDate: new DateTime(2020));

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
          onPressed: (){selectDate(context);},
        ),
      ),
    ],
  );
  }

  Widget timeWid(BuildContext context, String string){
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
          child: Text('${_time.toString()}'),
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
            width: MediaQuery.of(context).size.width/1.2,
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
    return  Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
          width: MediaQuery.of(context).size.width/1.2,
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
                      pickerImage(Method.CAMERA);
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

  Widget loadingTask(String string){
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
  Widget combo(List<FieldOptionModel> elements, String string){
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

  Widget searchButtonAppbar(Icon _searchIcon,VoidCallback _searchPressed,String tooltip, double iconSize){
    return IconButton(
      icon: _searchIcon,
      tooltip: tooltip,
      iconSize: iconSize,
      onPressed: _searchPressed,
    );
  }

  @override
  void setState(fn) {
    dropdownValue ;
    super.setState(fn);
  }
}



