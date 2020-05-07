import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:provider/provider.dart';

import 'package:flutter_demo_app/components/signup/email_textfield.dart';
import 'package:flutter_demo_app/components/signup/password_textfield.dart';
import 'package:flutter_demo_app/models/auth_user_model.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key key, this.title, this.analytics, this.observer})
      : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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
                EmailTextField(
                  editController: _emailController,
                  myFocus: _emailFocus,
                  nextFocus: _passwordFocus,
                ),
                const SizedBox(height: 12.0),
                PasswordTextField(
                  editController: _passwordController,
                  myFocus: _passwordFocus,
                  validate: false,
                ),
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
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          try {
                            Provider.of<AuthUserModel>(context, listen: false)
                                .signIn(_emailController.text,
                                    _passwordController.text)
                                .then((_) {
                              widget.analytics.logLogin();
                              Navigator.pop(context, 'サインインに成功しました');
                            });
                          } on PlatformException catch (e) {
                            print(e);
                            Scaffold.of(context).showSnackBar(const SnackBar(
                              content: Text('サインインに失敗しました'),
                            ));
                          } catch (e, stackTrace) {
                            print(e);
                            print(stackTrace);
                            Scaffold.of(context).showSnackBar(const SnackBar(
                              content: Text('サインインに失敗しました'),
                            ));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ])),
          FlatButton(
            child: Text('お困りの時はこちら',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.of(context).pushNamed('/password_reset');
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
          FlatButton(
            child: Text('匿名サインイン',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () async {
              try {
                Provider.of<AuthUserModel>(context, listen: false)
                    .signInAnonymously()
                    .then((_) {
                  widget.analytics.logLogin(loginMethod: 'signInAnonymously');
                  Navigator.pop(context, '匿名サインインに成功しました');
                });
              } on PlatformException catch (e) {
                // print(e);
                Scaffold.of(context).showSnackBar(const SnackBar(
                  content: Text('匿名サインインに失敗しました'),
                ));
              } catch (e, stackTrace) {
                print(e);
                print(stackTrace);
                Scaffold.of(context).showSnackBar(const SnackBar(
                  content: Text('匿名サインインに失敗しました'),
                ));
              }
            },
          ),
        ],
      );
    }));
  }
}
