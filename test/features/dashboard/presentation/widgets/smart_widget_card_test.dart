import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/calendar_card.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/news_summary_card.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/quick_notes_card.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/smart_widget_card.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/stock_ticker_card.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/weather_card.dart';

void main() {
  Widget createTestWidget(DashboardWidget widget) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 200, child: SmartWidgetCard(widget: widget)),
      ),
    );
  }

  group('SmartWidgetCard', () {
    testWidgets('renders correct card for each widget type', (tester) async {
      final testCases = [
        (WidgetType.weather, WeatherCard),
        (WidgetType.stockTicker, StockTickerCard),
        (WidgetType.newsSummary, NewsSummaryCard),
        (WidgetType.calendar, CalendarCard),
        (WidgetType.quickNotes, QuickNotesCard),
      ];

      for (final (type, expectedCardType) in testCases) {
        final widget = DashboardWidget(
          id: 'widget-${type.name}',
          type: type,
          title: type.name,
          position: 0,
        );

        await tester.pumpWidget(createTestWidget(widget));
        expect(find.byType(expectedCardType), findsOneWidget);
      }
    });
  });
}
