import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:the_validator/the_validator.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
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
          const SizedBox(height: 120.0),
          Form(
              key: _formKey,
              child: Column(children: <Widget>[
                TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'メールアドレス',
                      icon: Icon(Icons.account_circle),
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
                    validator: FieldValidator.password(
                        minLength: 8,
                        shouldContainNumber: true,
                        shouldContainCapitalLetter: true,
                        // shouldContainSpecialChars: true,
                        errorMessage: 'パスワードは必要な形式と一致する必要があります',
                        isNumberNotPresent: () {
                          return 'パスワードには数字が必要です';
                        },
                        // isSpecialCharsNotPresent: () {
                        //   return 'パスワードには特殊文字を含める必要があります';
                        // },
                        isCapitalLetterNotPresent: () {
                          return 'パスワードには大文字を含める必要があります';
                        }),
                    focusNode: _passwordFocus,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_confirmFocus);
                    }),
                const SizedBox(height: 12.0),
                TextFormField(
                    controller: _confirmController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      labelText: '確認用パスワード',
                      icon: Icon(Icons.security),
                    ),
                    obscureText: true,
                    autocorrect: false,
                    autofocus: false,
                    validator: FieldValidator.equalTo(_passwordController.text, message: 'パスワードが一致していません'),
                    focusNode: _confirmFocus,
                    onFieldSubmitted: (v) {
                      _confirmFocus.unfocus();
                    }),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: const Text('キャンセル'),
                      onPressed: () {
                        _emailController.clear();
                        _passwordController.clear();
                        _confirmController.clear();
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: const Text('アカウント登録'),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          analytics.logSignUp(signUpMethod: 'account regist');
                          Navigator.popUntil(
                              context, ModalRoute.withName('/demo'));
                        }
                      },
                    ),
                  ],
                ),
              ])),
        ],
      ),
    );
  }
}
