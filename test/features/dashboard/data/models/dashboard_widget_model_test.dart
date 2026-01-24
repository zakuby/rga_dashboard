import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/dashboard/data/models/dashboard_widget_model.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';

void main() {
  group('DashboardWidgetModel', () {
    const testWeatherData = WeatherData(
      location: 'San Francisco',
      temperature: 72,
      condition: 'sunny',
      humidity: 45,
    );

    const testModel = DashboardWidgetModel(
      id: 'widget-1',
      type: WidgetType.weather,
      title: 'Weather',
      position: 0,
      data: testWeatherData,
    );

    test('should create model with all properties', () {
      expect(testModel.id, 'widget-1');
      expect(testModel.type, WidgetType.weather);
      expect(testModel.title, 'Weather');
      expect(testModel.position, 0);
      expect(testModel.data, testWeatherData);
    });

    test('should have default values', () {
      const model = DashboardWidgetModel();

      expect(model.id, '');
      expect(model.type, WidgetType.weather);
      expect(model.title, '');
      expect(model.position, 0);
      expect(model.data, isNull);
    });

    group('fromJson', () {
      test('should create model from valid json with weather data', () {
        final json = {
          'id': 'widget-1',
          'type': 'weather',
          'title': 'Weather',
          'position': 0,
          'data': {
            'type': 'weather',
            'location': 'San Francisco',
            'temperature': 72,
            'condition': 'sunny',
            'humidity': 45,
          },
        };

        final model = DashboardWidgetModel.fromJson(json);

        expect(model.id, 'widget-1');
        expect(model.type, WidgetType.weather);
        expect(model.title, 'Weather');
        expect(model.position, 0);
        expect(model.weatherData, isNotNull);
        expect(model.weatherData!.location, 'San Francisco');
      });

      test('should create model from json with stock ticker data', () {
        final json = {
          'id': 'stock-1',
          'type': 'stockTicker',
          'title': 'Stocks',
          'position': 1,
          'data': {
            'type': 'stockTicker',
            'stocks': [
              {'symbol': 'AAPL', 'price': 178.52, 'change': 2.34},
            ],
          },
        };

        final model = DashboardWidgetModel.fromJson(json);

        expect(model.type, WidgetType.stockTicker);
        expect(model.stockTickerData, isNotNull);
        expect(model.stockTickerData!.stocks.first.symbol, 'AAPL');
      });

      test('should create model from json with null data', () {
        final json = {
          'id': 'widget-1',
          'type': 'weather',
          'title': 'Weather',
          'position': 0,
        };

        final model = DashboardWidgetModel.fromJson(json);

        expect(model.data, isNull);
      });

      test('should parse all widget types', () {
        for (final widgetType in WidgetType.values) {
          final json = {
            'id': 'widget-${widgetType.name}',
            'type': widgetType.name,
            'title': 'Test',
            'position': 0,
          };

          final model = DashboardWidgetModel.fromJson(json);
          expect(model.type, widgetType);
        }
      });

      test('should use default for unknown widget type', () {
        final json = {
          'id': 'widget-1',
          'type': 'unknown',
          'title': 'Test',
          'position': 0,
        };

        final model = DashboardWidgetModel.fromJson(json);
        expect(model.type, WidgetType.weather);
      });
    });

    group('toJson', () {
      test('should convert model to json', () {
        final json = testModel.toJson();

        expect(json['id'], 'widget-1');
        expect(json['type'], 'weather');
        expect(json['title'], 'Weather');
        expect(json['position'], 0);
        expect(json['data'], isNotNull);
      });

      test('should encode data correctly', () {
        final json = testModel.toJson();
        final dataJson = json['data'] as Map<String, dynamic>;

        expect(dataJson['location'], 'San Francisco');
        expect(dataJson['temperature'], 72);
      });

      test('should handle null data', () {
        const model = DashboardWidgetModel(
          id: 'test',
          type: WidgetType.calendar,
          title: 'Test',
          position: 0,
        );

        final json = model.toJson();

        expect(json['data'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create model from DashboardWidget entity', () {
        const entity = DashboardWidget(
          id: 'entity-1',
          type: WidgetType.quickNotes,
          title: 'Notes',
          position: 5,
          widgetData: QuickNotesData(notes: ['Note 1']),
        );

        final model = DashboardWidgetModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.type, entity.type);
        expect(model.title, entity.title);
        expect(model.position, entity.position);
        expect(model.data, entity.widgetData);
      });
    });

    group('toEntity', () {
      test('should convert to DashboardWidget entity', () {
        final entity = testModel.toEntity();

        expect(entity, isA<DashboardWidget>());
        expect(entity.id, testModel.id);
        expect(entity.type, testModel.type);
        expect(entity.title, testModel.title);
        expect(entity.position, testModel.position);
        expect(entity.widgetData, testModel.data);
      });
    });

    group('round-trip conversion', () {
      test('toJson then fromJson should preserve data', () {
        final json = testModel.toJson();
        final restored = DashboardWidgetModel.fromJson(json);

        expect(restored.id, testModel.id);
        expect(restored.type, testModel.type);
        expect(restored.title, testModel.title);
        expect(restored.position, testModel.position);
        expect(restored.weatherData?.location, testModel.weatherData?.location);
      });

      test('fromEntity then toEntity should preserve data', () {
        const entity = DashboardWidget(
          id: 'round-trip',
          type: WidgetType.calendar,
          title: 'Calendar',
          position: 3,
          widgetData: CalendarData(
            events: [CalendarEvent(title: 'Event', time: '10:00')],
          ),
        );

        final model = DashboardWidgetModel.fromEntity(entity);
        final restoredEntity = model.toEntity();

        expect(restoredEntity.id, entity.id);
        expect(restoredEntity.type, entity.type);
        expect(restoredEntity.calendarData?.events.first.title, 'Event');
      });
    });

    group('type-safe getters', () {
      test('weatherData getter returns data when type matches', () {
        expect(testModel.weatherData, isNotNull);
        expect(testModel.weatherData!.location, 'San Francisco');
      });

      test('weatherData getter returns null when type does not match', () {
        const stockModel = DashboardWidgetModel(
          id: 'test',
          type: WidgetType.stockTicker,
          data: StockTickerData(stocks: []),
        );

        expect(stockModel.weatherData, isNull);
      });
    });
  });
}
