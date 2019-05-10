import 'dart:async';
import 'package:joincompany/models/ModelUser.dart';
import 'package:rxdart/rxdart.dart';


class BlocUser{

  final _userController = BehaviorSubject<User>();
  Sink<User> get _inUser => _userController.sink;
  Stream<User> get outUser => _userController.stream;


  @override
  void dispose() {
    _userController.close();

  }

  BlocUser();
}