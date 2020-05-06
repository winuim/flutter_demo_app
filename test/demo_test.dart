// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_demo_app/screens/demo.dart';
import 'package:flutter_demo_app/utils/counter_store.dart';

class MockAnalytics extends Mock implements FirebaseAnalytics {}

class MockAnalyticsObserver extends Mock implements FirebaseAnalyticsObserver {}

class MockCounterStore extends Mock implements CounterStore {}

void main() {
  FirebaseAnalytics _analytics;
  FirebaseAnalyticsObserver _observer;
  CounterStore _counterStore;

  setUpAll(() async {
    _analytics = MockAnalytics();
    _observer = MockAnalyticsObserver();
    _counterStore = MockCounterStore();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Return 0 CounterStore().get()
    when(_counterStore.get()).thenAnswer((_) => Future.value(0));

    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
        home: DemoPage(
      title: 'Flutter Demo Test Page',
      analytics: _analytics,
      observer: _observer,
      counterStore: _counterStore,
    )));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Counter reset smoke test', (WidgetTester tester) async {
    // Return 0 CounterStore().get()
    when(_counterStore.get()).thenAnswer((_) => Future.value(0));

    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
        home: DemoPage(
      title: 'Flutter Demo Home Page',
      analytics: _analytics,
      observer: _observer,
      counterStore: _counterStore,
    )));

    await tester.tap(find.byKey(const Key('reset')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
