import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:provider/provider.dart';

import 'package:flutter_demo_app/models/auth_user_model.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const _MenuDrawHeader(),
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
            title: const Text('バーコードスキャナー'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/barcode_scanner');
            },
          ),
          ListTile(
            title: const Text('サインアウト'),
            onTap: () {
              Provider.of<AuthUserModel>(context, listen: false)
                  .signOut()
                  .then((_) {
                Scaffold.of(context).showSnackBar(const SnackBar(
                  content: Text('サインアウトしました'),
                ));
                Navigator.pop(context);
              });
            },
            enabled: Provider.of<AuthUserModel>(context).user != null,
          ),
        ],
      ),
    );
  }
}

class _MenuDrawHeader extends StatelessWidget {
  const _MenuDrawHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthUserModel>(context).user;
    if (user == null) {
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
    } else {
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
  }
}
