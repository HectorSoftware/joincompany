import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/clientes.dart';
import 'package:joincompany/models/WidgetsList.dart';

class AddContact extends StatelessWidget {
  ListWidgets lw = ListWidgets();
  final String a = "";

  Widget customTextField(String title,String savedData,int maxLines,bool isRequered){
    return Container(
      margin: EdgeInsets.all(12.0),
      color: Colors.grey.shade300,
      child: TextFormField(
        maxLines: maxLines,
        textInputAction: TextInputAction.next,
        validator: (value){
          if(isRequered){
            if (value.isEmpty) {
              return ('ingrese datos');//TODO
            }
          }
        },
        onSaved: (value){
          savedData = value;
        },
        decoration: InputDecoration(
          hintText: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacto"),
        automaticallyImplyLeading: true,
      ),
      body:SingleChildScrollView(
        child: Column(
          children: <Widget>[
            customTextField("Nombre / apellido *",a,1,true),
            customTextField("Codigo *",a,1,true),
            customTextField("Cargo",a,1,false),
            customTextField("Telefono fijo",a,1,false),
            customTextField("Telefono movil",a,1,false),
            customTextField("Emails",a,1,false),
            customTextField("Notas",a,4,false),
            Container(
              margin: EdgeInsets.all(12.0),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("cliente"),
                  Row(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: (){
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (BuildContext context) => new  Cliente()));
                          },
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
            ),
          ],
        ),
      ),
    );
  }
}
