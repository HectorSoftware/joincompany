import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/main.dart';

enum type{
  NAME,
  CODE,
  NOTE,
}

class AddClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    void setDataForm(String data, type t){

    }

    Widget customTextField(String title, type t, int maxLines){
      return Container(
        margin: EdgeInsets.all(12.0),
        color: Colors.grey.shade300,
        child: TextFormField(
          maxLines: maxLines,
          textInputAction: TextInputAction.next,
          validator: (value){
            //TODO
          },
          onSaved: (value){
            setDataForm(value, t);
          },
          decoration: InputDecoration(
              hintText: title,
              border: InputBorder.none
          ),
        ),
      );
    }


    return new Scaffold(
      appBar: AppBar(
        title: Text('Agregar Cliente'),
        elevation: 12,
        backgroundColor: PrimaryColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Eliminar Cliente',
            iconSize: 35,
            onPressed: (){},

          )
        ],

      ),
        body:SingleChildScrollView(
          child:Column(
            children: <Widget>[
              customTextField(" Nombre *",type.NAME,1),
              customTextField(" Codigo *",type.CODE,1),
              customTextField("Notas",type.NOTE,4),
              Container(
                     margin: EdgeInsets.all(12.0),
                     child:Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: <Widget>[
                         Text("Contacto"),
                         Row(
                           children: <Widget>[
                             Align(
                               alignment: Alignment.centerRight,
                               child: IconButton(
                                 icon: Icon(Icons.add),
                                 onPressed: (){},
                               ),
                             ),
                             Align(
                               alignment: Alignment.centerRight,
                               child: IconButton(
                                 icon: Icon(Icons.visibility),
                                 onPressed: (){

                                 },
                               ),
                             ),
                           ],
                         )
                       ],
                     )
                 ),//client
              Container(
                     margin: EdgeInsets.all(12.0),
                     child:Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: <Widget>[
                         Text("Direccion"),
                         Row(
                           children: <Widget>[
                             Align(
                               alignment: Alignment.centerRight,
                               child: IconButton(
                                 icon: Icon(Icons.add),
                                 onPressed: (){
                                   showDialog(context: context,
                                   builder: (BuildContext contex){
                                     return AlertDialog(
                                       content: Column(
                                         mainAxisSize: MainAxisSize.min,
                                         children: <Widget>[
                                           Text("TODO"),//TODO
                                         ],
                                       ),
                                     );
                                   }
                                   );
                                 },
                               ),
                             ),
                             Align(
                               alignment: Alignment.centerRight,
                               child: IconButton(
                                 icon: Icon(Icons.visibility),
                                 onPressed: (){},
                               ),
                             ),
                           ],
                         )
                       ],
                     )
                 ),//Direction
              Container(
                     margin: EdgeInsets.all(12.0),
                     child:Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: <Widget>[
                         Text("Negocios"),
                         Row(
                           children: <Widget>[
                             Align(
                               alignment: Alignment.centerRight,
                               child: IconButton(
                                 icon: Icon(Icons.add),
                                 onPressed: (){},
                               ),
                             ),
                             Align(
                               alignment: Alignment.centerRight,
                               child: IconButton(
                                 icon: Icon(Icons.visibility),
                                 onPressed: (){},
                               ),
                             ),
                           ],
                         )
                       ],
                     )
                 ),//Negotiates
            ],
          )
        )
    );
  }
}