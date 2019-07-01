
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/blocs/blocBusiness.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'formBusiness.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class BusinessList extends StatefulWidget {
  bool vista;
  BusinessList(bool vista){
    this.vista = vista;
  }
  @override
  _BusinessListState createState() => _BusinessListState();
}

class _BusinessListState extends State<BusinessList> {
  ListWidgets ls = ListWidgets();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Negocios');
  String textFilter='';
  String stage;
  BusinessesModel businessGlobal = BusinessesModel();

  List<BusinessModel> _listbusisnessOrdenada = new List<BusinessModel>();
  List<BusinessModel> _listPresentacion = new List<BusinessModel>();
  List<BusinessModel> _listEnvioppta = new List<BusinessModel>();
  List<BusinessModel> _listGanado = new List<BusinessModel>();
  List<BusinessModel> _listPerdido = new List<BusinessModel>();
  List<BusinessModel> _listPrimerContacto = new List<BusinessModel>();

  bool getData = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose(){
    super.dispose();
  }

  final TextEditingController _filter = new TextEditingController();

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Buscar'
          ),
          onChanged: (value){
            setState(() {
              textFilter = value.toString();
            });
          },
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Negocios');
        setState(() {
          textFilter='';
        });
        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var padding = 16.0;
    double por = 0.1;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      por = 0.07;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed:(){
              if(!widget.vista){
                Navigator.pushReplacementNamed(context, '/vistap');
              }else{
                Navigator.of(context).pop();
              }
            }
        ),
        title: _appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Eliminar Tarea', 30),

        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child:listViewCustomers(por,padding),

          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed:() {
            Navigator.pushReplacementNamed(context, '/FormBusiness');
          }
      ),
    );


  }

  Widget listViewCustomers(double por, padding) {
    stage = '';
    BusinessBloc _bloc = new BusinessBloc();
    return StreamBuilder<List<BusinessModel>>(
        stream: _bloc.outBusiness,
        initialData: <BusinessModel>[],
        builder: (context, snapshot) {
          if(snapshot != null){
            if (snapshot.data.isNotEmpty) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    var direction = snapshot.data[index].customer != null ? snapshot.data[index].customer : "";
                    var name = snapshot.data[index].name != null ? snapshot.data[index].stage:"";
                    if(snapshot.data.length == 0){
                      return Center(
                        child: Text('No hay Negocios Registrados'),
                      );
                    }
                    if(textFilter == ''){
                      if(stage == snapshot.data[index].stage){
                        stage = snapshot.data[index].stage;

                      return Card(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * por,
                              color: PrimaryColor,
                              child:snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                  fontSize: 16, color: Colors.white)): Text('Sin presentación', style: TextStyle(
                                  fontSize: 16, color: Colors.white)),
                            ),
                            Card(
                              child: ListTile(
                                title: Text(snapshot.data[index].name.toString() + '  -  ' + snapshot.data[index].customer),
                                subtitle: snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                    color: Colors.black)): Text('', style: TextStyle(
                                    color: Colors.black)),
                                trailing:snapshot.data[index].date != null ?Text(snapshot.data[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                                onTap: (){
                                  if(!widget.vista){
                                    return showDialog(
                                      context: context,
                                      barrierDismissible: false, // user must tap button for close dialog!
                                      builder: (BuildContext context) {
                                        return FormBusiness(dataBusiness: snapshot.data[index],edit: true,);
                                      },
                                    );
                                  }else{
                                    Navigator.of(context).pop(snapshot.data[index]);
                                  }
                                },
                              ),
                            ),

                          ],
                        ),
                      );
                    }else{
                        return Card(
                        child: ListTile(
                          title: Text(snapshot.data[index].name.toString() + '  -  ' + snapshot.data[index].customer),
                          subtitle: snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                              color: Colors.black)): Text('', style: TextStyle(
                              color: Colors.black)),
                          trailing:snapshot.data[index].date != null ?Text(snapshot.data[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                          onTap: (){
                            if(!widget.vista){
                              return showDialog(
                                context: context,
                                barrierDismissible: false, // user must tap button for close dialog!
                                builder: (BuildContext context) {
                                  return FormBusiness(dataBusiness: snapshot.data[index],edit: true,);
                                },
                              );
                            }else{
                              Navigator.of(context).pop(snapshot.data[index]);
                            }
                          },
                        ),
                      );

                      }
                    }else if(ls.createState().checkSearchInText(name, textFilter)||ls.createState().checkSearchInText(direction, textFilter)) {
                      var direction = snapshot.data[index].stage != null ? snapshot.data[index].stage : "";
                      var name = snapshot.data[index].customer != null ? snapshot.data[index].customer:"";
                      return Card(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * por,
                              color: PrimaryColor,
                              child:snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                  fontSize: 16, color: Colors.white)): Text('Sin presentación', style: TextStyle(
                                  fontSize: 16, color: Colors.white)),
                            ),
                            Card(
                              child: ListTile(
                                title: Text(snapshot.data[index].name.toString() + '  -  ' + snapshot.data[index].customer),
                                subtitle: snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                    color: Colors.black)): Text('', style: TextStyle(
                                    color: Colors.black)),
                                trailing:snapshot.data[index].date != null ?Text(snapshot.data[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                                onTap: (){
                                  if(!widget.vista){
                                    return showDialog(
                                      context: context,
                                      barrierDismissible: false, // user must tap button for close dialog!
                                      builder: (BuildContext context) {
                                        return FormBusiness(dataBusiness: snapshot.data[index],edit: true,);
                                      },
                                    );
                                  }else{
                                    Navigator.of(context).pop(snapshot.data[index]);
                                  }
                                },
                              ),
                            ),

                          ],
                        ),
                      );
                    }else{
                      return Container();
                    }

                  }

              );
            }else{
              if(snapshot.connectionState == ConnectionState.waiting){
                return new Center(
                  child: CircularProgressIndicator(),
                );
              }else{
                return new Container(
                  child: Center(
                    child: Text("No hay Negocios Registrados"),
                  ),
                );
              }
            }
          }else{
            return new Container(
              child: Center(
                child: Text("ha ocurrido un error"),
              ),
            );
          }

        }

    );

  }

}



/*Widget listViewCustomers(double por, padding) {
    BusinessBloc _bloc = new BusinessBloc();
    BusinessModel aux = BusinessModel(stage: '');
    int a = 0 ;
    int b = 0 ;
    int c = 0 ;
    int d = 0 ;
    int e = 0 ;
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscriptionList = _bloc.outBusiness
          .listen((onDataList) =>
          setState(() {
            //if(PageTasks == 1){
            //}
            print(_listbusisnessOrdenada.length);
            if (onDataList.length != 0){

              for(BusinessModel v in onDataList){

                if(v.stage == 'Envío ppta' && a == 0 ){
                  a++;
                  _listbusisnessOrdenada.add(aux);

                  while(v.stage == 'Envío ppta'){
                    _listbusisnessOrdenada.add(v);
                  }
                }
                if(v.stage == 'Ganado' && b == 0 ){
                  b++;
                  _listbusisnessOrdenada.add(aux);

                  while(v.stage == 'Ganado'){
                    _listbusisnessOrdenada.add(v);
                  }
                }
                if(v.stage == 'Perdido' && c == 0 ){
                  c++;
                  _listbusisnessOrdenada.add(aux);

                  while(v.stage == 'Perdido'){
                    _listbusisnessOrdenada.add(v);
                  }
                }
                if(v.stage == 'Primer contacto' && d == 0 ){
                  d++;
                  _listbusisnessOrdenada.add(aux);

                  while(v.stage == 'Primer contacto'){
                    _listbusisnessOrdenada.add(v);
                  }
                }
                if(v.stage == 'Presentación' && e == 0 ){
                  e++;
                  _listbusisnessOrdenada.add(aux);

                  while(v.stage == 'Presentación'){
                    _listbusisnessOrdenada.add(v);
                  }
                }

              }
            print(_listbusisnessOrdenada.length);
            } else {
              return Text(_listbusisnessOrdenada.length.toString());

            }

            return ListView.builder(
                itemCount: _listbusisnessOrdenada.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Icon(Icons.poll),
                    title: Text('${_listbusisnessOrdenada[index].stage.toString()}'),
                    onTap: () async {
                    },
                  );



                }

            );
          }));

  }


}*/






/*ListView.builder(
          itemCount:listBusiness.length,
          itemBuilder: (BuildContext context, index){
            var customer = listBusiness[index].customer != null ? listBusiness[index].customer : "";
            var name = listBusiness[index].name != null ? listBusiness[index].name:"";
            if(listBusiness.length == 0){
              return Center(
                child: Text('No hay Negocios Registrados'),
              );
            }
           if(textFilter == ''){
             return Card(
               child: Column(
                 children: <Widget>[
                   Container(
                     padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                     width: MediaQuery.of(context).size.width,
                     height: MediaQuery.of(context).size.height * por,
                     color: PrimaryColor,
                     child:listBusiness[index].stage != null? Text(listBusiness[index].stage.toString(), style: TextStyle(
                         fontSize: 16, color: Colors.white)): Text('Sin presentación', style: TextStyle(
                         fontSize: 16, color: Colors.white)),
                   ),
                   Card(
                     child: ListTile(
                       title: Text(listBusiness[index].name.toString()),
                       subtitle: listBusiness[index].stage != null? Text(listBusiness[index].stage.toString(), style: TextStyle(
                           color: Colors.black)): Text('', style: TextStyle(
                           color: Colors.black)),
                       trailing:listBusiness[index].date != null ?Text(listBusiness[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                       onTap: (){
                         if(!widget.vista){
                           return showDialog(
                             context: context,
                             barrierDismissible: false, // user must tap button for close dialog!
                             builder: (BuildContext context) {
                               return FormBusiness(dataBusiness: listBusiness[index],edit: true,);
                             },
                           );
                         }else{
                           Navigator.of(context).pop(listBusiness[index]);
                         }
                       },
                     ),
                   ),
                   Card(
                     child:  ListTile(
                       title: Text(listBusiness[index].customer),
                       subtitle:listBusiness[index].stage != null? Text(listBusiness[index].amount.toString(), style: TextStyle(
                           color: Colors.black)): Text('', style: TextStyle(
                           color: Colors.black)),
                       trailing: listBusiness[index].date != null ?Text(listBusiness[index].updatedAt.toString().substring(0,10)): Text('Sin Fecha asignada'),
                     ),
                   ),
                   Container(
                     padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                     width: MediaQuery.of(context).size.width,
                     height: MediaQuery.of(context).size.height * por,
                     color: PrimaryColor,
                     child: Text("Presentacion", style: TextStyle(
                         fontSize: 16, color: Colors.white)),
                   ),
                   Card(
                     child: ListTile(
                       title:  Text(listBusiness[index].customer),
                       subtitle: Text(""),
                       trailing:listBusiness[index].date != null ?Text(listBusiness[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                     ),
                   ),
                 ],
               ),
             );
           }else if(ls.createState().checkSearchInText(name, textFilter)||ls.createState().checkSearchInText(customer, textFilter)){
           }
          }
      ):Center(
        child: CircularProgressIndicator(
        ),
          return Card(
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * por,
                                color: PrimaryColor,
                                child:snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                    fontSize: 16, color: Colors.white)): Text('Sin presentación', style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                              ),
                              Card(
                                child: ListTile(
                                  title: Text(snapshot.data[index].name.toString() + '  -  ' + snapshot.data[index].customer),
                                  subtitle: snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                      color: Colors.black)): Text('', style: TextStyle(
                                      color: Colors.black)),
                                  trailing:snapshot.data[index].date != null ?Text(snapshot.data[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                                  onTap: (){
                                    if(!widget.vista){
                                      return showDialog(
                                        context: context,
                                        barrierDismissible: false, // user must tap button for close dialog!
                                        builder: (BuildContext context) {
                                          return FormBusiness(dataBusiness: snapshot.data[index],edit: true,);
                                        },
                                      );
                                    }else{
                                      Navigator.of(context).pop(snapshot.data[index]);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
      ),*/