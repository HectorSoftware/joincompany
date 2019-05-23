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



//  List<Widget> listWidget = List<Widget>();
  List<String> listElement = List<String>();
  List<Widget> listWidgetMain = List<Widget>();
  bool changedView = false;

  UserDataBase userToken ;
  String token;
  String customer;
  String user;
  FormsModel formType;

@override
void initState(){
  BuildOwner();
  initFormType();
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
           icon: Icon(Icons.arrow_back),
           tooltip: 'Guardar Tarea',
           iconSize: 35,
           onPressed: (){
             StreamBuilder<String>(
                 stream: _bloc.outSaveForm,
                 builder: (context, snapshot) {



                 }
             );
             Navigator.pop(context);
             Navigator.pushReplacementNamed(context, '/vistap');
           },

         ) ,
         actions: <Widget>[
           IconButton(
             icon: Icon(Icons.delete),
             tooltip: 'Eliminar Cliente',
             iconSize: 35,
             onPressed: (){},

           )

         ],
         title: Text('Agregar Tareas'),
       ),

        body:Stack(
          children: <Widget>[
             StreamBuilder<List<dynamic>>(
            stream: _bloc.outListWidget,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (ConnectionState.active != null) {
                    final data = snapshot.data;
                    if(snapshot.hasData)
                    {
                      return  buildView(data);
                    }
                   else
                     {
                       return Center(
                         child: Column(
                           children: <Widget>[
                             Container(
                               child: Center(
                                 child: CircularProgressIndicator(
                                 ),
                               ),
                             ),
                             Text('Seleccione un Formulario')
                           ],
                         ),
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
              icon: Icon(Icons.menu,color: Colors.white,),
              onPressed: (){
                _showModalDateTimeAndDirections();

              },
            ),
            IconButton(
                icon: Icon(Icons.business,color: Colors.white,),
                onPressed: () {
                  showModalBottomSheet<String>(
                      context: context,
                      builder: (BuildContext context) {
                              return new ListView.builder(
                               itemCount: formType.data.length,//formType.data.length,
                                itemBuilder: (BuildContext context, index){
                                   return ListTile(
                                     title: Text('${formType.data[index].name}'),
                                     leading: Icon(Icons.label),
                                     onTap: () async {

                                       var getFormResponse = await getForm(formType.data[index].id.toString(), customer, token);
                                         FormModel form = FormModel.fromJson(getFormResponse.body);
                                           _bloc.idFormType = formType.data[index].id.toString();
                                           _bloc.customer = customer;
                                           _bloc.token = token;
                                           _bloc.form = form;
                                         // getFormResponse.body.split(' ').forEach((word) => print(" " + word));
                                         _bloc.updateListWidget(context);

                                       Navigator.pop(context);



                                     },

                                   );

                                },
                              );
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


