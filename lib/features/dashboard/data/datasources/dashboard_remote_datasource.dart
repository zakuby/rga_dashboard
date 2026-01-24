import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/dashboard_widget.dart';
import '../models/dashboard_widget_model.dart';

/// Remote data source for dashboard widgets.
/// Simulates fetching data from a backend API using JSON asset files.
abstract class DashboardRemoteDataSource {
  /// Fetches dashboard widgets from the remote source (mock JSON).
  Future<List<DashboardWidgetModel>> fetchWidgets();
}

/// Implementation using JSON asset files to simulate API responses.
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  static const String _dashboardDataPath = 'assets/mock/dashboard_data.json';

  @override
  Future<List<DashboardWidgetModel>> fetchWidgets() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final jsonString = await rootBundle.loadString(_dashboardDataPath);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final widgetsJson = jsonData['widgets'] as List<dynamic>;

    return widgetsJson.map((widgetJson) {
      final map = widgetJson as Map<String, dynamic>;
      return _parseWidget(map);
    }).toList();
  }

  DashboardWidgetModel _parseWidget(Map<String, dynamic> map) {
    final typeString = map['type'] as String;
    final type = _parseWidgetType(typeString);
    final dataMap = map['data'] as Map<String, dynamic>?;

    return DashboardWidgetModel(
      id: map['id'] as String,
      type: type,
      title: map['title'] as String,
      order: map['order'] as int,
      isVisible: map['is_visible'] as bool? ?? true,
      widgetData: WidgetData.fromMap(typeString, dataMap),
    );
  }

  WidgetType _parseWidgetType(String type) {
    return switch (type) {
      'weather' => WidgetType.weather,
      'stockTicker' => WidgetType.stockTicker,
      'newsSummary' => WidgetType.newsSummary,
      'calendar' => WidgetType.calendar,
      'quickNotes' => WidgetType.quickNotes,
      _ => WidgetType.weather,
    };
  }
}
