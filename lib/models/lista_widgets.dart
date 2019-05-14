

import 'package:flutter/material.dart';
import 'dart:async';

class ListWidgets{


  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();


  Widget label(){
    //------------------------------------LABEL----------------------------
    return Text('hola vv');
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
    return RaisedButton(
      child: Text('Fecha: ${_date.toLocal()}'),
      onPressed: (){selectDate(context);},
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
    return RaisedButton(
      child: Text('Hora: ${_time.format(context)}'),
      onPressed: (){_selectTime(context);},
    );
  }

  Widget textArea(context){
    return
      //-------------------------------------TEXTAREA---------------
        Container(
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
        );

  }

  Widget input(context){
    //-----------------------------------------INPUT----------------------------------
    return  Container(
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
          maxLines: 1,
          //controller: nameController,
          decoration: InputDecoration(

            border: InputBorder.none,

            hintText: '',
          ),
        ),
    );
  }
}