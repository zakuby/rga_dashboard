import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';

void main() {
  group('WidgetType', () {
    test('should have all expected types', () {
      expect(WidgetType.values, contains(WidgetType.weather));
      expect(WidgetType.values, contains(WidgetType.stockTicker));
      expect(WidgetType.values, contains(WidgetType.newsSummary));
      expect(WidgetType.values, contains(WidgetType.calendar));
      expect(WidgetType.values, contains(WidgetType.quickNotes));
    });

    test('should have exactly 5 types', () {
      expect(WidgetType.values.length, 5);
    });

    test('should have correct index values', () {
      expect(WidgetType.weather.index, 0);
      expect(WidgetType.stockTicker.index, 1);
      expect(WidgetType.newsSummary.index, 2);
      expect(WidgetType.calendar.index, 3);
      expect(WidgetType.quickNotes.index, 4);
    });

    test('should have correct name values', () {
      expect(WidgetType.weather.name, 'weather');
      expect(WidgetType.stockTicker.name, 'stockTicker');
      expect(WidgetType.newsSummary.name, 'newsSummary');
      expect(WidgetType.calendar.name, 'calendar');
      expect(WidgetType.quickNotes.name, 'quickNotes');
    });
  });

  group('DashboardWidget', () {
    const weatherData = WeatherData(
      location: 'San Francisco',
      temperature: 72,
      condition: 'sunny',
      humidity: 45,
    );

    test('should create widget with required properties', () {
      const widget = DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Weather Widget',
        position: 0,
      );

      expect(widget.id, 'widget-1');
      expect(widget.type, WidgetType.weather);
      expect(widget.title, 'Weather Widget');
      expect(widget.position, 0);
      expect(widget.widgetData, isNull);
    });

    test('should create widget with all properties', () {
      const widget = DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Weather',
        position: 1,
        widgetData: weatherData,
      );

      expect(widget.id, 'widget-1');
      expect(widget.type, WidgetType.weather);
      expect(widget.title, 'Weather');
      expect(widget.position, 1);
      expect(widget.widgetData, weatherData);
    });

    test('should return typed weatherData getter', () {
      const widget = DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Weather',
        position: 0,
        widgetData: weatherData,
      );

      expect(widget.weatherData, isNotNull);
      expect(widget.weatherData!.location, 'San Francisco');
      expect(widget.weatherData!.temperature, 72);
    });

    test('should return null for wrong data type getter', () {
      const widget = DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Weather',
        position: 0,
        widgetData: weatherData,
      );

      expect(widget.stockTickerData, isNull);
      expect(widget.newsSummaryData, isNull);
      expect(widget.calendarData, isNull);
      expect(widget.quickNotesData, isNull);
    });

    test('should support equality for same properties', () {
      const widget1 = DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Weather',
        position: 0,
        widgetData: weatherData,
      );
      const widget2 = DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Weather',
        position: 0,
        widgetData: weatherData,
      );

      expect(widget1, equals(widget2));
    });

    test('should not be equal when id differs', () {
      const widget1 = DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Weather',
        position: 0,
      );
      const widget2 = DashboardWidget(
        id: 'widget-2',
        type: WidgetType.weather,
        title: 'Weather',
        position: 0,
      );

      expect(widget1, isNot(equals(widget2)));
    });

    group('copyWith', () {
      const originalWidget = DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Weather',
        position: 0,
        widgetData: weatherData,
      );

      test('should return same widget when no parameters provided', () {
        final copied = originalWidget.copyWith();

        expect(copied, equals(originalWidget));
      });

      test('should copy with new id', () {
        final copied = originalWidget.copyWith(id: 'widget-2');

        expect(copied.id, 'widget-2');
        expect(copied.type, originalWidget.type);
      });

      test('should copy with new widgetData', () {
        const newData = WeatherData(
          location: 'New York',
          temperature: 65,
          condition: 'cloudy',
          humidity: 60,
        );
        final copied = originalWidget.copyWith(widgetData: newData);

        expect(copied.widgetData, newData);
        expect(copied.weatherData!.location, 'New York');
      });
    });
  });

  group('WeatherData', () {
    test('should create with all properties', () {
      const data = WeatherData(
        location: 'San Francisco',
        temperature: 72,
        condition: 'sunny',
        humidity: 45,
      );

      expect(data.location, 'San Francisco');
      expect(data.temperature, 72);
      expect(data.condition, 'sunny');
      expect(data.humidity, 45);
    });

    test('should support equality', () {
      const data1 = WeatherData(
        location: 'SF',
        temperature: 72,
        condition: 'sunny',
        humidity: 45,
      );
      const data2 = WeatherData(
        location: 'SF',
        temperature: 72,
        condition: 'sunny',
        humidity: 45,
      );

      expect(data1, equals(data2));
    });
  });

  group('Stock', () {
    test('should create with all properties', () {
      const stock = Stock(symbol: 'AAPL', price: 178.52, change: 2.34);

      expect(stock.symbol, 'AAPL');
      expect(stock.price, 178.52);
      expect(stock.change, 2.34);
    });

    test('should convert to json correctly', () {
      const stock = Stock(symbol: 'AAPL', price: 178.52, change: 2.34);

      final json = stock.toJson();

      expect(json['symbol'], 'AAPL');
      expect(json['price'], 178.52);
      expect(json['change'], 2.34);
    });

    test('should create from json correctly', () {
      final json = {'symbol': 'GOOGL', 'price': 141.23, 'change': -1.12};

      final stock = Stock.fromJson(json);

      expect(stock.symbol, 'GOOGL');
      expect(stock.price, 141.23);
      expect(stock.change, -1.12);
    });
  });

  group('StockTickerData', () {
    test('should create with stocks list', () {
      const data = StockTickerData(
        stocks: [
          Stock(symbol: 'AAPL', price: 178.52, change: 2.34),
          Stock(symbol: 'GOOGL', price: 141.23, change: -1.12),
        ],
      );

      expect(data.stocks.length, 2);
      expect(data.stocks[0].symbol, 'AAPL');
      expect(data.stocks[1].symbol, 'GOOGL');
    });
  });

  group('NewsSummaryData', () {
    test('should create with headlines list', () {
      const data = NewsSummaryData(headlines: ['Headline 1', 'Headline 2']);

      expect(data.headlines.length, 2);
      expect(data.headlines[0], 'Headline 1');
    });
  });

  group('CalendarEvent', () {
    test('should create with all properties', () {
      const event = CalendarEvent(title: 'Meeting', time: '09:00 AM');

      expect(event.title, 'Meeting');
      expect(event.time, '09:00 AM');
    });

    test('should convert to json correctly', () {
      const event = CalendarEvent(title: 'Meeting', time: '09:00 AM');

      final json = event.toJson();

      expect(json['title'], 'Meeting');
      expect(json['time'], '09:00 AM');
    });
  });

  group('CalendarData', () {
    test('should create with events list', () {
      const data = CalendarData(
        events: [
          CalendarEvent(title: 'Meeting', time: '09:00 AM'),
          CalendarEvent(title: 'Lunch', time: '12:00 PM'),
        ],
      );

      expect(data.events.length, 2);
      expect(data.events[0].title, 'Meeting');
    });
  });

  group('QuickNotesData', () {
    test('should create with notes list', () {
      const data = QuickNotesData(notes: ['Note 1', 'Note 2']);

      expect(data.notes.length, 2);
      expect(data.notes[0], 'Note 1');
    });
  });
}
