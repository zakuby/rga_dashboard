import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/quick_notes_card.dart';

void main() {
  Widget createTestWidget(DashboardWidget widget) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 200, child: QuickNotesCard(widget: widget)),
      ),
    );
  }

  group('QuickNotesCard', () {
    testWidgets('displays notes when available', (tester) async {
      const widget = DashboardWidget(
        id: 'notes-1',
        type: WidgetType.quickNotes,
        title: 'Quick Notes',
        order: 0,
        widgetData: QuickNotesData(
          notes: ['Buy groceries', 'Call dentist'],
        ),
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('Quick Notes'), findsOneWidget);
      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Call dentist'), findsOneWidget);
    });

    testWidgets('displays empty state when no data', (tester) async {
      const widget = DashboardWidget(
        id: 'notes-1',
        type: WidgetType.quickNotes,
        title: 'Quick Notes',
        order: 0,
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('No notes yet'), findsOneWidget);
    });
  });
}
