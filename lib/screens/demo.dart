import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../components/menu_drawer.dart';
import '../models/auth_user_model.dart';
import '../utils/counter_store.dart';

final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

class DemoPage extends StatefulWidget {
  const DemoPage(
      {Key key, this.title, this.analytics, this.observer})
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

  int _counter;

  @override
  void initState() {
    super.initState();
    // _counter = 0;
    CounterStore().get().then((value) {
      setState(() {
        _counter = value;
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
    analytics.logEvent(
        name: '_incrementCounter',
        parameters: <String, dynamic>{'_counter': _counter});
    CounterStore().set(_counter);
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    analytics.logEvent(
        name: '_resetCounter',
        parameters: <String, dynamic>{'_counter': _counter});
    CounterStore().set(_counter);
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
      drawer: const MenuDrawer(),
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
            Container(
              child: Builder(builder: (BuildContext context) {
                return RaisedButton(
                  child: const Text('Reset'),
                  onPressed: _resetCounter,
                );
              }),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
            ),
            Container(
              child: Builder(builder: (BuildContext context) {
                return RaisedButton(
                  child: const Text('Upload File'),
                  onPressed: () async {
                    final result = await _uploadFile();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(result),
                    ));
                  },
                );
              }),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
            )
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

  Future<String> _uploadFile() async {
    final user = Provider.of<AuthUserModel>(context, listen: false).user;
    if (user == null) {
      return 'No one has signed in.';
    }

    final File file = await CounterStore().getFileStorage();

    final StorageReference storageReference = _firebaseStorage
        .ref()
        .child('text')
        .child(user.uid)
        .child('counter.txt');

    final StorageUploadTask uploadTask = storageReference.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    final StreamSubscription<StorageTaskEvent> streamSubscription =
        uploadTask.events.listen((event) {
      // You can use this to notify yourself or your user in any kind of way.
      // For example: you could use the uploadTask.events stream in a StreamBuilder instead
      // to show your user what the current status is. In that case, you would not need to cancel any
      // subscription as StreamBuilder handles this automatically.

      // Here, every StorageTaskEvent concerning the upload is printed to the logs.
      print('EVENT ${event.type}');
    });

    // Cancel your subscription when done.
    await uploadTask.onComplete;
    streamSubscription.cancel();

    final downloadUrl = (await storageReference.getDownloadURL()).toString();
    print('downloadUrl: $downloadUrl');
    return downloadUrl.toString();
  }
}
