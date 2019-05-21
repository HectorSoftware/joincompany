

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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


  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();
  File image;
  List<String> elementsNew = List<String>();
  String pivot;
  List<Offset> _points = <Offset>[];

  Widget tab(List<FieldOptionModel> data){
    return SingleChildScrollView(
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(80.0),
          1: FixedColumnWidth(80.0),
        },
        border: TableBorder.all(width: 1.0),
        children: data.map((item) {
          return TableRow(
              children:<Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item.name,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item.value.toString(),
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                )
              ]);
        }).toList(),
      ),
    );
  }


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

  Future<Null> selectDate( context )async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020));

  }
  Widget date(context, String string){
    //------------------------------DATE--------------------------
    return Padding(
      padding: const EdgeInsets.only(right: 220),
      child: Container(
        width: MediaQuery.of(context).size.width *0.5,
        child: RaisedButton(
          child: Text('$string: ${_date.toString().substring(0,10)}'),
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
    return Container(
      width: MediaQuery.of(context).size.width*0.5,
      child: RaisedButton(
        child: Text('Hora: ${_time.format(context)}'),
        onPressed: (){_selectTime(context);},
      ),
    );
  }

  Widget textArea(context,placeholder){
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
              //controller: nameController,
              decoration: InputDecoration(

                border: InputBorder.none,

                hintText: placeholder,
              ),
            ),
          ),
        );
  }

  Widget input(context,placeholder){
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
            //controller: nameController,
            decoration: InputDecoration(

              border: InputBorder.none,

              hintText: placeholder,
            ),
          ),
      ),
    );
  }
  Widget number(context,placeholder){
    return  Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
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
          //controller: nameController,
          decoration: InputDecoration(
            border: InputBorder.none,

            hintText: placeholder,
          ),
        ),
      ),
    );
  }

  picker(Method m) async {
    switch(m){
      case Method.CAMERA:{
        File img = await ImagePicker.pickImage(source: ImageSource.camera);
        if (img != null) {
          image = img;
          // setState(() {});
        }
        break;
      }
      case Method.GALLERY:{
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
        if (img != null) {
          image = img;
          // setState(() {});
        }
      }
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
          onPressed: picker(Method.CAMERA),
          child: Text('Imagen'),
          color: PrimaryColor,
        )
      ],

    );

  }
  Widget loadingTask(context)
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


  List<String> dropdownMenuItems = List<String>();
  String dropdownValue = null;
  Widget combo(List<FieldOptionModel> elements)
  {
    for(FieldOptionModel v in elements) dropdownMenuItems.add(v.name);

    return  DropdownButton<String>(
      value: dropdownValue,
      hint: Text("Seleccione"),
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
    );
  }

Widget tocuh(context){
  return new Scaffold(
    body: new Container(
      child: new GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            RenderBox object = context.findRenderObject();
            Offset _localPosition =
            object.globalToLocal(details.globalPosition);
            _points = new List.from(_points)..add(_localPosition);
          });
        },
        onPanEnd: (DragEndDetails details) => _points.add(null),
        child: new CustomPaint(
          painter: new Signature(points: _points),
          size: Size.infinite,
        ),
      ),
    ),
    floatingActionButton: new FloatingActionButton(
      child: new Icon(Icons.clear),
      onPressed: () => _points.clear(),
    ),
  );
}



  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


class Signature extends CustomPainter {
  List<Offset> points;

  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}



