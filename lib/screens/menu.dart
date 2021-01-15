import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tictacapp/models/game.dart';
import 'package:tictacapp/models/user.dart';
import 'package:tictacapp/utils/constants.dart';
import 'package:tictacapp/utils/logoText.dart';
import 'package:tictacapp/utils/main_back.dart';
import 'package:tictacapp/utils/button.dart';
import 'package:tictacapp/blocs/game_bloc.dart';
import 'package:tictacapp/blocs/user_bloc.dart';
import 'package:tictacapp/blocs/bloc_provider.dart';
import 'package:tictacapp/screens/gameboard.dart';
import 'package:tictacapp/screens/login.dart';


class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  UserBloc _userBloc;
  GameBloc _gameBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _gameBloc = BlocProvider.of<GameBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    //precacheImage(AssetImage("assets/chat.png"), context);
    return MaterialApp(
        home: new Background(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: size.height * 0.05),
                      LogoText(),

                      SizedBox(height: size.height * 0.05),
                      Image.asset(
                        "assets/chat.png",
                        height: size.height * 0.35,
                      ),
                      SizedBox(height: size.height * 0.01),

                      SizedBox(height: size.height * 0.01),
                      Button(
                        text: 'PLAY WITH COMPUTER',
                        press: () {
                          _gameBloc.startSingleDeviceGame(GameType.computer);
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (index) => GameBoard()//GameBoard()
                          ));
                        },
                      ),
                      Button(
                        text: 'PLAY WITH FRIEND',
                        color: primaryLightColor,
                        textColor: Colors.black,
                        press: () {
                          _gameBloc.startSingleDeviceGame(GameType.multi_device);
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (index) => GameBoard(
                          )
                          ));
                        },
                      ),
                      Button(
                        text: 'PLAY WITH USERS',
                        press: () {

                        },
                      ),
                      Button(
                        text: 'HIGH SCORE',
                        color: primaryLightColor,
                        textColor: Colors.black,
                        press: () {},
                      ),
                      StreamBuilder(
                        initialData: null,
                        builder: (context, currentUserSnapshot) {
                          if (currentUserSnapshot.hasData &&
                              currentUserSnapshot.data != null) {
                            return FlatButton(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                    fontSize: 18.0, color: primaryColor),
                              ),
                              onPressed: () {},
                            );
                          } else {
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Play with Others?',
                                    style:
                                    TextStyle(fontSize: 18.0,
                                        color: Colors.grey[850]),
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                          fontSize: 18.0, color: primaryColor),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (index) => LoginScreen()//AuthPage(false)
                                          ));
                                    },
                                  )
                                ]);
                          }
                        },
                      ),
                    ]))));
  }
}