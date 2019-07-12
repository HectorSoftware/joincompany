import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  Map<String,String> dataInfoOld = Map<String,String>();
  FormModel formGlobal;
  List<FieldModel> listFieldsModels = List<FieldModel>();
  DateTime _date = new DateTime.now();
  DateTime _dateDT = new DateTime.now();
  TimeOfDay _time = new TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _timeDT = new TimeOfDay.now();
  Image image2;
  List<String> searchList = new List<String>();
  @override
  void initState(){
    _getUserLocation();
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
    return WillPopScope(
      onWillPop: saveTask,
      child: Scaffold(
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
        if(varValue.isNotEmpty){
          varValue = varValue.substring(searchComa(varValue));
        }
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
      dataInfo[list.field.id.toString()] = varValue;
    }

    for(var key in dataInfo.keys){
      dataInfoOld[key] = dataInfo[key];
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

    if(field.fieldType.toLowerCase() == 'textarea') {
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
            controller: TextEditingController(text: (dataInfo[field.id.toString()])),
            onChanged: (value){
              saveData(value,listFieldsModels[index].id.toString());
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
      }catch(e){}
      Uint8List img;
      String b64;
      return  Container(
        child: Row(
          children: <Widget>[
            RaisedButton(
              onPressed: () async{
                img = await photoAndImage();
                if (img != null) {
                  setState(() {
                    b64 = base64String(img);
                    image2 = Image.memory(img);
                    saveData(b64, field.id.toString());
                  });
                }
              },
              child: Text(listFieldsModels[index].name),
              color: PrimaryColor,
            ),
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
            onChanged: (value){
              saveData(value,field.id.toString());
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
            controller: TextEditingController(text:'${dataInfo[field.id.toString()]}'),
            onChanged: (value){
              saveData(value,field.id.toString());
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
      return Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 1,left: 16),
                    child: Text(field.name,style: TextStyle(fontSize: 20),)
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RaisedButton(
              child: dataInfo[field.id.toString()].isNotEmpty ? Text('${dataInfo[field.id.toString()]}') : Text('Sin Asignar'),
              onPressed: ()async {
                await selectDate(context);
                saveData(_date.toString().substring(0,10),field.id.toString());
              },
            ),
          ),
        ],
      );
    }

    if(field.fieldType == 'Time'){
      return new Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 1,left: 16),
                    child: Text(listFieldsModels[index].name,style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RaisedButton(
              child: dataInfo[listFieldsModels[index].id.toString()].isNotEmpty ? Text(dataInfo[listFieldsModels[index].id.toString()]) : Text('Sin Asignar'),
              onPressed: () async {
                await selectTime(context);
                saveData(_time.format(context).toString(), listFieldsModels[index].id.toString()) ;
                setState(() {});
              },
            ),
          ),
        ],
      );
    }

    if(field.fieldType == 'CanvanImage'){
      String ruta = dataInfo[field.id.toString()];
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
      String ruta = dataInfo[field.id.toString()];
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
      return Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 1,left: 16),
                    child: Text(listFieldsModels[index].name,style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RaisedButton(
              child: dataInfo[field.id.toString()] != null  ? Text(dataInfo[field.id.toString()]): Text('Sin Asignar'),
              onPressed: () async {
                await selectDateDateTime(context);
                await selectTimeDatetime(context);
                var dateCo = _dateDT.toString().substring(0,10) + ' ' +_timeDT.format(context).toString();
                saveData(dateCo.toString(),field.id.toString());
                setState(() {});
              },
            ),
          ),
        ],
      );
    }

    if(field.fieldType == 'Combo'){
      List<String> dropdownMenuItems = List<String>();
      for(FieldOptionModel v in listFieldsModels[index].fieldOptions){
        dropdownMenuItems.add(v.name);
      }
      return Container(
        height: MediaQuery.of(context).size.height * 0.06,
        margin: EdgeInsets.all(30.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5
              )
            ]
        ),
        child: new  Padding(
          padding: const EdgeInsets.only(left: 20,right: 10,bottom: 10,top: 10),
          child: Container(
            child: new DropdownButton<String>(
              isExpanded: true,
              underline: Container(),
              isDense: false,
              icon: Icon(Icons.arrow_drop_down),
              elevation: 10,
              value: dataInfo[listFieldsModels[index].id],
              hint:  dataInfo[listFieldsModels[index].id.toString()] != null  ? Text(dataInfo[listFieldsModels[index].id.toString()]): Text(listFieldsModels[index].name),
              onChanged: (newValue) {
                setState(() {
                  //dropdownValue = newValue;
                  dataInfo.putIfAbsent(listFieldsModels[index].id.toString() ,()=> newValue);
                });
              },
              items: dropdownMenuItems.map<DropdownMenuItem<String>>((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      );

    }

    if(field.fieldType == 'Boolean'){
      bool _value1 = false;
      if(dataInfo[field.id.toString()] == 'true'){
        _value1 = true;
      }
      saveData(_value1.toString(),listFieldsModels[index].id.toString());
      return Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Container(
                child: new Checkbox(
                    value: _value1,
                    onChanged: (value){
                      setState(() {
                        _value1 = value;
                      });
                      saveData(value.toString(),listFieldsModels[index].id.toString());
                    }
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
                child: Text('${listFieldsModels[index].name}',style: TextStyle(fontSize: 20),),
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

    if(listFieldsModels[index].fieldType == 'Button'){
      return Container(
          margin: EdgeInsets.only(top: 30,bottom: 30),
          width: MediaQuery.of(context).size.width*0.5,
          child:Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: (){
                  saveData( '${_initialPosition.latitude} , ${_initialPosition.longitude}' ,listFieldsModels[index].id.toString());
                  setState(() {});
                },
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

      if(!seachKeyInData('ComboSearch')){
        data['ComboSearch'] = TextEditingController(text: dataInfo[field.id.toString()]);
      }
     return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width*0.5,
                height: MediaQuery.of(context).size.height * 0.06,
                margin: EdgeInsets.only(top: 30,bottom: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(10)
                  ),
                  color: Colors.white,

                ),
                child: TextField(
                  controller: data['ComboSearch'],
                  onChanged: (value){
                    searchList.clear();
                    setState(() {});

                    if(listFieldsModels[index].fieldOptions != null){
                      for(FieldOptionModel values in listFieldsModels[index].fieldOptions){
                        if(values.name.toLowerCase().contains(value.toLowerCase()) && value.isNotEmpty){
                          searchList.add(values.name);
                          setState(() {});
                        }
                      }
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: listFieldsModels[index].name,
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 30,bottom: 1),
                  child: Icon(Icons.search)
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: searchList.length * 60.0,
            child: searchList.isNotEmpty ? ListView.builder(
              itemCount: searchList.length,
              itemBuilder: (BuildContext context, int inde){
                return Card(
                  child: ListTile(
                    title: Text(searchList[inde],style: TextStyle(fontSize: 15),),
                    onTap: (){
                      data['ComboSearch'].text = searchList[inde];
                      searchList.clear();
                      saveData(data['ComboSearch'].text,listFieldsModels[index].id.toString());
                      setState(() {});
                    },
                  ),
                );
              },
            ):Container(),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
     mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Tabla Sin datos'),
      ],
    );
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

  String savedDataTablet(){
    String dat="";
    var keys = data.keys;
    if(!keys.contains("table")){
      return dat;
    }else{
      for(String k in  data["table"].keys){
        for(String Sk in data["table"][k].keys){
          if(data["table"][k][Sk] is TextEditingController){
            String value = data["table"][k][Sk].text != "" ? data["table"][k][Sk].text : " ";
            dat = dat + "$Sk:$value;";
          }
        }
      }
    }
    return dat;
  }

  Widget generatedTable(List<FieldOptionModel> listOptions, String id){
    initDataTable(listOptions);

    saveData(savedDataTablet(),id);

    Card card(TextEditingController t){
      return Card(
        child: TextField(
          onChanged: (value){
            saveData(savedDataTablet(),id);
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

  Future<Null> selectDate(BuildContext context )async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020)
    );
    if (picked != null && picked != _date){
      setState(() {
        _date = picked;
      });
    }
  }

  Future<Null> selectTime(BuildContext context )async{
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time){
      setState(() {
        _time = picked;
      });
    }
    setState(() {});
  }

  Future<Null> selectTimeDatetime(BuildContext context )async{
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _timeDT,
    );
    if (picked != null && picked != _timeDT){
      _timeDT = picked;
    }
    setState(() {});
  }

  Future<Null> selectDateDateTime(BuildContext context )async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dateDT,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020)
    );
    if (picked != null && picked != _dateDT){
      setState(() {
        _dateDT = picked;
      });
    }
  }

  static LatLng _initialPosition;
  Future _getUserLocation() async{
    try{
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    }catch(e){}
  }

  bool seachKeyInData(String key){
    for(var k in data.keys){
      if(k.toLowerCase() == key.toLowerCase()){
        return true;
      }
    }
    return false;
  }

  Future<bool> saveTask() async{
    var res = await _asyncConfirmDialog();

    if(res != null){
      if(!res){
        res = await updateTaskNew();
      }
    }

    return res == null ? false : res;
  }

  // ignore: missing_return
  Future<bool> updateTaskNew() async {
    taskOne.customValuesMap = dataInfo;
    taskOne.customValues = null;
    setState(() {});
    return await saveTaskApi();
  }

  Future<bool> saveTaskApi() async{
    var createTaskResponse = await updateTask(taskOne.id.toString(), taskOne, customer, token);
    if(createTaskResponse.statusCode == 200){
      return true;
    }
    return false;
  }

  Future<bool> _asyncConfirmDialog() async {
    if(taskOne != null){
      bool change = false;
      dataInfo.forEach((key,value) {
        if(dataInfoOld[key] != value){
          change = true;
        }
      });
      if(change){
        return showDialog<bool>(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('¿Guardar?'),
              content: const Text(
                  '¿Desea guardar estos datos?.'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('SALIR'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                FlatButton(
                  child: const Text('ACEPTAR'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                )
              ],
            );
          },
        );
      }
      return true;
    }
  }
}
