import 'package:freezed_annotation/freezed_annotation.dart';

import 'widget_data.dart';

export 'widget_data.dart';

part 'dashboard_widget.freezed.dart';
part 'dashboard_widget.g.dart';

/// Types of widgets available in the dashboard.
enum WidgetType {
  weather,
  stockTicker,
  newsSummary,
  calendar,
  quickNotes;

  /// Returns the string name of the widget type.
  String get name => switch (this) {
    WidgetType.weather => 'weather',
    WidgetType.stockTicker => 'stockTicker',
    WidgetType.newsSummary => 'newsSummary',
    WidgetType.calendar => 'calendar',
    WidgetType.quickNotes => 'quickNotes',
  };
}

/// Domain entity representing a dashboard widget.
@freezed
class DashboardWidget with _$DashboardWidget {
  const DashboardWidget._();

  const factory DashboardWidget({
    required String id,
    required WidgetType type,
    required String title,
    required int position,
    WidgetData? widgetData,
  }) = _DashboardWidget;

  factory DashboardWidget.fromJson(Map<String, dynamic> json) =>
      _$DashboardWidgetFromJson(json);

  /// Type-safe getter for weather data.
  WeatherData? get weatherData =>
      widgetData is WeatherData ? widgetData as WeatherData : null;

  /// Type-safe getter for stock ticker data.
  StockTickerData? get stockTickerData =>
      widgetData is StockTickerData ? widgetData as StockTickerData : null;

  /// Type-safe getter for news summary data.
  NewsSummaryData? get newsSummaryData =>
      widgetData is NewsSummaryData ? widgetData as NewsSummaryData : null;

  /// Type-safe getter for calendar data.
  CalendarData? get calendarData =>
      widgetData is CalendarData ? widgetData as CalendarData : null;

  /// Type-safe getter for quick notes data.
  QuickNotesData? get quickNotesData =>
      widgetData is QuickNotesData ? widgetData as QuickNotesData : null;
}
