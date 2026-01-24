import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/stock_ticker_card.dart';

void main() {
  Widget createTestWidget(DashboardWidget widget) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 200, child: StockTickerCard(widget: widget)),
      ),
    );
  }

  group('StockTickerCard', () {
    testWidgets('displays stock data when available', (tester) async {
      const widget = DashboardWidget(
        id: 'stocks-1',
        type: WidgetType.stockTicker,
        title: 'Stocks',
        position: 0,
        widgetData: StockTickerData(
          stocks: [
            Stock(symbol: 'AAPL', price: 178.52, change: 2.34),
            Stock(symbol: 'GOOGL', price: 141.23, change: -1.12),
          ],
        ),
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('Stocks'), findsOneWidget);
      expect(find.text('AAPL'), findsOneWidget);
      expect(find.text('GOOGL'), findsOneWidget);
    });

    testWidgets('displays empty state when no data', (tester) async {
      const widget = DashboardWidget(
        id: 'stocks-1',
        type: WidgetType.stockTicker,
        title: 'Stocks',
        position: 0,
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('No stock data available'), findsOneWidget);
    });
  });
}
