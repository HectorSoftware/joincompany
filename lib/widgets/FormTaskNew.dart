import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joincompany/blocs/blocTaskForm.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/BuscarRuta/BuscarDireccion.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:http/http.dart' as http;
import 'package:joincompany/Sqlite/database_helper.dart';


class FormTask extends StatefulWidget {


  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {



  BuildContext globalContext;
  List<String> listElement = List<String>();
  List<Widget> listWidgetMain = List<Widget>();
  var data = List<Widget>();
  UserDataBase userToken ;
  String token;
  String customer;
  String user;
  FormsModel formType;
  bool pass = false;

  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    final BlocTaskForm _bloc = new BlocTaskForm(context);
    return new Scaffold(
       appBar: AppBar(
         elevation: 12,
         backgroundColor: PrimaryColor,
         leading:  IconButton(
           icon: Icon(Icons.arrow_back,size: 25,),
           tooltip: 'Guardar Tarea',
           iconSize: 35,
           onPressed: ()=> showDialog(
               context: context,
               child: SimpleDialog(

                 title: Text('Guardar Tarea'),
                 children: <Widget>[
                   Padding(
                     padding: const EdgeInsets.only(left: 100),
                     child: Column(
                       children: <Widget>[
                         Padding(
                           padding: const EdgeInsets.all(10),
                           child: Row(
                             children: <Widget>[

                               RaisedButton(
                                 child:  Text('Aceptar'),
                                 color: Colors.white,
                                 elevation: 0,

                                 onPressed: (){
                                   //GUARDAR TAREA AQUI...
                                   Navigator.pop(context);
                                   Navigator.pop(context);
                                 },
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ))
         ) ,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete,size: 25,),
            tooltip: 'Descartar Formulario',
            iconSize: 35,
            onPressed: ()=> showDialog(
                context: context,
            child: SimpleDialog(

              title: Text('Descartar Formulario'),
              children: <Widget>[
               Padding(
                 padding: const EdgeInsets.only(right: 80),
                 child: Column(
                   children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                            RaisedButton(
                              elevation: 0,
                              color: Colors.white,
                              child: Text('Volver'),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                     Row(
                       children: <Widget>[
                         IconButton(
                           icon: Icon(Icons.delete),
                             onPressed: (){
                               setState(() {
                                 data.clear();
                                 pass= false;
                                 _bloc.idFormType = null;
                                 _bloc.updateListWidget(globalContext);
                               });

                               //Navigator.pop(context);
                             }
                         ),
                         RaisedButton(
                           child: Text('Descartar Formulario'),
                           elevation: 0,
                           color: Colors.white,
                             onPressed: (){
                               setState(() {
                                 pass= false;
                                 data.clear();
                               });
                               _bloc.idFormType = null;
                               _bloc.updateListWidget(globalContext);
                               Navigator.pop(context);
                             }
                         ),
                       ],
                     ),

                   ],
                 ),
               ),
              ],
            ))
          )
        ],
        title: Text('Agregar Tareas'),
      ),
      body:Stack(
        children: <Widget>[
          StreamBuilder<List<dynamic>>(
              stream: _bloc.outListWidget,
              builder: (BuildContext context, snapshot) {
                globalContext  = context;
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (ConnectionState.active != null) {
                   data = snapshot.data;
                  if(snapshot.hasData)
                  {
                    return  buildView(data);
                  }
                  else
                  {
                    return Center(
                      child: Text('Selecione un Formulario'),
                    );
                  }
                }else{
                  CircularProgressIndicator(
                  );
                }
              }
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: PrimaryColor,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu,color: pass? Colors.white: Colors.grey),
              onPressed: () => pass ?  _showModalDateTimeAndDirections(): null


            ),
            IconButton(
                icon: Icon(Icons.business,color: Colors.white,),
                onPressed: () {
                  showModalBottomSheet<String>(
                      context: context,
                      builder: (BuildContext context) {
                        initFormType();
                        return  formType != null ?  new ListView.builder(
                          itemCount: formType.data.length,//formType.data.length,
                          itemBuilder: (BuildContext context, index){
                            return ListTile(
                             contentPadding: EdgeInsets.all(10),
                              title: Text('${formType.data[index].name}'),
                              leading: Icon(Icons.poll),
                              onTap: () async {
                                var getFormResponse = await getForm(formType.data[index].id.toString(), customer, token);
                                FormModel form = FormModel.fromJson(getFormResponse.body);
                                _bloc.idFormType = formType.data[index].id.toString();
                                _bloc.customer = customer;
                                _bloc.token = token;
                                _bloc.form = form;
                                setState(() {
                                  pass = true;
                                });
                                // getFormResponse.body.split(' ').forEach((word) => print(" " + word));
                                _bloc.updateListWidget(globalContext);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ) :  Center(child: CircularProgressIndicator());
                      }
                  );
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget buildView(data){
    return  ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return data[index];
        }
    ) ;
  }
  getAll()async{
    FormsModel forms;
    FormsModel formType;
    await getElements();
    http.Response getAllFormsResponse = await getAllForms(customer , token);
    try{
      if(getAllFormsResponse.statusCode == 200)
      {
        //  print(getAllFormsResponse.headers['content-type']);
        forms = FormsModel.fromJson(getAllFormsResponse.body);
        formType = forms;

      }
    }catch(e){

    }
    return formType;
  }

  initFormType()async{
    formType = await getAll();
  }

  getElements()async{
    userToken = await ClientDatabaseProvider.db.getCodeId('1');
    token = userToken.token;
    customer = userToken.company;
    user = userToken.name;

  }
  void _showModalDateTimeAndDirections() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.location_on),
                title: new Text('Lugar'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchAddress()),
                  );

                },
              ),
              new ListTile(
                leading: new Icon(Icons.access_time),
                title: new Text('Hora'),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

}

