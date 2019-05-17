

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:joincompany/main.dart';
class ListWidgets{


  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();
  File image;


  Widget label(string){
    //------------------------------------LABEL----------------------------
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(string,style: TextStyle(
          fontSize: 25,
      ),
      ),
    );
  }

  Future<Null> selectDate(BuildContext context )async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020));

  }
  Widget date(context){
    //------------------------------DATE--------------------------
    return Padding(
      padding: const EdgeInsets.only(right: 220),
      child: Center(
        child: RaisedButton(
          child: Text('Fecha: ${_date.toString().substring(0,10)}'),
          onPressed: (){selectDate(context);},
        ),
      ),
    );
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: _time
    );
  }
  Widget dateTime(context){
    //------------------------------DATE------------------------
    return Container(
      width: MediaQuery.of(context).size.width*0.5,
      child: RaisedButton(
        child: Text('Hora: ${_time.format(context)}'),
        onPressed: (){_selectTime(context);},
      ),
    );
  }

  Widget textArea(context){
    return
      //-------------------------------------TEXTAREA---------------
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
                    Radius.circular(20)
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
              //controller: nameController,
              decoration: InputDecoration(

                border: InputBorder.none,

                hintText: '',
              ),
            ),
          ),
        );

  }

  Widget input(context){
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
                  Radius.circular(15)
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
            //controller: nameController,
            decoration: InputDecoration(

              border: InputBorder.none,

              hintText: '',
            ),
          ),
      ),
    );
  }

  picker() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
//    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      image = img;
     // setState(() {});
    }
  }

  Widget uploadImage(context){
    return Column(
      children: <Widget>[
        Container(
          child: new Center(
            child: image == null
                ? new Text('No Image to Show ')
                : new Image.file(image),
          ),
        ),
        RaisedButton(
          onPressed: picker,
          child: Text('Imagen'),
          color: PrimaryColor,
        )
      ],

    );

  }
  Widget loadingTask()
  {
    return Center(
      child: Column(
        children: <Widget>[
          Text('Seleccione una Tarea'),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

