import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_capstone/widgets/empty_state_view.dart';

void main() {
  group('EmptyStateView Widget Tests', () {
    testWidgets('renders title and message correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.task_alt,
              title: 'No Tasks',
              message: 'Get started by creating your first task',
            ),
          ),
        ),
      );

      expect(find.text('No Tasks'), findsOneWidget);
      expect(find.text('Get started by creating your first task'), findsOneWidget);
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders action button and triggers callback when clicked',
        (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.add,
              title: 'Empty State',
              message: 'Tap the button below',
              buttonText: 'Add First Task',
              onButtonPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Add First Task'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(buttonPressed, isTrue);
    });
  });
}
