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



    return new Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.pushReplacementNamed(context, '/formularioTareas');
    },

      ),
    );
  }
}