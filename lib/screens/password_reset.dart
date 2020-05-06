import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_demo_app/components/signup/email_textfield.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({Key key, this.title, this.analytics, this.observer})
      : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState(analytics, observer);
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  _PasswordResetPageState(this.analytics, this.observer);
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

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
              Text('パスワードをリセットする',
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
                ),
                const SizedBox(height: 12.0),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: const Text('キャンセル'),
                      onPressed: () {
                        _emailController.clear();
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: const Text('パスワードリセット'),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          try {
                            await _firebaseAuth.sendPasswordResetEmail(email: _emailController.text);
                            Scaffold.of(context).showSnackBar(const SnackBar(
                              content: Text('パスワードリセットメールを送信しました'),
                            ));
                          } on PlatformException catch (e) {
                            // print(e);
                            Scaffold.of(context).showSnackBar(const SnackBar(
                              content: Text('パスワードリセットに失敗しました'),
                            ));
                          } catch (e, stackTrace) {
                            print(e);
                            print(stackTrace);
                            Scaffold.of(context).showSnackBar(const SnackBar(
                              content: Text('パスワードリセットに失敗しました'),
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
