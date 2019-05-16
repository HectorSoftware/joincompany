import 'dart:async';

class TypeTaskBloc{


  final  _taskTypeFormController   = StreamController<String>();

  TypeTaskBloc(context);

  Stream<String> get outTaskType => _taskTypeFormController.stream;
  Sink<String> get inTaskType => _taskTypeFormController.sink;


  formTypeTask(String string){
    inTaskType.add(string);
  return string;
  }



  @override
  void dispose() {
    _taskTypeFormController.close();
  }


}
