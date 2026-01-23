import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/presentation/widgets/weather_card.dart';

void main() {
  Widget createTestWidget(DashboardWidget widget) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 200, child: WeatherCard(widget: widget)),
      ),
    );
  }

  group('WeatherCard', () {
    testWidgets('displays weather data when available', (tester) async {
      const widget = DashboardWidget(
        id: 'weather-1',
        type: WidgetType.weather,
        title: 'Weather',
        order: 0,
        widgetData: WeatherData(
          location: 'San Francisco',
          temperature: 72,
          condition: 'sunny',
          humidity: 45,
        ),
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('Weather'), findsOneWidget);
      expect(find.text('San Francisco'), findsOneWidget);
      expect(find.text('72°'), findsOneWidget);
      expect(find.text('45% humidity'), findsOneWidget);
    });

    testWidgets('displays empty state when no data', (tester) async {
      const widget = DashboardWidget(
        id: 'weather-1',
        type: WidgetType.weather,
        title: 'Weather',
        order: 0,
      );

      await tester.pumpWidget(createTestWidget(widget));

      expect(find.text('No weather data available'), findsOneWidget);
    });
  });
}
