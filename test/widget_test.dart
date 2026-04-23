import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strm_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const STRMApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}