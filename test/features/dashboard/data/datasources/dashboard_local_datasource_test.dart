import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:rga_dashboard/features/dashboard/data/models/dashboard_widget_model.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';

void main() {
  group('DashboardLocalDataSourceImpl', () {
    group('getDefaultWidgets', () {
      test('should return 5 default widgets', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        expect(widgets.length, 5);
      });

      test('should return widgets in correct order', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        expect(widgets[0].order, 0);
        expect(widgets[1].order, 1);
        expect(widgets[2].order, 2);
        expect(widgets[3].order, 3);
        expect(widgets[4].order, 4);
      });

      test('should return weather widget first', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        expect(widgets[0].type, WidgetType.weather);
        expect(widgets[0].id, 'weather_1');
        expect(widgets[0].title, 'Weather');
      });

      test('should return stock ticker widget second', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        expect(widgets[1].type, WidgetType.stockTicker);
        expect(widgets[1].id, 'stock_1');
        expect(widgets[1].title, 'Stock Ticker');
      });

      test('should return news summary widget third', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        expect(widgets[2].type, WidgetType.newsSummary);
        expect(widgets[2].id, 'news_1');
        expect(widgets[2].title, 'News Summary');
      });

      test('should return calendar widget fourth', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        expect(widgets[3].type, WidgetType.calendar);
        expect(widgets[3].id, 'calendar_1');
        expect(widgets[3].title, 'Calendar');
      });

      test('should return quick notes widget fifth', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        expect(widgets[4].type, WidgetType.quickNotes);
        expect(widgets[4].id, 'notes_1');
        expect(widgets[4].title, 'Quick Notes');
      });

      test('should include weather data', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();
        final weatherWidget = widgets[0];

        expect(weatherWidget.weatherData, isNotNull);
        expect(weatherWidget.weatherData!.location, 'San Francisco');
        expect(weatherWidget.weatherData!.temperature, 72);
        expect(weatherWidget.weatherData!.condition, 'sunny');
        expect(weatherWidget.weatherData!.humidity, 45);
      });

      test('should include stock ticker data', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();
        final stockWidget = widgets[1];

        expect(stockWidget.stockTickerData, isNotNull);
        expect(stockWidget.stockTickerData!.stocks.length, 3);
        expect(stockWidget.stockTickerData!.stocks[0].symbol, 'AAPL');
        expect(stockWidget.stockTickerData!.stocks[1].symbol, 'GOOGL');
        expect(stockWidget.stockTickerData!.stocks[2].symbol, 'MSFT');
      });

      test('should include news summary data', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();
        final newsWidget = widgets[2];

        expect(newsWidget.newsSummaryData, isNotNull);
        expect(newsWidget.newsSummaryData!.headlines.length, 3);
      });

      test('should include calendar data', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();
        final calendarWidget = widgets[3];

        expect(calendarWidget.calendarData, isNotNull);
        expect(calendarWidget.calendarData!.events.length, 3);
        expect(calendarWidget.calendarData!.events[0].title, 'Team Standup');
      });

      test('should include quick notes data', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();
        final notesWidget = widgets[4];

        expect(notesWidget.quickNotesData, isNotNull);
        expect(notesWidget.quickNotesData!.notes.length, 3);
      });

      test('should return DashboardWidgetModel instances', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        for (final widget in widgets) {
          expect(widget, isA<DashboardWidgetModel>());
        }
      });

      test('all widgets should be visible by default', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        for (final widget in widgets) {
          expect(widget.isVisible, true);
        }
      });
    });
  });
}
