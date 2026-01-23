import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/news_summary_card.dart';

void main() {
  Widget createTestWidget(DashboardWidget widget) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 200, child: NewsSummaryCard(widget: widget)),
      ),
    );
  }

  group('NewsSummaryCard', () {
    testWidgets('displays news headlines when available', (tester) async {
      const widget = DashboardWidget(
        id: 'news-1',
        type: WidgetType.newsSummary,
        title: 'News',
        order: 0,
        widgetData: NewsSummaryData(
          headlines: [
            'Tech stocks surge amid AI boom',
            'Federal Reserve holds rates steady',
          ],
        ),
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('News'), findsOneWidget);
      expect(find.text('Tech stocks surge amid AI boom'), findsOneWidget);
      expect(find.text('Federal Reserve holds rates steady'), findsOneWidget);
    });

    testWidgets('displays empty state when no data', (tester) async {
      const widget = DashboardWidget(
        id: 'news-1',
        type: WidgetType.newsSummary,
        title: 'News',
        order: 0,
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('No news available'), findsOneWidget);
    });
  });
}
