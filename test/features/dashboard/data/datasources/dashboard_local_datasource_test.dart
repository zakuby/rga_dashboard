import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/core/database/database_helper.dart';
import 'package:rga_dashboard/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:rga_dashboard/features/dashboard/data/models/dashboard_widget_model.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DashboardLocalDataSourceImpl dataSource;
  late Database testDb;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    testDb = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tableWidgets} (
              id TEXT PRIMARY KEY,
              type_index INTEGER NOT NULL,
              title TEXT NOT NULL,
              widget_order INTEGER NOT NULL,
              is_visible INTEGER NOT NULL DEFAULT 1,
              data TEXT
            )
          ''');
        },
      ),
    );
    DatabaseHelper.setTestDatabase(testDb);
    dataSource = DashboardLocalDataSourceImpl();
  });

  tearDown(() async {
    await testDb.close();
    DatabaseHelper.resetDatabase();
  });

  final testWidgets = [
    const DashboardWidgetModel(
      id: 'weather_1',
      type: WidgetType.weather,
      title: 'Weather',
      order: 0,
      widgetData: WeatherData(
        location: 'Test City',
        temperature: 70,
        condition: 'sunny',
        humidity: 50,
      ),
    ),
    const DashboardWidgetModel(
      id: 'stock_1',
      type: WidgetType.stockTicker,
      title: 'Stocks',
      order: 1,
    ),
  ];

  group('DashboardLocalDataSourceImpl', () {
    group('saveWidgets', () {
      test('should save widgets to database', () async {
        await dataSource.saveWidgets(testWidgets);

        final result = await testDb.query(DatabaseHelper.tableWidgets);
        expect(result.length, 2);
      });

      test('should replace existing widgets on save', () async {
        await dataSource.saveWidgets(testWidgets);

        final newWidgets = [
          const DashboardWidgetModel(
            id: 'calendar_1',
            type: WidgetType.calendar,
            title: 'Calendar',
            order: 0,
          ),
        ];
        await dataSource.saveWidgets(newWidgets);

        final result = await testDb.query(DatabaseHelper.tableWidgets);
        expect(result.length, 1);
        expect(result.first['id'], 'calendar_1');
      });
    });

    group('getWidgets', () {
      test('should return saved widgets', () async {
        await dataSource.saveWidgets(testWidgets);

        final result = await dataSource.getWidgets();

        expect(result.length, 2);
        expect(result[0].id, 'weather_1');
        expect(result[1].id, 'stock_1');
      });

      test('should return widgets ordered by widget_order', () async {
        final unorderedWidgets = [
          const DashboardWidgetModel(
            id: 'widget_2',
            type: WidgetType.calendar,
            title: 'Second',
            order: 1,
          ),
          const DashboardWidgetModel(
            id: 'widget_1',
            type: WidgetType.weather,
            title: 'First',
            order: 0,
          ),
        ];
        await dataSource.saveWidgets(unorderedWidgets);

        final result = await dataSource.getWidgets();

        expect(result[0].order, 0);
        expect(result[1].order, 1);
      });

      test('should return empty list when no widgets', () async {
        final result = await dataSource.getWidgets();

        expect(result, isEmpty);
      });

      test('should deserialize widget data correctly', () async {
        await dataSource.saveWidgets(testWidgets);

        final result = await dataSource.getWidgets();

        expect(result[0].weatherData, isNotNull);
        expect(result[0].weatherData!.location, 'Test City');
        expect(result[0].weatherData!.temperature, 70);
      });
    });

    group('hasWidgets', () {
      test('should return true when widgets exist', () async {
        await dataSource.saveWidgets(testWidgets);

        final result = await dataSource.hasWidgets();

        expect(result, isTrue);
      });

      test('should return false when no widgets', () async {
        final result = await dataSource.hasWidgets();

        expect(result, isFalse);
      });
    });

    group('clearWidgets', () {
      test('should clear all widgets', () async {
        await dataSource.saveWidgets(testWidgets);
        expect(await dataSource.hasWidgets(), isTrue);

        await dataSource.clearWidgets();

        expect(await dataSource.hasWidgets(), isFalse);
      });

      test('should not throw when clearing empty database', () async {
        await expectLater(dataSource.clearWidgets(), completes);
      });
    });

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
      });

      test('should include widget data for all widgets', () {
        final widgets = DashboardLocalDataSourceImpl.getDefaultWidgets();

        expect(widgets[0].weatherData, isNotNull);
        expect(widgets[1].stockTickerData, isNotNull);
        expect(widgets[2].newsSummaryData, isNotNull);
        expect(widgets[3].calendarData, isNotNull);
        expect(widgets[4].quickNotesData, isNotNull);
      });
    });
  });
}
