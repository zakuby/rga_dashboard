import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../domain/entities/dashboard_widget.dart';
import '../models/dashboard_widget_model.dart';

/// Local data source for dashboard widgets using SQLite.
abstract class DashboardLocalDataSource {
  /// Gets all widgets from local storage.
  Future<List<DashboardWidgetModel>> getWidgets();

  /// Saves widgets to local storage.
  Future<void> saveWidgets(List<DashboardWidgetModel> widgets);

  /// Clears all widgets from storage.
  Future<void> clearWidgets();

  /// Checks if widgets exist in storage.
  Future<bool> hasWidgets();
}

/// Implementation using SQLite.
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  @override
  Future<List<DashboardWidgetModel>> getWidgets() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableWidgets,
      orderBy: 'widget_order ASC',
    );

    return maps.map((map) => DashboardWidgetModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveWidgets(List<DashboardWidgetModel> widgets) async {
    final db = await DatabaseHelper.database;

    await db.transaction((txn) async {
      await txn.delete(DatabaseHelper.tableWidgets);
      for (final widget in widgets) {
        await txn.insert(
          DatabaseHelper.tableWidgets,
          widget.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> clearWidgets() async {
    final db = await DatabaseHelper.database;
    await db.delete(DatabaseHelper.tableWidgets);
  }

  @override
  Future<bool> hasWidgets() async {
    final db = await DatabaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableWidgets,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Returns default widgets for initial setup.
  static List<DashboardWidgetModel> getDefaultWidgets() {
    return [
      const DashboardWidgetModel(
        id: 'weather_1',
        type: WidgetType.weather,
        title: 'Weather',
        order: 0,
        widgetData: WeatherData(
          location: 'San Francisco',
          temperature: 72,
          condition: 'sunny',
          humidity: 45,
        ),
      ),
      const DashboardWidgetModel(
        id: 'stock_1',
        type: WidgetType.stockTicker,
        title: 'Stock Ticker',
        order: 1,
        widgetData: StockTickerData(
          stocks: [
            Stock(symbol: 'AAPL', price: 178.52, change: 2.34),
            Stock(symbol: 'GOOGL', price: 141.23, change: -1.12),
            Stock(symbol: 'MSFT', price: 378.91, change: 4.56),
          ],
        ),
      ),
      const DashboardWidgetModel(
        id: 'news_1',
        type: WidgetType.newsSummary,
        title: 'News Summary',
        order: 2,
        widgetData: NewsSummaryData(
          headlines: [
            'Tech Stocks Rally Amid AI Optimism',
            'Federal Reserve Signals Rate Decision',
            'New Climate Agreement Reached',
          ],
        ),
      ),
      const DashboardWidgetModel(
        id: 'calendar_1',
        type: WidgetType.calendar,
        title: 'Calendar',
        order: 3,
        widgetData: CalendarData(
          events: [
            CalendarEvent(title: 'Team Standup', time: '09:00 AM'),
            CalendarEvent(title: 'Product Review', time: '02:00 PM'),
            CalendarEvent(title: 'Client Call', time: '04:30 PM'),
          ],
        ),
      ),
      const DashboardWidgetModel(
        id: 'notes_1',
        type: WidgetType.quickNotes,
        title: 'Quick Notes',
        order: 4,
        widgetData: QuickNotesData(
          notes: [
            'Review PR #234',
            'Update documentation',
            'Schedule design review',
          ],
        ),
      ),
    ];
  }
}
