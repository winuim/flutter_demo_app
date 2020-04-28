import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error = '';

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
              Text('FLUTTER DEMO APP', style: TextStyle(color: Theme.of(context).accentColor)),
            ],
          ),
          const SizedBox(height: 100.0),
          Center(
              child: Text(_error,
                  style: TextStyle(color: Theme.of(context).errorColor))),
          const SizedBox(height: 12.0),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'E-mail',
            ),
          ),
          const SizedBox(height: 12.0),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
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
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          FlatButton(
            child: Text('匿名サインイン', style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              setState(() {
                _error = 'ERROR';
              });
              // Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('アカウント登録', style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              setState(() {
                _error = 'ERROR';
              });
              // Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
