import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:provider/provider.dart';

import '../components/signup/email_textfield.dart';
import '../components/signup/password_textfield.dart';
import '../components/signup/username_textfield.dart';
import '../models/auth_user_model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key key, this.title, this.analytics, this.observer})
      : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SignUpPageState createState() => _SignUpPageState(analytics, observer);
}

class _SignUpPageState extends State<SignUpPage> {
  _SignUpPageState(this.analytics, this.observer);

  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (BuildContext context) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: <Widget>[
          const SizedBox(height: 80.0),
          Column(
            children: <Widget>[
              Image.asset('packages/shrine_images/diamond.png'),
              const SizedBox(height: 16.0),
              Text('アカウント登録',
                  style: TextStyle(color: Theme.of(context).accentColor)),
            ],
          ),
          const SizedBox(height: 60.0),
          Form(
              key: _formKey,
              child: Column(children: <Widget>[
                UsernameTextField(
                  editController: _usernameController,
                  myFocus: _usernameFocus,
                  nextFocus: _emailFocus,
                ),
                const SizedBox(height: 12.0),
                EmailTextField(
                  editController: _emailController,
                  myFocus: _emailFocus,
                  nextFocus: _passwordFocus,
                ),
                const SizedBox(height: 12.0),
                PasswordTextField(
                  editController: _passwordController,
                  myFocus: _passwordFocus,
                  nextFocus: _confirmFocus,
                ),
                const SizedBox(height: 12.0),
                ConfirmPasswordTextField(
                  editController: _confirmController,
                  passwordController: _passwordController,
                  myFocus: _confirmFocus,
                ),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: const Text('キャンセル'),
                      onPressed: () {
                        _usernameController.clear();
                        _emailController.clear();
                        _passwordController.clear();
                        _confirmController.clear();
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: const Text('アカウント登録'),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          try {
                            await Provider.of<AuthUserModel>(context, listen: false).signUp(_emailController.text, _passwordController.text, _usernameController.text);
                            analytics.logSignUp(
                                signUpMethod: 'createUserWithEmailAndPassword');
                            Navigator.pop(context, 'アカウント登録&サインインに成功しました');
                          } catch (e, stackTrace) {
                            print(e);
                            print(stackTrace);
                            Scaffold.of(context).showSnackBar(const SnackBar(
                              content: Text('アカウント登録に失敗しました'),
                            ));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ])),
        ],
      );
    }));
  }
}
