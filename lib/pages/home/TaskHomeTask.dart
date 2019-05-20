
import 'package:flutter/material.dart';
import 'package:joincompany/blocs/blocListTask.dart';
import 'package:joincompany/models/TaskModel.dart';

class taskHomeTask extends StatefulWidget {
  _MytaskPageTaskState createState() => _MytaskPageTaskState();
}

class _MytaskPageTaskState extends State<taskHomeTask> {

  bool MostrarLista = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final mediaQueryData = MediaQuery.of(context);
    double aument = 0.7;
    if (mediaQueryData.orientation == Orientation.portrait) {
      aument = 0.8;
    }

    String fechaHoy = DateTime.now().day.toString()+ ' ' + obtenerMes(DateTime.now().month.toString())+ ' ' +DateTime.now().year.toString();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * aument,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            /*MostrarLista ? ListViewTareas() :
            Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),*/
            ListViewTareas(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: (){
              Navigator.pushReplacementNamed(context, '/formularioTareas');

            }),
      ),
    );
  }
  String DateTask = "2019-05-05 20:00:04Z";
  ListViewTareas(){
    blocListTask bloctasks = new blocListTask();
    return StreamBuilder<List<Task>>(
      stream: bloctasks.outListTaks,
      initialData: <Task>[],
      builder: (context, snapshot){
        if(snapshot.data.isNotEmpty){
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index){

                String texto = snapshot.data[index].createdAt + '  ' + snapshot.data[index].name;
                if((DateTime.parse(DateTask).day != DateTime.parse(snapshot.data[index].createdAt).day)||
                    (DateTime.parse(DateTask).month != DateTime.parse(snapshot.data[index].createdAt).month)||
                    (DateTime.parse(DateTask).year != DateTime.parse(snapshot.data[index].createdAt).year)){
                  DateTask = snapshot.data[index].createdAt;
                  String textoFecha = DateTime.parse(snapshot.data[index].createdAt).day.toString() + ' ' + obtenerMes(DateTime.parse(snapshot.data[index].createdAt).day.toString()) + ' ' + DateTime.parse(snapshot.data[index].createdAt).year.toString();
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.blue,
                          child: Text(textoFecha),
                        ),
                        Text(texto),
                      ],
                    ),
                  );
                }else{
                  return Text(texto);
                }
              }
          );
        }else{
          return new Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

      },
    );
  }

  String obtenerMes(String mes){
    if(mes == '1'){return 'Enero';}
    if(mes == '2'){return 'Febrero';}
    if(mes == '3'){return 'Marzo';}
    if(mes == '4'){return 'Abril';}
    if(mes == '5'){return 'Mayo';}
    if(mes == '6'){return 'Junio';}
    if(mes == '7'){return 'Julio';}
    if(mes == '8'){return 'Agosto';}
    if(mes == '9'){return 'Septiembre';}
    if(mes == '10'){return 'Octubre';}
    if(mes == '11'){return 'Noviembre';}
    if(mes == '12'){return 'Diciembre';}
    return 'Hoy';
  }
}


