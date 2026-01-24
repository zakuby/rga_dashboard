import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../models/dashboard_widget_model.dart';

/// Local data source for dashboard widgets using SQLite.
/// Handles persistence of widget order and configurations.
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
@LazySingleton(as: DashboardLocalDataSource)
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  @override
  Future<List<DashboardWidgetModel>> getWidgets() async {
    final db = await DatabaseHelper.database;
    final rows = await db.query(
      DatabaseHelper.tableWidgets,
      orderBy: 'position ASC',
    );
    return rows.map(_fromSqlite).toList();
  }

  @override
  Future<void> saveWidgets(List<DashboardWidgetModel> widgets) async {
    final db = await DatabaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseHelper.tableWidgets);
      for (final widget in widgets) {
        await txn.insert(
          DatabaseHelper.tableWidgets,
          _toSqlite(widget),
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
    final result = await db.query(DatabaseHelper.tableWidgets, limit: 1);
    return result.isNotEmpty;
  }

  DashboardWidgetModel _fromSqlite(Map<String, dynamic> row) =>
      DashboardWidgetModel.fromJson({
        ...row,
        'data': row['data'] != null ? jsonDecode(row['data'] as String) : null,
      });

  Map<String, dynamic> _toSqlite(DashboardWidgetModel widget) => {
    ...widget.toJson(),
    'data': widget.data != null ? jsonEncode(widget.data!.toJson()) : null,
  };
}
