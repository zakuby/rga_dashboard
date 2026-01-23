import 'package:equatable/equatable.dart';

import 'widget_data.dart';

export 'widget_data.dart';

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
class DashboardWidget extends Equatable {
  final String id;
  final WidgetType type;
  final String title;
  final int order;
  final bool isVisible;
  final WidgetData? widgetData;

  const DashboardWidget({
    required this.id,
    required this.type,
    required this.title,
    required this.order,
    this.isVisible = true,
    this.widgetData,
  });

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

  DashboardWidget copyWith({
    String? id,
    WidgetType? type,
    String? title,
    int? order,
    bool? isVisible,
    WidgetData? widgetData,
  }) {
    return DashboardWidget(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      widgetData: widgetData ?? this.widgetData,
    );
  }

  @override
  List<Object?> get props => [id, type, title, order, isVisible, widgetData];
}
