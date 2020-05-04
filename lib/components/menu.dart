import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/auth_util.dart';

class MenuComponent extends StatefulWidget {
  const MenuComponent({Key key, this.analytics, this.observer})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _MenuComponentState createState() => _MenuComponentState(analytics, observer);
}

class _MenuComponentState extends State<MenuComponent> {
  _MenuComponentState(this.analytics, this.observer);
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  final BaseAuth _auth = AuthUtil();
  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _user = await _auth.getCurrentUser();
    setState(() {});
  }

  Widget _userAccountHeader(FirebaseUser user) {
    final name = user.isAnonymous ? 'Anonymous' : user.displayName;
    final email = user.isAnonymous ? '' : user.email;
    return UserAccountsDrawerHeader(
      accountName: Text(name ?? 'DisplayName not set'),
      accountEmail: Text(email ?? 'Email not set'),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage('https://i.pravatar.cc/'),
      ),
    );
  }

  Widget _noLoginHeader() {
    return DrawerHeader(
      child: FlatButton(
          onPressed: () async {
            await Navigator.of(context).pushNamed('/signin').then((result) {
              if (result != null) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(result.toString()),
                ));
              }
            });
            await _getCurrentUser();
            Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          (_user != null ? _userAccountHeader(_user) : _noLoginHeader()),
          ListTile(
            title: const Text('Cupertino Demo'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/cupertino');
            },
          ),
          ListTile(
            title: const Text('Provider Demo'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/provider_demo');
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
  }
}
