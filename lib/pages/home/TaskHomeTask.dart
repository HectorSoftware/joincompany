import 'package:flutter/material.dart';
import 'package:joincompany/widgets/formulario_tareas.dart';

class taskHomeTask extends StatefulWidget {
  _MytaskPageTaskState createState() => _MytaskPageTaskState();
}

class _MytaskPageTaskState extends State<taskHomeTask> {

  @override
  Future initState() {
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

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * aument,
      child: Scaffold(
        body: ListViewTareas(),
        floatingActionButton: FloatingActionButton(onPressed: (){
          Navigator.pushReplacementNamed(context, '/formularioTareas');

        }),
      ),
    );
  }

  ListView ListViewTareas(){
    List<String> li = new List<String>();
    li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');
    li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');
    li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');
    li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');
    li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');li.add('Lista Ejemplo');
    return ListView.builder(
      itemCount: li.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(li[index]),
          onTap: (){},
        );
      }
    );
  }
}