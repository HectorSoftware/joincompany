import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:joincompany/pages/home/taskHome.dart';

class AddClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

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
        body: ListView(
          children: <Widget>[
            Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30,left: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width/1.2,
                      height: 45,
                      padding: EdgeInsets.only(
                          top: 4,left: 16, right: 16, bottom: 4
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(50)
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
                        //controller: nameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.account_circle,
                            color: Colors.black,
                          ),
                          hintText: 'Nombre',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 120,left: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width/1.2,
                      height: 45,
                      padding: EdgeInsets.only(
                          top: 4,left: 16, right: 16, bottom: 4
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(50)
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
                        //controller: nameController,
                        decoration: InputDecoration(

                          border: InputBorder.none,
                          icon: Icon(Icons.label_important,
                            color: Colors.black,
                          ),
                          hintText: 'Codigo',
                        ),
                      ),
                    ),
                  ),

              Padding(
                padding: const EdgeInsets.only(top: 380),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[

                        Text('Contacto'),
                        Padding(
                          padding: const EdgeInsets.only(left: 250),
                          child: IconButton(
                            icon: Icon(Icons.delete),
                            tooltip: 'Eliminar Cliente',
                            iconSize: 35,
                            onPressed: (){},

                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: 'Eliminar Cliente',
                          iconSize: 35,
                          onPressed: (){},

                        ),
                      ],
                    ),
                  ],
                ),
              )
                ]

            ),

          ],

        )
    );
  }
}