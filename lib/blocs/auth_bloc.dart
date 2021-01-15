import 'dart:async';

import 'package:tictacapp/blocs/bloc_provider.dart';
import 'package:tictacapp/models/auth.dart';
import 'package:tictacapp/models/bloc_completer.dart';
import 'package:tictacapp/models/load_status.dart';
import 'package:tictacapp/services/user_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tictacapp/models/User.dart';


class AuthBloc extends BlocBase{

  UserService userService;
  BlocCompleter completer;

  final _currentUserSubject = BehaviorSubject<User>(seedValue: null);
  final _loadStatusSubject = BehaviorSubject<LoadStatus>(seedValue: LoadStatus.loaded);
  final _socialLoginSubject = BehaviorSubject<SocialLoginType>(seedValue: null);
  final _signUpSubject = BehaviorSubject<Map>(seedValue: null);
  final _loginSubject = BehaviorSubject<Map>(seedValue: null);

  Function(SocialLoginType) get loginWithSocial => (socialLoginType) => _socialLoginSubject.sink.add(socialLoginType);
  Function(String , String, String) get signUp => (username, email, password) => _signUpSubject.sink.add({'username': username, 'email': email, 'password': password});
  Function(String , String) get login => (email, password) => _loginSubject.sink.add({'email': email, 'password': password});


  Stream<LoadStatus> get loadStatus => _loadStatusSubject.stream;

  AuthBloc(this.userService, this.completer){

    _loginSubject.stream.listen(_handleLogin);

    _signUpSubject.stream.listen(_handleSignUp);

  }


  _handleLogin(Map loginCredential) async{
    _loadStatusSubject.sink.add(LoadStatus.loading);
    try{
      User user =  await userService.signInWithEmailAndPasword(loginCredential['email'], loginCredential['password']);
      _loadStatusSubject.sink.add(LoadStatus.loaded);
      completer.completed(user);
    }catch(appError){
      _loadStatusSubject.sink.add(LoadStatus.loaded);
      completer.error(appError);
    }
  }

  _handleSignUp(Map signUpCredential) async {
    _loadStatusSubject.sink.add(LoadStatus.loading);

    try{
      User user = await userService.signUpWithEmailAndPassword(signUpCredential['username'], signUpCredential['email'], signUpCredential['password']);
      _loadStatusSubject.sink.add(LoadStatus.loaded);
      completer.completed(user);

    }catch(appError){
      _loadStatusSubject.sink.add(LoadStatus.loaded);
      completer.error(appError);
    }
  }

  @override
  void dispose() {
    _currentUserSubject.close();
    _socialLoginSubject.close();
    _loadStatusSubject.close();
    _signUpSubject.close();
    _loginSubject.close();
  }


}