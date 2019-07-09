import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/ImageAndPhoto.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/UserModel.dart';
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

  UserModel userToken ;
  String token,customer, user;
  int responsibleId;
  TaskModel taskOne;
  DateTime _dateTask = new DateTime.now();
  Map<String,String> dataInfo = Map<String,String>();
  FormModel formGlobal;
  List<FieldModel> listFieldsModels = List<FieldModel>();
  DateTime _date = new DateTime.now();
  Image image2;
  @override
  void initState(){

    _dateTask = DateTime.parse(fixStringDateIfBroken(widget.taskmodelres.planningDate));
    listWithTask();
    super.initState();
  }

  @override
  void dispose(){
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
                            listBuiderListView(context)
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
    taskOne = responseTaskone.body;


    //SOLICITAR FORMULARIOS
    var getFormResponse = await getForm(widget.taskmodelres.formId.toString(), customer, token);
    FormModel form = getFormResponse.body;
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
    userToken = await DatabaseProvider.db.RetrieveLastLoggedUser();
    setState(() {
      token = userToken.rememberToken;
      customer = userToken.company;
      user = userToken.name;
      responsibleId = userToken.id;
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

  listBuiderListView(BuildContext context){
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
      String ruta = '';
      try{
        ruta = dataInfo[field.id.toString()];
        if(ruta.isNotEmpty){
          ruta = ruta.substring(searchComa(ruta));
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
                            child:  dataInfo[field.id.toString()] != null ? Image(image: imageFromBase64String(ruta).image,)
                                                                          : Center(child: Text('Sin Asignar',style: TextStyle( color: PrimaryColor),),)),)),
                  )),
            ),
          ],
        ),
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
      return Container(
        padding: EdgeInsets.only(top: 10),
        height: MediaQuery.of(context).size.height * 0.08,
        child: Text(field.name,style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
      );

    }
    if(field.fieldType == 'Date'){
      DateTime fecha = DateTime.parse(_date.toString().substring(0,10));

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Container(),),
            Expanded(child: Text(field.name,style: TextStyle(fontSize: 20),)),
            Expanded(child: dataInfo[field.id.toString()] != null ? Text('${fecha.day.toString() + '-' + fecha.month.toString() + '-' + fecha.year.toString()}',style: TextStyle(fontSize: 20),)
                                                                  : Text('Sin Asignar',style: TextStyle(fontSize: 20),),),
            Expanded(child: Container(),),
          ],
        ),
      );
    }
    if(field.fieldType == 'Time'){
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: new Row(
          children: <Widget>[
            Expanded(child: Container(),),
            Expanded(child: Text(field.name,style: TextStyle(fontSize: 20),)),
            Expanded(child: dataInfo[field.id.toString()] != null ? Text('${dataInfo[field.id.toString()]}',style: TextStyle(fontSize: 20),)
                                                                  : Text('Sin Asignar',style: TextStyle(fontSize: 20),),),
            Expanded(child: Container(),),
          ],
        ),
      );
    }

    if(field.fieldType == 'CanvanImage'){
      String ruta = '';
      try{
        ruta = dataInfo[field.id.toString()];
        if(ruta.isNotEmpty){
          ruta = ruta.substring(searchComa(ruta));
        }
      }catch(e){}

      return  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width* 0.5,
            child: Container(
                child: Card(color: Colors.white,child: SizedBox(height: 200,width: 300,
                    child:  dataInfo[field.id.toString()] != '' ? Image(image: imageFromBase64String(ruta).image,)
                                                                : Center(child: Text('Sin asignar',style: TextStyle( color: PrimaryColor),),)),
                    )
            ),
          ),
        ],
      );
    }

    if(field.fieldType == 'CanvanSignature'){
      String ruta = '';
      try{
        ruta = dataInfo[field.id.toString()];
        if(ruta.isNotEmpty){
          ruta = ruta.substring(searchComa(ruta));
        }
      }catch(e){}

      return  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width* 0.5,
            child: Center(
                child: Container(
                    child: Card(
                      color: Colors.white,
                      child: SizedBox(height: 200,width: 250,
                                      child: ruta != '' ? Image(image: imageFromBase64String(ruta).image,height: 200,width:300 ,)
                                                                                  : Center(child: Text('Sin Asignar',style: TextStyle( color: PrimaryColor),),)),))),
          ),
        ],
      );
    }

    if(field.fieldType == 'DateTime'){
      String fecha = 'Sin Asignar';
      if(dataInfo[field.id.toString()] != ''){
        fecha = dataInfo[field.id.toString()];
      }
      return Padding(
        padding: const EdgeInsets.only(top: 20,bottom: 20),
        child: Row(
          children: <Widget>[
            Expanded(child: textDialogstyle(field.name + ' : ' + fecha),),
            //textDialogstyle(fecha),
            /*Expanded(child: Container(),),
            Expanded(child: Text(field.name,style: TextStyle(fontSize: 20),)),
            Expanded(child: Text(fecha,style: TextStyle(fontSize: 20),),),
            Expanded(child: Container(),),*/
          ],
        ),
      );
    }

    if(field.fieldType == 'Combo'){
      //return textDialogstyle(dataInfo[field.id.toString()]);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
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
                      child: dataInfo[field.id.toString()].length != 0 ? Text(field.name.toString() +' : '+ dataInfo[field.id.toString()],style: TextStyle(fontSize: 20),textAlign: TextAlign.center,)
                                                                       : Text('${field.name.toString()} : Sin Asignar',style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                    ),
                  ),
                ],
              ),

            ],

          ),
        ],
      );

    }

    if(field.fieldType == 'Boolean'){
      bool _value1 = false;
      if(dataInfo[field.id.toString()] == 'true'){
        _value1 = true;
      }
      return Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Container(
                child: new Checkbox(
                    value: _value1
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
                child: _value1 == true ? Text('${listFieldsModels[index].name}',style: TextStyle(fontSize: 20),)
                    : Text(''),
              ),

            ),
          ),
        ],
      );
    }


    if(listFieldsModels[index].fieldType == 'Image'){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child:Center(
              child: listFieldsModels[index].name.length >20 ?  new Text(listFieldsModels[index].name.substring(0,11),style: TextStyle(
                  color: PrimaryColor),
              ): Text(listFieldsModels[index].name,style: TextStyle(color: PrimaryColor),),
            ),
          ),
          Column(
            children: <Widget>[
              Image.network(listFieldsModels[index].fieldDefaultValue,height: MediaQuery.of(context).size.height*0.25,),
            ],
          ),
        ],
      );
    }

    if(listFieldsModels[index].fieldType == 'Button')
    {
      //  for(FieldOptionModel v in listFieldsModels[index].fieldOptions){
      //saveData( isSwitched.toString() ,listFieldsModels[index].id.toString());
      return Container(
          margin: EdgeInsets.only(top: 30,bottom: 30),
          width: MediaQuery.of(context).size.width*0.5,
          child:Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: (){},
                child: Text(listFieldsModels[index].name),
              ),
              Container(
                child: dataInfo[listFieldsModels[index].id.toString()] != null  ? Text(dataInfo[listFieldsModels[index].id.toString()]): Text('Sin Asignar'),
                margin: EdgeInsets.only(left: 30),
              )
            ],
          )
      );
    }

    if(field.fieldType == 'ComboSearch'){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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

    if(field.fieldType == 'boolean'){
      return Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Container(
                child: new Checkbox(
                    value:true, onChanged: (bool value) {},
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
                child: Text('${listFieldsModels[index].name}',style: TextStyle(fontSize: 20),)
              ),
            ),
          ),
        ],
      );
    }

    if(field.fieldType =='Table'){

      String value = dataInfo[field.id.toString()];
      FieldOptionModel model = new FieldOptionModel();
      List<FieldOptionModel> listOption = new List<FieldOptionModel>();
      var datos = value.split(';');

      for(String v in datos){
        if(v != '' && v != ' '){
          var values = v.split(':');
          int valueInt = 0;
          try{
            valueInt = int.parse(values[1]);
          }on Exception{}
          listOption.add(new FieldOptionModel(value: valueInt,name: values[0]));
        }
      }
      return generatedTable(listOption, field.id.toString());
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

  bool findKeys(String key){
    for(var k in data.keys){
      if(k == key){
        return true;
      }
    }
    return false;
  }

  bool checkKeyInTable(String key){
    for(String k in data["table"].keys){
      if(k.toLowerCase() == key.toLowerCase()){
        return true;
      }
    }
    return false;
  }

  void initDataTable(List<FieldOptionModel> listOptions){
      data["table"] = new Map();
      for(FieldOptionModel varV in listOptions)
      {
        varV.name = varV.name.replaceAll("Item", "");
        var split = varV.name.split('x');
        if(!checkKeyInTable(split[1])){
          data["table"][split[1]] = new Map();
        }

        data["table"][split[1]]["name"] = split[1];
        data["table"][split[1]][varV.name] = new TextEditingController();
        data["table"][split[1]][varV.name].text = varV.value.toString();
      }
  }

  Widget generatedTable(List<FieldOptionModel> listOptions, String id){
    initDataTable(listOptions);
    Card card(TextEditingController t){
      return Card(
        child: TextField(
          enabled: false,
          onChanged: (value){
          },
          controller: t,
          decoration: InputDecoration(
            hintText: '',
          ),
        ),
      );
    }

    //COLUMNAS
    Container columna(Map column, bool colorcolum){
      List<Widget> listCard = new List<Widget>();
      for(String key in column.keys){
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
              width: MediaQuery.of(context).size.width * 0.6,
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

  Future checkDialog(String mensaje){
    return showDialog(
        context: context,
        barrierDismissible: true, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(mensaje)
          );
        }
    );
  }

  Row textDialogstyle(String mensaje){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
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
                    child: Text(mensaje,style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                  ),
                ),
              ],
            ),

          ],

        ),
      ],
    );
  }

  int searchComa(String texto){
    int pos = 23;
    for(int x = 0 ; x < texto.length ; x++){
      if(texto[x] == ','){
        pos = x + 1;
      }
    }
    return pos;
  }

}
