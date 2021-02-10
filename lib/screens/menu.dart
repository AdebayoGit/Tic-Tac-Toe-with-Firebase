import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tictacapp/models/game.dart';
import 'package:tictacapp/models/User.dart';
import 'package:tictacapp/screens/users_board.dart';
import 'package:tictacapp/utils/constants.dart';
import 'package:tictacapp/utils/logoText.dart';
import 'package:tictacapp/utils/main_back.dart';
import 'package:tictacapp/utils/button.dart';
import 'package:tictacapp/blocs/game_bloc.dart';
import 'package:tictacapp/blocs/user_bloc.dart';
import 'package:tictacapp/blocs/bloc_provider.dart';
import 'package:tictacapp/screens/gameboard.dart';
import 'package:tictacapp/screens/gameprocess.dart';
import 'package:tictacapp/screens/authpage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'highscore.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  UserBloc _userBloc;
  GameBloc _gameBloc;
  FirebaseMessaging _messaging = new FirebaseMessaging();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _gameBloc = BlocProvider.of<GameBloc>(context);
  }

  @override
  void initState() {
    super.initState();

    // ignore: missing_return
    _messaging.configure(onLaunch: (Map<String, dynamic> message) {
      print('ON LAUNCH ----------------------------');
      print(message);
      // ignore: missing_return
    }, onMessage: (Map<String, dynamic> message) {
      String notificationType = message['data']['notificationType'];

      switch (notificationType) {
        case 'challenge':
          User challenger = User(
              id: message['data']['senderId'],
              name: message['data']['senderName'],
              fcmToken: message['data']['senderFcmToken']);
          _showAcceptanceDialog(challenger);
          break;
        case 'started':
          _gameBloc.startServerGame(
              message['data']['player1Id'], message['data']['player2Id']);
          break;
        case 'replayGame':
          _gameBloc.changeGameOver(false);
          break;
        case 'rejected':
          _showGameRejectedDialog(message);
          break;
        case 'gameEnd':
          _gameBloc.clearProcessDetails();
          _showGameEndDialog(message);
          break;
        default:
          print('message');
          break;
      }
      // ignore: missing_return
    }, onResume: (Map<String, dynamic> message) {
      // _showAcceptanceDialog(message);
      print('ON RESUME ----------------------------');
      print(message);
      String notificationType = message['notificationType'];
      switch (notificationType) {
        case 'challenge':
          User challenger = User(
              id: message['senderId'],
              name: message['senderName'],
              fcmToken: message['senderFcmToken']);
          _showAcceptanceDialog(challenger);
          break;
        case 'started':
          _gameBloc.startServerGame(message['player1Id'], message['player2Id']);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => GameProcessPage()));
          break;
        case 'gameEnd':
          _gameBloc.clearProcessDetails();
          break;
      }
    });

    _messaging.getToken().then((token) {
      print('------------------');
      print(token);
      _userBloc.changeFcmToken(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
          StreamBuilder(
            initialData: null,
            stream: _userBloc.currentUser,
            builder: (context, currentUserSnapshot) {
              if (!currentUserSnapshot.hasData) {
                return Container();
              }
              User currentUser = currentUserSnapshot.data;
              return (currentUser != null)
                  ? Text('Hi ' + currentUser.name)
                  : Container();
            },
          ),
          SizedBox(height: size.height * 0.01),
          Button(
            text: 'PLAY WITH COMPUTER',
            press: () {
              _gameBloc.startSingleDeviceGame(GameType.computer);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (index) => GameBoard() //GameBoard()
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
                  .push(MaterialPageRoute(builder: (index) => GameBoard()));
            },
          ),
          Button(
            text: 'PLAY WITH USERS',
            press: () {
              _userBloc.getUsers();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (index) => UsersBoard()));
            },
          ),
          Button(
            text: 'HIGH SCORE',
            color: primaryLightColor,
            textColor: Colors.black,
            press: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (index) => HighScoreBoard()));
            },
          ),
          StreamBuilder(
            initialData: null,
            stream: _userBloc.currentUser,
            builder: (context, currentUserSnapshot) {
              if (currentUserSnapshot.hasData &&
                  currentUserSnapshot.data != null) {
                return FlatButton(
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 18.0, color: primaryColor),
                  ),
                  onPressed: () {
                    _userBloc.logoutUser();
                  },
                );
              } else {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Play with Others?',
                        style:
                            TextStyle(fontSize: 18.0, color: Colors.grey[850]),
                      ),
                      FlatButton(
                        child: Text(
                          'Sign In',
                          style: TextStyle(fontSize: 18.0, color: primaryColor),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (index) => AuthPage()));
                        },
                      )
                    ]);
              }
            },
          ),
        ]))));
  }

  _showGameEndDialog(Map<String, dynamic> message) async {
    Future.delayed(Duration.zero, () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Game Ended!'),
          content: Text(message['notification']['body']), // get from server

          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Menu()));
              },
            ),
          ],
        ),
      );
    });
  }

  _showGameRejectedDialog(Map<String, dynamic> message) async {
    Future.delayed(Duration.zero, () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Game Rejected!'),
          content: Text(message['notification']['body']), // get from server

          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Menu()));
              },
            ),
          ],
        ),
      );
    });
  }

  _showAcceptanceDialog(User challenger) async {
    Future.delayed(Duration.zero, () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => StreamBuilder<User>(
          stream: _userBloc.currentUser,
          builder: (context, currentUserSnapshot) {
            return AlertDialog(
              title: Text('Tic Tac Toe Challeenge'),
              content: Text(challenger.name +
                  ' has Challenged you to a game of tic tac toe'),
              actions: <Widget>[
                FlatButton(
                  child: Text('ACCEPT'),
                  onPressed: () async {
                    _gameBloc.handleChallenge(
                        challenger, ChallengeHandleType.accept);
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GameProcessPage()));
                  },
                ),
                FlatButton(
                  child: Text('DECLINE'),
                  onPressed: () {
                    _gameBloc.handleChallenge(
                        challenger, ChallengeHandleType.reject);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          },
        ),
      );
    });
  }
}
