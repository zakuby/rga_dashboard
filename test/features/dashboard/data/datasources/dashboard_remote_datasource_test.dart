import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DashboardRemoteDataSourceImpl dataSource;

  const mockJsonData = '''
{
  "widgets": [
    {
      "id": "weather_1",
      "type": "weather",
      "title": "Weather",
      "order": 0,
      "is_visible": true,
      "data": {
        "location": "San Francisco",
        "temperature": 72,
        "condition": "sunny",
        "humidity": 45
      }
    },
    {
      "id": "stock_1",
      "type": "stockTicker",
      "title": "Stock Ticker",
      "order": 1,
      "is_visible": true,
      "data": {
        "stocks": [
          {"symbol": "AAPL", "price": 178.52, "change": 2.34}
        ]
      }
    },
    {
      "id": "news_1",
      "type": "newsSummary",
      "title": "News Summary",
      "order": 2,
      "is_visible": true,
      "data": {
        "headlines": ["Test Headline 1", "Test Headline 2"]
      }
    },
    {
      "id": "calendar_1",
      "type": "calendar",
      "title": "Calendar",
      "order": 3,
      "is_visible": true,
      "data": {
        "events": [
          {"title": "Meeting", "time": "09:00 AM"}
        ]
      }
    },
    {
      "id": "notes_1",
      "type": "quickNotes",
      "title": "Quick Notes",
      "order": 4,
      "is_visible": true,
      "data": {
        "notes": ["Test note 1", "Test note 2"]
      }
    }
  ]
}
''';

  setUp(() {
    dataSource = DashboardRemoteDataSourceImpl();

    // Mock the asset bundle
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final String key = const StringCodec().decodeMessage(message)!;
          if (key == 'assets/mock/dashboard_data.json') {
            return const StringCodec().encodeMessage(mockJsonData);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('DashboardRemoteDataSourceImpl', () {
    group('fetchWidgets', () {
      test('should fetch and parse widgets from JSON asset', () async {
        final widgets = await dataSource.fetchWidgets();

        expect(widgets.length, 5);
      });

      test('should parse weather widget correctly', () async {
        final widgets = await dataSource.fetchWidgets();
        final weatherWidget = widgets.firstWhere(
          (w) => w.type == WidgetType.weather,
        );

        expect(weatherWidget.id, 'weather_1');
        expect(weatherWidget.title, 'Weather');
        expect(weatherWidget.order, 0);
        expect(weatherWidget.isVisible, true);
        expect(weatherWidget.weatherData, isNotNull);
        expect(weatherWidget.weatherData!.location, 'San Francisco');
        expect(weatherWidget.weatherData!.temperature, 72);
        expect(weatherWidget.weatherData!.condition, 'sunny');
        expect(weatherWidget.weatherData!.humidity, 45);
      });

      test('should parse stock ticker widget correctly', () async {
        final widgets = await dataSource.fetchWidgets();
        final stockWidget = widgets.firstWhere(
          (w) => w.type == WidgetType.stockTicker,
        );

        expect(stockWidget.id, 'stock_1');
        expect(stockWidget.stockTickerData, isNotNull);
        expect(stockWidget.stockTickerData!.stocks.length, 1);
        expect(stockWidget.stockTickerData!.stocks[0].symbol, 'AAPL');
        expect(stockWidget.stockTickerData!.stocks[0].price, 178.52);
        expect(stockWidget.stockTickerData!.stocks[0].change, 2.34);
      });

      test('should parse news summary widget correctly', () async {
        final widgets = await dataSource.fetchWidgets();
        final newsWidget = widgets.firstWhere(
          (w) => w.type == WidgetType.newsSummary,
        );

        expect(newsWidget.id, 'news_1');
        expect(newsWidget.newsSummaryData, isNotNull);
        expect(newsWidget.newsSummaryData!.headlines.length, 2);
        expect(newsWidget.newsSummaryData!.headlines[0], 'Test Headline 1');
      });

      test('should parse calendar widget correctly', () async {
        final widgets = await dataSource.fetchWidgets();
        final calendarWidget = widgets.firstWhere(
          (w) => w.type == WidgetType.calendar,
        );

        expect(calendarWidget.id, 'calendar_1');
        expect(calendarWidget.calendarData, isNotNull);
        expect(calendarWidget.calendarData!.events.length, 1);
        expect(calendarWidget.calendarData!.events[0].title, 'Meeting');
        expect(calendarWidget.calendarData!.events[0].time, '09:00 AM');
      });

      test('should parse quick notes widget correctly', () async {
        final widgets = await dataSource.fetchWidgets();
        final notesWidget = widgets.firstWhere(
          (w) => w.type == WidgetType.quickNotes,
        );

        expect(notesWidget.id, 'notes_1');
        expect(notesWidget.quickNotesData, isNotNull);
        expect(notesWidget.quickNotesData!.notes.length, 2);
        expect(notesWidget.quickNotesData!.notes[0], 'Test note 1');
      });

      test('should return widgets in correct order', () async {
        final widgets = await dataSource.fetchWidgets();

        expect(widgets[0].order, 0);
        expect(widgets[1].order, 1);
        expect(widgets[2].order, 2);
        expect(widgets[3].order, 3);
        expect(widgets[4].order, 4);
      });
    });
  });
}
