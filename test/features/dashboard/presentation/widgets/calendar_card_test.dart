import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/calendar_card.dart';

void main() {
  Widget createTestWidget(DashboardWidget widget) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 200, child: CalendarCard(widget: widget)),
      ),
    );
  }

  group('CalendarCard', () {
    testWidgets('displays calendar events when available', (tester) async {
      const widget = DashboardWidget(
        id: 'calendar-1',
        type: WidgetType.calendar,
        title: 'Calendar',
        position: 0,
        widgetData: CalendarData(
          events: [
            CalendarEvent(title: 'Team Meeting', time: '09:00 AM'),
            CalendarEvent(title: 'Lunch with Client', time: '12:30 PM'),
          ],
        ),
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Team Meeting'), findsOneWidget);
      expect(find.text('09:00 AM'), findsOneWidget);
      expect(find.text('Lunch with Client'), findsOneWidget);
    });

    testWidgets('displays empty state when no data', (tester) async {
      const widget = DashboardWidget(
        id: 'calendar-1',
        type: WidgetType.calendar,
        title: 'Calendar',
        position: 0,
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('No events scheduled'), findsOneWidget);
    });
  });
}
