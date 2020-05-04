import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:the_validator/the_validator.dart';

import '../utils/auth_util.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key key, this.title, this.analytics, this.observer})
      : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SignInPageState createState() => _SignInPageState(analytics, observer);
}

class _SignInPageState extends State<SignInPage> {
  _SignInPageState(this.analytics, this.observer);
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  final BaseAuth _auth = AuthUtil();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

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
              Text('サインイン',
                  style: TextStyle(color: Theme.of(context).accentColor)),
            ],
          ),
          const SizedBox(height: 120.0),
          Form(
              key: _formKey,
              child: Column(children: <Widget>[
                TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'メールアドレス',
                      icon: Icon(Icons.email),
                    ),
                    autocorrect: false,
                    autofocus: true,
                    validator:
                        FieldValidator.email(message: 'メールアドレスが正しくありません'),
                    focusNode: _emailFocus,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    }),
                const SizedBox(height: 12.0),
                TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      labelText: 'パスワード',
                      icon: Icon(Icons.security),
                    ),
                    obscureText: true,
                    autocorrect: false,
                    autofocus: false,
                    focusNode: _passwordFocus,
                    onFieldSubmitted: (v) {
                      _passwordFocus.unfocus();
                    }),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: const Text('キャンセル'),
                      onPressed: () {
                        _emailController.clear();
                        _passwordController.clear();
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: const Text('サインイン'),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          await _auth
                              .signIn(_emailController.text,
                                  _passwordController.text)
                              .then((userId) {
                            analytics.logLogin();
                            Navigator.pop(context, 'サインインに成功しました');
                          }).catchError((dynamic e) {
                            print(e);
                            Scaffold.of(context).showSnackBar(const SnackBar(
                              content: Text('サインインに失敗しました'),
                            ));
                          });
                        }
                      },
                    ),
                  ],
                ),
              ])),
          FlatButton(
            child: Text('匿名サインイン',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () async {
              await _auth.signInAnonymously().then((userId) {
                analytics.logLogin(loginMethod: 'signInAnonymously');
                Navigator.pop(context, '匿名サインインに成功しました');
              }).catchError((dynamic e) {
                print(e);
                Scaffold.of(context).showSnackBar(const SnackBar(
                  content: Text('匿名サインインに失敗しました'),
                ));
              });
            },
          ),
          FlatButton(
            child: Text('アカウント登録',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.of(context).pushNamed('/signup').then((result) {
                if (result != null) {
                  Navigator.pop(context, result);
                }
              });
            },
          ),
        ],
      );
    }));
  }
}
