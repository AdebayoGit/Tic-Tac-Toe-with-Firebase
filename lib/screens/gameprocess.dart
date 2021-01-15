import 'package:flutter/material.dart';
import 'package:tictacapp/blocs/bloc_provider.dart';
import 'package:tictacapp/blocs/game_bloc.dart';
import 'package:tictacapp/screens/gameboard.dart';

class GameProcessPage extends StatefulWidget {
  GameProcessPage({Key key}) : super(key: key);

  @override
  _GameProcessPageState createState() => new _GameProcessPageState();
}

class _GameProcessPageState extends State<GameProcessPage> {

  GameBloc _gameBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameBloc = BlocProvider.of<GameBloc>(context);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          
        ),
      ),
    );
  }
}