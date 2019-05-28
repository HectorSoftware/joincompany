import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/BuscarRuta/BuscarDireccion.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:http/http.dart' as http;
import 'package:joincompany/Sqlite/database_helper.dart';


class FormTask extends StatefulWidget {


  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {


  ListWidgets items = new ListWidgets();
  BuildContext globalContext;
  List<String> listElement = List<String>();
  List<Widget> listWidgetMain = List<Widget>();

  UserDataBase userToken ;
  String token;
  String customer;
  String user;
  FormsModel formType;
  bool pass = false;
  List<FieldOptionModel> elementsOptions = List<FieldOptionModel>();

  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
       appBar: AppBar(
         elevation: 12,
         backgroundColor: PrimaryColor,
         leading:  IconButton(
           icon: Icon(Icons.arrow_back),
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
                                   Navigator.pushReplacementNamed(context, '/vistap');
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
            icon: Icon(Icons.delete),
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
                                 listWidgetMain.clear();
                                 pass= false;

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
                                 listWidgetMain.clear();
                               });

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
      body:Center(
        child: pass ? Stack(
          children: <Widget>[
            ListView.builder(
            itemCount:listWidgetMain.length,
            itemBuilder: (BuildContext context, index){
              return listWidgetMain[index];

            }

            )
            ]

        ) : Text('Seleccione un Formulario'),
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
                                lisC(form);
                                setState(() {
                                  pass = true;
                                });
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

  lisC(FormModel form){
    listWidgetMain.clear();
    for(SectionModel section in form.sections)
      {
        for(FieldModel fields in section.fields)
        {


          switch(fields.fieldType){
            case 'Combo':
              {
                elementsOptions = fields.fieldOptions;
                listWidgetMain.add(items.createState().combo(elementsOptions,fields.name));
                //  listWidget.add(items.createState().dateTime());
              }
              break;
            case 'Text':
              {
                final nameController = TextEditingController();
                listWidgetMain.add(items.createState().text(context,fields.name,nameController,section.id.toString() ));
              }
              break;
            case 'Textarea':
              {
                final nameController = TextEditingController();
                listWidgetMain.add(items.createState().textArea(context,fields.name,nameController,section.id.toString()));
              }
              break;
            case 'Number':
              {
                final nameController = TextEditingController();
                listWidgetMain.add(items.createState().number(context,fields.name,nameController));
              }
              break;
            case 'Date':
              {
                listWidgetMain.add(items.createState().dateT(context,fields.name));
              }
              break;
            case 'Table':
              {
                elementsOptions = fields.fieldOptions;
                listWidgetMain.add(items.createState().tab(elementsOptions,context));
              }
              break;
            case 'CanvanSignature':
              {
                listWidgetMain.add(items.createState().newFirm(context, fields.name));
              }
              break;
            case 'Photo':
              {
                listWidgetMain.add(items.createState().imagePhoto(context,fields.name));
              }
              break;
            case 'Image':
              {
                listWidgetMain.add(items.createState().imageImage(context,fields.name));
              }
              break;
            case 'Time':
              {
                listWidgetMain.add(items.createState().timeWidget(context,fields.name));
              }
              break;
            case 'DateTime'://
              {
                listWidgetMain.add(items.createState().loadingTask(fields.name));
              }
              break;
            case 'ComboSearch':
              {
                listWidgetMain.add(items.createState().ComboSearch(context, fields.name));
              }
              break;
            case 'Boolean':
              {
                listWidgetMain.add(items.createState().bolean());
              }
              break;
            case 'CanvanImage'://
              {
                listWidgetMain.add(items.createState().loadingTask(fields.name));
              }
              break;
            default:
              {
                listWidgetMain.add(items.createState().label(fields.name));
              }
              break;
          }
        }
      }
  }


  Widget buildView(){
    return  ListView.builder(
        itemBuilder: (BuildContext context, int index) {

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

