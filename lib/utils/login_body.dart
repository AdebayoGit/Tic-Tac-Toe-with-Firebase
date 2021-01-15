import 'package:flutter/material.dart';
import 'package:tictacapp/Screens/register.dart';
import 'package:tictacapp/utils/logoText.dart';
import 'package:tictacapp/utils/sign_up_back.dart';
import 'package:tictacapp/utils/button.dart';
import 'package:tictacapp/components/already_have_an_account_acheck.dart';
import 'package:tictacapp/blocs/auth_bloc.dart';
import 'package:tictacapp/blocs/bloc_provider.dart';
import 'package:tictacapp/blocs/user_bloc.dart';
import 'package:tictacapp/screens/menu.dart';
import 'package:tictacapp/models/User.dart';
import 'package:tictacapp/models/load_status.dart';
import 'package:tictacapp/utils/validator.dart';
import 'package:tictacapp/models/bloc_completer.dart';
import 'package:tictacapp/services/user_service.dart';
import 'package:tictacapp/components/text_field_container.dart';
import 'package:tictacapp/utils/constants.dart';

class Body extends StatefulWidget {
  final bool signUp;
  Body(this.signUp, {Key key}) : super(key: key);

  @override
  _BodyState createState() => new _BodyState();
}

class _BodyState extends State<Body> implements BlocCompleter<User> {
  final _formKey = GlobalKey<FormState>();
  Validator _validator;
  BuildContext _context;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AuthBloc _authBloc;
  UserBloc _userBloc;

  bool signUp = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _authBloc = AuthBloc(UserService(), this);
  }

  @override
  void initState() {
    super.initState();

    _validator = Validator();
    signUp = widget.signUp;
  }

  @override
  void dispose() {
    super.dispose();
    _authBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
        child: Builder(
        builder: (context) {
          _context = context;
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LogoText(),
                  SizedBox(height: size.height * 0.03),
                  Image.asset(
                    "assets/login.png",
                    height: size.height * 0.35,
                  ),
                  SizedBox(height: size.height * 0.03),
                  _authTextField(
                      controller: _emailController,
                      hintText: 'Your Email',
                      icon: Icons.mail,
                      validator: _validator.emailValidator),
                  _passTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      validator: _validator.passwordValidator),
                  StreamBuilder(
                    initialData: LoadStatus.loaded,
                    stream: _authBloc.loadStatus,
                    builder: (context, snapshot) {
                      final loadStatus = snapshot.data;
                      return Button(
                          text: "LOGIN",
                          press: (loadStatus == LoadStatus.loading)
                              ? null
                              : () {
                            if (_formKey.currentState.validate()) {
                              if (!signUp) {
                                _authBloc.login(
                                    _emailController.text,
                                    _passwordController.text);
                              }
                            }
                          }
                      );
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  AlreadyHaveAnAccountCheck(
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SignUpScreen();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }));
  }


    _authTextField(
        {TextEditingController controller,
          String hintText,
          Function validator,
          IconData icon,
        }) {
      return TextFieldContainer(
          child: TextFormField(
              controller: controller,
              validator: validator,
              cursorColor: primaryColor,
              decoration: InputDecoration(
                icon: Icon(
                  icon,
                  color: primaryColor,
                ),
                hintText: hintText,
                border: InputBorder.none,

              ))
      );
    }

    _passTextField(
        {TextEditingController controller,
          String hintText,
          Function validator,
          bool obscureText: true,
          IconData icon,
        }) {
      return TextFieldContainer(
          child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              validator: validator,
              cursorColor: primaryColor,
              decoration: InputDecoration(
                icon: Icon(
                  icon,
                  color: primaryColor,
                ),
                hintText: hintText,
                suffixIcon: Icon(
                  Icons.visibility,
                  color: primaryColor,
                ),
                border: InputBorder.none,

              ))
      );
    }

    @override
    completed(user) {
      _userBloc.changeCurrentUser(user);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menu()));
    }

    @override
    error(error) {
      Scaffold.of(_context).showSnackBar(SnackBar(
        content: Text('Error: ' + error.message),
      ));
    }
}
