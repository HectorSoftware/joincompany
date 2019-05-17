import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:joincompany/pages/home/taskHome.dart';

class AddClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    final mediaQueryData = MediaQuery.of(context);
     double aument = 250;
    if (mediaQueryData.orientation == Orientation.portrait) {
      aument = 0.8;
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
                    padding: const EdgeInsets.only(top: 200,left: 20),
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

                          hintText: '      Nota',
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      verticalDirection: VerticalDirection.down,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 400),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[

                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text('Contacto',style: TextStyle(
                                        fontSize: 20
                                    ),),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 200),
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      tooltip: 'Agregar Contacto',
                                      iconSize: 35,
                                      onPressed: (){},

                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_red_eye),
                                    tooltip: 'Ver Contacto',
                                    iconSize: 35,
                                    onPressed: (){},

                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[

                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text('Direccion',style: TextStyle(
                                        fontSize: 20
                                    ),),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 200),
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      tooltip: 'agregar Direccion',
                                      iconSize: 35,
                                      onPressed: (){},

                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_red_eye),
                                    tooltip: 'Ver Direccion',
                                    iconSize: 35,
                                    onPressed: (){},

                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[

                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text('Negocios',style: TextStyle(
                                        fontSize: 20
                                    ),),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 200),
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      tooltip: 'agregar Direccion',
                                      iconSize: 35,
                                      onPressed: (){},

                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_red_eye),
                                    tooltip: 'Ver Direccion',
                                    iconSize: 35,
                                    onPressed: (){},

                                  ),
                                ],
                              ),
                            ],
                          ),
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