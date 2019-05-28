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

  Map<String,String> dataInfo = Map<String,String>();
  List<Map<String, String>> dataSaveState =  List<Map<String, String>>();
  ListWidgets items = new ListWidgets();
  BuildContext globalContext;
  List<String> listElement = List<String>();
  List<Widget> listWidgetMain = List<Widget>();
  List<FieldModel> listFieldsModels = List<FieldModel>();
  SectionModel section;
  FormModel formGlobal;
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
    globalContext = context;
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
      body:pass ? Stack(
        children: <Widget>[
          ListView.builder(
          itemCount: listFieldsModels.length,
          itemBuilder: (BuildContext context, index){
            if(listFieldsModels[index].fieldType == 'Textarea'){
              return textArea(listFieldsModels[index].name,index.toString());
            }
            if(listFieldsModels[index].fieldType == 'Text'){
              return text(listFieldsModels[index].name,index.toString());
            }

          }

          )
          ]

      ) : Center(child: Text('Seleccione un Formulario'),),
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

 Future<Null> lisC(FormModel form)async {
    for(SectionModel section in form.sections)
      {
        for(FieldModel fields in section.fields)
        {
          listFieldsModels.add(fields);
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

  void saveData(TextEditingController nameController, String id) {
    var value = nameController.text;
    dataInfo.putIfAbsent(id ,()=> value);
    dataInfo[id] = value;
    print(dataInfo.values);

  }
  Widget text(placeholder,String id){
    TextEditingController nameController = TextEditingController();
    return  Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: MediaQuery.of(globalContext).size.width,
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
          onChanged: (value){
           // print(id);
              saveData(nameController,id);
          },
          maxLines: 1,
          controller: nameController,
          decoration: InputDecoration(

            border: InputBorder.none,

            hintText: placeholder,
          ),
        ),
      ),
    );
  }
  Widget textArea(placeholder, String id){
    TextEditingController nameController = TextEditingController();
    return
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(

          width: MediaQuery.of(globalContext).size.width,
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

              onChanged: (value){
              //  print(id);
                saveData(nameController,id);
                },
            maxLines: 4,
             controller: nameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: placeholder,
            ),
          ),
        ),
      );
  }
}

