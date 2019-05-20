import 'dart:async';
import 'package:rxdart/rxdart.dart';

class Bloc  with Validators{
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  get changeEmail => _emailController.sink.add;
  get changePassword => _passwordController.sink.add;

  Stream<String> get email => _emailController.stream.transform(validateEmail);
  Stream<String> get password => _passwordController.stream.transform(validatePassword);
  Stream<bool> get  submitValid => Observable.combineLatest2(email, password, (e,p) => true);


  submit(){
    final validEmail = _emailController.value;
    final validPassord = _passwordController.value;

  }

  void dispose()
  {
    _emailController.close();
    _passwordController.close();
  }



}
final blocValidators = Bloc();

class Validators{
  final validateEmail = StreamTransformer<String,String>.fromHandlers(
      handleData: (email, sink){
        if(email.contains('@')){
          sink.add(email);
        }
        if(!email.contains('@')){
          sink.addError('No es un correo, falta @');
        }
        if(email.isEmpty){
          sink.addError('Esta vacio');
        }


        /*else{
          sink.addError('No es un correo, falta @');
        }*/
      }

  );

  final validatePassword = StreamTransformer<String,String>.fromHandlers(
      handleData: (password,sink){
        /*if(password.length > 3)
        {
          sink.add(password);
        }else{
          sink.addError('Password debe ser de al menos 4 caracteres');
        }*/
      }
  );
}