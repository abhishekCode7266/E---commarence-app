import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_capstone/models/priority_enum.dart';
import 'package:flutter_todo_capstone/widgets/priority_badge.dart';

void main() {
  group('PriorityBadge Widget Tests', () {
    testWidgets('renders High priority badge with correct text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriorityBadge(priority: TaskPriority.high),
          ),
        ),
      );

      expect(find.text('High'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('renders Low priority badge with correct text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriorityBadge(priority: TaskPriority.low),
          ),
        ),
      );

      expect(find.text('Low'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });

    testWidgets('renders Medium priority badge with correct text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriorityBadge(priority: TaskPriority.medium),
          ),
        ),
      );

      expect(find.text('Medium'), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    });
  });
}
