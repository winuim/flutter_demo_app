import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'authentication.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key key, this.title, this.analytics, this.observer})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _DemoPageState createState() => _DemoPageState(analytics, observer);
}

class _DemoPageState extends State<DemoPage> {
  _DemoPageState(this.analytics, this.observer);
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final BaseAuth _auth = Auth();
  FirebaseUser _user;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _counter = 0;
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _user = await _auth.getCurrentUser();
    setState(() {});
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      analytics.logEvent(
          name: '_incrementCounter',
          parameters: <String, dynamic>{'_counter': _counter});
    });
  }

  Widget _drawerHeader() {
    if (_user != null) {
      final name = _user.isAnonymous ? 'Anonymous' : _user.displayName;
      final email = _user.isAnonymous ? '' : _user.email;
      return UserAccountsDrawerHeader(
        accountName: Text(name ?? 'DisplayName not set'),
        accountEmail: Text(email ?? 'Email not set'),
        currentAccountPicture: const CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage('https://i.pravatar.cc/'),
        ),
      );
    } else {
      return DrawerHeader(
        child: FlatButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.of(context).pushNamed('/signin');
              await _getCurrentUser();
            },
            child: Text(
              'サインイン',
              style: Theme.of(context).primaryTextTheme.headline6,
            )),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Builder(builder: (BuildContext context) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _drawerHeader(),
              ListTile(
                title: const Text('Cupertino Demo'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/cupertino');
                },
              ),
              ListTile(
                title: const Text('サインアウト'),
                onTap: () async {
                  await _auth.signOut();
                  await _getCurrentUser();
                  Scaffold.of(context).showSnackBar(const SnackBar(
                    content: Text('サインアウトしました'),
                  ));
                  Navigator.pop(context);
                },
                enabled: _user != null,
              ),
            ],
          ),
        );
      }),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
