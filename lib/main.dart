import 'package:flutter/material.dart';
import 'package:tictacapp/screens/menu.dart';
import 'package:tictacapp/blocs/game_bloc.dart';
import 'package:tictacapp/blocs/bloc_provider.dart';
import 'package:tictacapp/blocs/user_bloc.dart';
import 'package:tictacapp/services/game_service.dart';
import 'package:tictacapp/services/user_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    UserService userService = UserService();
    return BlocProvider<UserBloc>(
        bloc: UserBloc(userService: userService),
        child: BlocProvider<GameBloc>(
            bloc: GameBloc(gameService: GameService(), userService: userService),
    child:MaterialApp(
      title: 'Tic Tac Go',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Menu(),
      ))
      );
  }
}

