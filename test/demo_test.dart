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

class MockAnalytics extends Mock implements FirebaseAnalytics {}

class MockAnalyticsObserver extends Mock implements FirebaseAnalyticsObserver {}

void main() {
  FirebaseAnalytics _analytics;
  FirebaseAnalyticsObserver _observer;

  setUpAll(() async {
    _analytics = MockAnalytics();
    _observer = MockAnalyticsObserver();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
        home: DemoPage(
      title: 'Flutter Demo Test Page',
      analytics: _analytics,
      observer: _observer,
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
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
        home: DemoPage(
      title: 'Flutter Demo Home Page',
      analytics: _analytics,
      observer: _observer,
    )));

    await tester.tap(find.byKey(const Key('reset')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
