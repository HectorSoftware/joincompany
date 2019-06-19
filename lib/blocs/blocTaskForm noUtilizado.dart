/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
showDialog(
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
                              onPressed: () {

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
                                 dataInfo = null;
                                 pass= false;
                                 dropdownValue = null;
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
                                 dataInfo = new Map();
                                 pass= false;
                                 dropdownValue = null;
                                 image = null;
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
*/


/*class BlocTaskForm  {


  ListWidgets items = new ListWidgets();
  List<Widget> listWidget = List<Widget>();
  String token;
  String customer;
  var idFormType;
  FormModel form;
  FieldModel camposWidgets;
  List<FieldOptionModel> optionsElements = List<FieldOptionModel>();
  List<Map<String,String>> dataSave =  List<Map<String,String>>();

  var  _taskFormController   = StreamController<List<dynamic>>();
  Stream<List<dynamic>> get outListWidget => _taskFormController.stream;
  Sink<List<dynamic>> get inListWidget => _taskFormController.sink;


  void updateListWidget(context){
    listWidget.clear();
    if(idFormType != null)
    {
      for(SectionModel v in form.sections)
      {
        for(FieldModel k in v.fields)
        {

          switch(k.fieldType){
            case 'Combo':*
              {
                optionsElements = k.fieldOptions;
                listWidget.add(items.createState().combo(optionsElements,k.name));
              //  listWidget.add(items.createState().dateTime());
              }
              break;
            case 'Text':*
              {
                final nameController = TextEditingController();
                listWidget.add(items.createState().text(context,k.name,nameController,v.id.toString() ));
              }
              break;
            case 'Textarea':*
              {
                final nameController = TextEditingController();
                listWidget.add(items.createState().textArea(context,k.name,nameController,v.id.toString()));
              }
              break;
            case 'Number':*
              {
                final nameController = TextEditingController();
                listWidget.add(items.createState().number(context,k.name,nameController));
              }
              break;
            case 'Date':*
              {
                listWidget.add(items.createState().dateT(context,k.name));
              }
              break;
            case 'Table':*
              {
                optionsElements = k.fieldOptions;
                listWidget.add(items.createState().tab(optionsElements,context));
              }
              break;
            case 'CanvanSignature':////
              {
                listWidget.add(items.createState().newFirm(context, k.name));
              }
              break;
            case 'Photo':**
              {
                listWidget.add(items.createState().imagePhoto(context,k.name));
              }
              break;
            case 'Image':
              {
                listWidget.add(items.createState().imageImage(context,k.name));
              }
              break;
            case 'Time':
              {
                listWidget.add(items.createState().timeWidget(context,k.name));
              }
              break;
            case 'DateTime'://
              {
                listWidget.add(items.createState().loadingTask(k.fieldType));
              }
              break;
            case 'ComboSearch':
              {
                listWidget.add(items.createState().ComboSearch(context, k.name));
              }
              break;
            case 'Boolean':
              {
                listWidget.add(items.createState().bolean());
              }
              break;
            case 'CanvanImage'://
              {
                listWidget.add(items.createState().loadingTask(k.fieldType));
              }
              break;
            default:
              {
                listWidget.add(items.createState().label(k.fieldType));
              }
              break;
          }
        }
      }
      inListWidget.add(listWidget);
    }else{
    }
  }
  void saveTask(BuildContext context, data,){


  }

  @override
  void dispose() {
    _taskFormController.close();
  }

  BlocTaskForm(context) {
    updateListWidget(context);
  }

    listOptions = listFieldsModels[index].fieldOptions;
                for(FieldOptionModel varV in listOptions)
                  {
                    print(varV.name);
                    print(varV.value);
                    listName.add(varV.name);
                    listValues.add(varV.value.toString());
                  }
                Card card(){
                  return Card(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '',
                      ),
                    ),
                  );
                }
                Card title(String title)
                 {
                   return Card(
                     child: Text(title),

                   );
                 }
                //COLUMNAS
                Container columna(Color col,int intCard){
                  List<Widget> listCard = new List<Widget>();
                  for(int i = 0; i < intCard; i++){
                    listCard.add(card());
                  }
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: col,
                    child: Column(
                      children: <Widget>[
                        card(),
                        Divider(
                          height: 20,
                          color: Colors.black,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: ListView.builder(
                            itemCount: listCard.length,
                            itemBuilder: (context,index){
                              return listCard[index];
                            },
                          ),
                        )
                      ],
                    ),
                  );
                }
                //LISTA DE COLUMNAS
                List<Widget> listColuma = new List<Widget>();
                 listColuma.add(columna(Colors.red[50],listValues.length));
                return SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listColuma.length,
                      itemBuilder: (context,index){
                        return listColuma[index];
                      },
                      // This next line does the trick.
                    ) ,
                  ),
                );
              }
}*/