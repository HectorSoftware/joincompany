import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/ImageAndPhoto.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:joincompany/main.dart';

class FormTaskView extends StatefulWidget {
  FormTaskView({this.taskmodelres});
  final TaskModel taskmodelres;
  @override
  _FormTaskViewState createState() => new _FormTaskViewState();
}
class _FormTaskViewState extends State<FormTaskView> {

  UserDataBase userToken ;
  String token,customer, user;
  int responsibleId;
  TaskModel taskOne;
  DateTime _dateTask = new DateTime.now();
  Map<String,String> dataInfo = Map<String,String>();
  FormModel formGlobal;
  List<FieldModel> listFieldsModels = List<FieldModel>();
  DateTime _date = new DateTime.now();
  Image image2;
  TimeOfDay _time = new TimeOfDay.now();

  @override
  void initState(){

    _dateTask = DateTime.parse(widget.taskmodelres.planningDate);
    listWithTask();
    super.initState();
  }

  @override
  void Dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Tarea ' + widget.taskmodelres.name.toString(), style: TextStyle(fontSize: 15),),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Card(
                  color: Colors.grey[200],
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Cliente :',style: TextStyle(fontSize: 20),),
                      ),
                      Expanded(
                        child: widget.taskmodelres.customer != null ? Text('${widget.taskmodelres.customer.name}',style: TextStyle(fontSize: 15),textAlign: TextAlign.left,)
                            : Text('Sin Asignar'),
                      ),
                      Expanded(child: Container(),),
                    ],
                  ),
                ),
                Card(
                  color: Colors.grey[200],
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Direccion :',style: TextStyle(fontSize: 20),),
                      ),
                      Expanded(
                        child: widget.taskmodelres.address != null ? Text('${widget.taskmodelres.address.address}}',style: TextStyle(fontSize: 15),textAlign: TextAlign.left,)
                                                                         : Text('Sin Asignar'),
                      ),
                      Expanded(child: Container(),),
                    ],
                  ),
                ),
                Card(
                  color: Colors.grey[200],
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Fecha :',style: TextStyle(fontSize: 20),),
                      ),
                      Expanded(child: Text(_dateTask.day.toString() + '-' +_dateTask.month.toString() + '-' +_dateTask.year.toString(),textAlign: TextAlign.left,)),
                      Expanded(child: Container(),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            child: listFieldsModels.length != 0 ?
                            ListBuider_ListView(context)
                            : Center(
                              child: Text('Cargando . . .'),
                            ),
          ),
        ],
      ),
    );
  }

  Future listWithTask() async {

    await getElements();

    //SOLICITAR TAREA CON DETALLES
    var responseTaskone = await getTask(widget.taskmodelres.id.toString(),customer, token);
    taskOne = TaskModel.fromJson(responseTaskone.body);


    //SOLICITAR FORMULARIOS
    var getFormResponse = await getForm(widget.taskmodelres.formId.toString(), customer, token);
    FormModel form = FormModel.fromJson(getFormResponse.body);
    formGlobal = form;
    for(var sectionform in form.sections){
      for(var fieldform in sectionform.fields){
        dataInfo.putIfAbsent(fieldform.id.toString() ,()=> '');
        dataInfo[fieldform.id.toString()] = '';
      }
    }
    for(var list in taskOne.customValues){
      var varValue = '';
      if(list.field.fieldType == 'Photo' || list.field.fieldType == 'CanvanSignature' || list.field.fieldType == 'CanvanImage'){
        varValue = list.imageBase64;
      }
      if(list.field.fieldType == 'TextArea' ||
          list.field.fieldType == 'Text' ||
          list.field.fieldType == 'Label' ||
          list.field.fieldType == 'Date' ||
          list.field.fieldType == 'Combo' ||
          list.field.fieldType == 'Number' ||
          list.field.fieldType == 'DateTime' ||
          list.field.fieldType == 'Boolean' ||
          list.field.fieldType == 'ComboSearch' ||
          list.field.fieldType == 'Button' ||
          list.field.fieldType == 'Table' ||
          list.field.fieldType == 'Time' ){
        varValue = list.value;
      }

      //dataInfo.putIfAbsent(list.field.id.toString() ,()=> varValue);
      dataInfo[list.field.id.toString()] = varValue;
    }
    await lisC(form);
  }

  getElements()async{
    userToken = await ClientDatabaseProvider.db.getCodeId('1');
    setState(() {
      userToken;
      token = userToken.token;
      customer = userToken.company;
      user = userToken.name;
      responsibleId = userToken.idUserCompany;
    });
  }

  Future<bool> lisC(FormModel form)async {
    List<FieldModel> listFieldsModelsCopia = List<FieldModel>();
    setState(() {
      formGlobal = form;
      listFieldsModels.clear();
    });
    for(SectionModel section in form.sections){
      for(FieldModel fields in section.fields){
        listFieldsModelsCopia.add(fields);
      }
    }

      listFieldsModels = listFieldsModelsCopia;

    return true;
  }

  ListBuider_ListView(BuildContext context){
    return  ListView.builder(
        itemCount: listFieldsModels.length,
        itemBuilder: (BuildContext context, index){
          return widgetCrate(listFieldsModels[index],index,context);
        }
    );
  }

  void saveData(String dataController, String id) {
    var value = dataController;
    dataInfo.putIfAbsent(id ,()=> value);
    dataInfo[id] = value;
  }

  widgetCrate(FieldModel field, int index,BuildContext context){

    if(field.fieldType == 'TextArea' ||  field.fieldType == 'Textarea'||  field.fieldType == "TextArea") {
      //TEXTAREA
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
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
            enabled: false,
            controller: TextEditingController(text: (dataInfo[field.id.toString()])),
            onChanged: (value){
              //saveData(value,listFieldsModels[index].id.toString());
            },
            maxLines: 4,
            //controller: nameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: listFieldsModels[index].name,
            ),
          ),
        ),
      );
    }
    if(field.fieldType == 'Photo'){
      Uint8List img;
      String b64;

      String ruta = '';
      try{
        ruta = dataInfo[field.id.toString()];
        if(ruta.isNotEmpty){
          ruta = ruta.substring(21);
        }
      }catch(e){}

      return  Container(
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width* 0.5,
              child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: Card(
                          color: Colors.white,
                          child: SizedBox(height: MediaQuery.of(context).size.height * 0.5,width: 300,
                            child:  dataInfo[field.id.toString()] != null ?  Image(image: imageFromBase64String(ruta).image,)
                                :Center(child: Text('Sin Asignar',style: TextStyle( color: PrimaryColor),),)),)),
                  )),
            ),
          ],
        ),
      );
    }

    if(listFieldsModels[index].fieldType == 'Image'){
      return Row(
        children: <Widget>[

          Container(
            child:Center(
              child: listFieldsModels[index].name.length >20 ?  new Text(listFieldsModels[index].name.substring(0,11),style: TextStyle(
                  color: PrimaryColor),
              ): Text(listFieldsModels[index].name,style: TextStyle(color: PrimaryColor),),
            ),
          ),
          Spacer(),
          Column(
            children: <Widget>[
              Image.network(listFieldsModels[index].fieldDefaultValue,height: MediaQuery.of(context).size.height*0.25,),
            ],

          ),
        ],
      );
    }

    if(field.fieldType == 'Text'){
      //TEXT
      return  Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
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
            enabled: false,
            onChanged: (value){
              //saveData(value,listFieldsModels[index].id.toString());
            },
            maxLines: 1,
            controller: TextEditingController(text: (dataInfo[field.id.toString()])),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: field.name,
            ),
          ),
        ),
      );
    }
    if(field.fieldType == 'Number'){
      return  Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width:  40,
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
            enabled: false,
            controller: TextEditingController(text:'${dataInfo[field.id.toString()]}'),
            onChanged: (value){
              //saveData(value,index.toString());
            },
            keyboardType: TextInputType.number,
            maxLines: 1,
            // controller: nameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: field.name,
            ),
          ),
        ),
      );
    }
    if(field.fieldType == 'Label'){
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(field.name,style: TextStyle(
          fontSize: 20,
        ),
        ),
      );

    }
    if(field.fieldType == 'Time'){
      TimeOfDay _time = new TimeOfDay.now();
      return new Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 1,left: 16),
                    child: Text(field.name),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RaisedButton(
              child: dataInfo[field.id.toString()] != null ? Text('${dataInfo[field.id.toString()]}') : Text('Sin Asignar'),
              onPressed: (){
                //saveData(_time.format(context).toString(), field.id.toString()) ;
              },

            ),
          ),
        ],
      );
    }
    if(field.fieldType == 'Date'){
      return Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 1,left: 16),
                    child: Text(field.name),
                  ),
                ],
              ),

            ],

          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RaisedButton(
              child: dataInfo[field.id.toString()] != null ? Text('${_date.toString().substring(0,10)}') : Text('Sin Asignar'),
              onPressed: (){
//                selectDate(context);
//                saveData(_date.toString().substring(0,10),listFieldsModels[index].id.toString());
              },
            ),
          ),
        ],
      );
    }
    if(field.fieldType == 'Combo'){
      return Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5
                          )
                        ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10,left: 10),
                      child: Text(dataInfo[field.id.toString()],style: TextStyle(fontSize: 20),),
                    ),
                  ),
                ],
              ),

            ],

          ),
        ],
      );
    }

    if(field.fieldType == 'CanvanImage'){
      String b64;

      String ruta = '';
      try{
        ruta = dataInfo[field.id.toString()];
        if(ruta.isNotEmpty){
          ruta = ruta.substring(22);
        }
      }catch(e){}

      return  Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width* 0.5,
            child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      child: Card(color: Colors.white,child: SizedBox(height: 200,width: 300,
                          child:  dataInfo[field.id.toString()] != '' ? Image(image: imageFromBase64String(ruta).image,)
                                                                      : Center(child: Text('Sin asignar',style: TextStyle( color: PrimaryColor),),)),
                          )
                  ),
                )),
          ),
        ],
      );
    }

    if(field.fieldType == 'CanvanSignature'){
      String b64;

      String ruta = '';
      try{
        ruta = dataInfo[field.id.toString()];
        if(ruta.isNotEmpty){
          ruta = ruta.substring(22);
        }
      }catch(e){}

      return  Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width* 0.5,
            child: Center(
                child: Container(
                    child: Card(color: Colors.white,child: SizedBox(height: 200,width: 250,
                        child:  dataInfo[field.id.toString()] != null ? Image(image: imageFromBase64String(ruta).image,height: 200,width:300 ,)
                                                                      :Center(child: Text('Sin Asignar',style: TextStyle( color: PrimaryColor),),)),))),
          ),
        ],
      );
    }

    if(field.fieldType == 'DateTime'){
      String fecha = 'Sin Asignar';
      if(dataInfo[field.id.toString()] != ''){
        fecha = dataInfo[field.id.toString()];
      }
      return Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 1,left: 16),
                    child: Text(field.name),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RaisedButton(
              child: Text(fecha),
              onPressed: (){},
            ),
          ),
        ],
      );
    }

    if(field.fieldType == 'Boolean'){
      //  for(FieldOptionModel v in listFieldsModels[index].fieldOptions){}
      return Container(
        height: 40,
        width: MediaQuery.of(context).size.width * 0.7,
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5
              )
            ]
        ),
        child: Row(
          children: <Widget>[
            Text(field.name),
            dataInfo[field.id.toString()] == '' ? Text('Sin valor') : Text('Verdadero'),
          ],

        ),
      );
    }

    if(field.fieldType == 'ComboSearch')
    {

      return Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: MediaQuery.of(context).size.width*0.5,
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
                controller: new TextEditingController(text: dataInfo[field.id.toString()]),
                enabled: false,
                maxLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: field.name,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Busqueda',
            iconSize: 20,
            onPressed: (){},
          ),

        ],
      );
    }

    if(field.fieldType == 'Button'|| field.fieldType == "button"){
      return Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Container(
                child: new Checkbox(
                    value: true,
                )
            ),
          ),
          Spacer(),
          Container(
            width: MediaQuery.of(context).size.width *0.5,
            height: MediaQuery.of(context).size.height *0.1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(left: 60, top: 10),
                child: Text('${field.name}',style: TextStyle(fontSize: 20),)
              ),
            ),
          ),
        ],
      );
    }

    if(field.fieldType =='Table'){
      return generatedTable(field.fieldOptions, field.id.toString());
    }

    return Text('Sin datos');
  }

  Future<Uint8List> photoAndImage() async{
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TomarImage();
      },
    );
  }
  String base64String(Uint8List data) {
    return base64Encode(data);
  }
  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }
  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }
  Map data = new Map();
  Widget generatedTable(List<FieldOptionModel> listOptions, String id){

    data["table"] = new Map();

    for(FieldOptionModel dataTab in listOptions)
    {
      data["table"][dataTab.name] = new Map();
      data["table"][dataTab.name]["name"] = dataTab.name;
      data["table"][dataTab.name][dataTab.value.toString()] =new TextEditingController();
      data["table"][dataTab.name][dataTab.value.toString()].text = dataTab.value.toString();
    }

    Card card(TextEditingController t){
      return Card(
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: '',
          ),
          controller: t,
        ),
      );
    }

    //COLUMNAS
    Container columna(Map column, bool colorcolum){
      List<Widget> listCard = new List<Widget>();
      for(var key in column.keys){
        if(key != 'name'){
          listCard.add(card(column[key]));
        }
      }

      return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height *(listCard.length*0.1),
        color: colorcolum ? Colors.blue[50] : Colors.grey[200],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height *(listCard.length*0.05),
              child: Card(
                child: Center(
                    child: Text(column["name"])
                ),
              ),
            ),

            Divider(
              height: 20,
              color: Colors.black,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height *(listCard.length*0.1),
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
    Map column = data["table"];
    bool colorcolum = false;
    for(var key in column.keys)
    {
      if(colorcolum){colorcolum = false;}else{colorcolum = true;}
      listColuma.add(columna(column[key],colorcolum));
    }

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.3,
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

}
