import 'dart:convert';

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
      order: 0,
      isVisible: true,
      widgetData: testWeatherData,
    );

    test('should be a subclass of DashboardWidget', () {
      expect(testModel, isA<DashboardWidget>());
    });

    test('should create model with all properties', () {
      expect(testModel.id, 'widget-1');
      expect(testModel.type, WidgetType.weather);
      expect(testModel.title, 'Weather');
      expect(testModel.order, 0);
      expect(testModel.isVisible, true);
      expect(testModel.widgetData, testWeatherData);
    });

    test('should default isVisible to true', () {
      const model = DashboardWidgetModel(
        id: 'test',
        type: WidgetType.calendar,
        title: 'Test',
        order: 0,
      );

      expect(model.isVisible, true);
    });

    group('fromMap', () {
      test('should create model from valid map with weather data', () {
        final map = {
          'id': 'widget-1',
          'type_index': 0,
          'title': 'Weather',
          'widget_order': 0,
          'is_visible': 1,
          'data': jsonEncode({
            'location': 'San Francisco',
            'temperature': 72,
            'condition': 'sunny',
            'humidity': 45,
          }),
        };

        final model = DashboardWidgetModel.fromMap(map);

        expect(model.id, 'widget-1');
        expect(model.type, WidgetType.weather);
        expect(model.title, 'Weather');
        expect(model.order, 0);
        expect(model.isVisible, true);
        expect(model.weatherData, isNotNull);
        expect(model.weatherData!.location, 'San Francisco');
      });

      test('should create model from map with stock ticker data', () {
        final map = {
          'id': 'stock-1',
          'type_index': 1,
          'title': 'Stocks',
          'widget_order': 1,
          'is_visible': 1,
          'data': jsonEncode({
            'stocks': [
              {'symbol': 'AAPL', 'price': 178.52, 'change': 2.34},
            ],
          }),
        };

        final model = DashboardWidgetModel.fromMap(map);

        expect(model.type, WidgetType.stockTicker);
        expect(model.stockTickerData, isNotNull);
        expect(model.stockTickerData!.stocks.first.symbol, 'AAPL');
      });

      test('should create model from map with null data', () {
        final map = {
          'id': 'widget-1',
          'type_index': 0,
          'title': 'Weather',
          'widget_order': 0,
          'is_visible': 1,
          'data': null,
        };

        final model = DashboardWidgetModel.fromMap(map);

        expect(model.widgetData, isNull);
      });

      test('should handle is_visible as 0', () {
        final map = {
          'id': 'widget-1',
          'type_index': 0,
          'title': 'Hidden',
          'widget_order': 0,
          'is_visible': 0,
          'data': null,
        };

        final model = DashboardWidgetModel.fromMap(map);

        expect(model.isVisible, false);
      });

      test('should parse all widget types', () {
        for (var i = 0; i < WidgetType.values.length; i++) {
          final map = {
            'id': 'widget-$i',
            'type_index': i,
            'title': 'Test $i',
            'widget_order': i,
            'is_visible': 1,
            'data': null,
          };

          final model = DashboardWidgetModel.fromMap(map);
          expect(model.type, WidgetType.values[i]);
        }
      });
    });

    group('toMap', () {
      test('should convert model to map', () {
        final map = testModel.toMap();

        expect(map['id'], 'widget-1');
        expect(map['type_index'], 0);
        expect(map['title'], 'Weather');
        expect(map['widget_order'], 0);
        expect(map['is_visible'], 1);
        expect(map['data'], isNotNull);
      });

      test('should encode widgetData as JSON string', () {
        final map = testModel.toMap();

        expect(map['data'], isA<String>());
        final decoded = jsonDecode(map['data'] as String);
        expect(decoded['location'], 'San Francisco');
      });

      test('should handle null widgetData', () {
        const model = DashboardWidgetModel(
          id: 'test',
          type: WidgetType.calendar,
          title: 'Test',
          order: 0,
        );

        final map = model.toMap();

        expect(map['data'], isNull);
      });

      test('should convert isVisible to 1 or 0', () {
        const visibleModel = DashboardWidgetModel(
          id: 'test',
          type: WidgetType.calendar,
          title: 'Test',
          order: 0,
          isVisible: true,
        );

        const hiddenModel = DashboardWidgetModel(
          id: 'test',
          type: WidgetType.calendar,
          title: 'Test',
          order: 0,
          isVisible: false,
        );

        expect(visibleModel.toMap()['is_visible'], 1);
        expect(hiddenModel.toMap()['is_visible'], 0);
      });
    });

    group('fromEntity', () {
      test('should create model from DashboardWidget entity', () {
        const entity = DashboardWidget(
          id: 'entity-1',
          type: WidgetType.quickNotes,
          title: 'Notes',
          order: 5,
          isVisible: false,
          widgetData: QuickNotesData(notes: ['Note 1']),
        );

        final model = DashboardWidgetModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.type, entity.type);
        expect(model.title, entity.title);
        expect(model.order, entity.order);
        expect(model.isVisible, entity.isVisible);
        expect(model.widgetData, entity.widgetData);
      });
    });

    group('toEntity', () {
      test('should convert to DashboardWidget entity', () {
        final entity = testModel.toEntity();

        expect(entity, isA<DashboardWidget>());
        expect(entity.id, testModel.id);
        expect(entity.type, testModel.type);
        expect(entity.title, testModel.title);
        expect(entity.order, testModel.order);
        expect(entity.isVisible, testModel.isVisible);
        expect(entity.widgetData, testModel.widgetData);
      });
    });

    group('round-trip conversion', () {
      test('toMap then fromMap should preserve data', () {
        final map = testModel.toMap();
        final restored = DashboardWidgetModel.fromMap(map);

        expect(restored.id, testModel.id);
        expect(restored.type, testModel.type);
        expect(restored.title, testModel.title);
        expect(restored.order, testModel.order);
        expect(restored.isVisible, testModel.isVisible);
        expect(restored.weatherData?.location, testModel.weatherData?.location);
      });

      test('fromEntity then toEntity should preserve data', () {
        const entity = DashboardWidget(
          id: 'round-trip',
          type: WidgetType.calendar,
          title: 'Calendar',
          order: 3,
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
  });
}
