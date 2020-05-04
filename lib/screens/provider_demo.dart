// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

/// This is an example of a counter application using `provider` + [ChangeNotifier].
///
/// It builds a typical `+` button, with a twist: the texts using the counter
/// are built using the localization framework.
///
/// This shows how to bind our custom [ChangeNotifier] to things like [LocalizationsDelegate].

class Counter with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

class ProviderDemoPage extends StatelessWidget {
  const ProviderDemoPage({Key key, this.title, this.analytics, this.observer})
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
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Counter()),
      ],
      child: Consumer<Counter>(
        builder: (context, counter, _) {
          return _ProviderDemoPage(
              title: title, analytics: analytics, observer: observer);
        },
      ),
    );
  }
}

class _ProviderDemoPage extends StatelessWidget {
  const _ProviderDemoPage({Key key, this.title, this.analytics, this.observer})
      : super(key: key);
  final String title;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Tons of small widgets!
      ///
      /// Splitting our app in small widgets like [Title] or [CounterLabel] is
      /// useful for rebuild optimization.
      ///
      /// Since they are instantiated using `const`, they won't unnecessarily
      /// rebuild when their parent changes.
      /// But they can still have dynamic content, as they can obtain providers!
      ///
      /// This means only the widgets that depends on a provider to rebuild when they change.
      /// Alternatively, we could use [Consumer] or [Selector] to achieve the
      /// same result.
      appBar: AppBar(title: Title(title: title)),
      body: const Center(child: CounterLabel()),
      floatingActionButton: const IncrementCounterButton(),
    );
  }
}

class IncrementCounterButton extends StatelessWidget {
  const IncrementCounterButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Provider.of<Counter>(context, listen: false).increment();
      },
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    );
  }
}

class CounterLabel extends StatelessWidget {
  const CounterLabel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Counter>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '${counter.count}',
          // ignore: deprecated_member_use
          style: Theme.of(context).textTheme.display1,
        ),
      ],
    );
  }
}

class Title extends StatelessWidget {
  const Title({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}
