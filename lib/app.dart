import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'screens/cupertino_demo.dart';
import 'screens/demo.dart';
import 'screens/provider_demo.dart';
import 'screens/signin.dart';
import 'screens/signup.dart';

class MyApp extends StatelessWidget {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics();
  static final FirebaseAnalyticsObserver _observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _analytics.logAppOpen();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      initialRoute: '/demo',
      routes: _route(),
      navigatorObservers: <NavigatorObserver>[_observer],
      // debugShowCheckedModeBanner: false,
      // debugShowMaterialGrid: true,
      // showSemanticsDebugger: true,
      // showPerformanceOverlay: true,
    );
  }

  Map<String, Widget Function(BuildContext)> _route() {
    return <String, WidgetBuilder>{
      '/demo': (BuildContext context) => DemoPage(
          title: 'Flutter Demo Home Page',
          analytics: _analytics,
          observer: _observer),
      '/cupertino': (BuildContext context) => CupertinoDemoPage(
          title: 'Flutter Demo Home Page',
          analytics: _analytics,
          observer: _observer),
      '/provider_demo': (BuildContext context) => ProviderDemoPage(
          title: 'Flutter Provider Demo Page',
          analytics: _analytics,
          observer: _observer),
      '/signin': (BuildContext context) => SignInPage(
          title: 'Flutter Demo Home Page',
          analytics: _analytics,
          observer: _observer),
      '/signup': (BuildContext context) => SignUpPage(
          title: 'Flutter Demo Home Page',
          analytics: _analytics,
          observer: _observer),
    };
  }
}
