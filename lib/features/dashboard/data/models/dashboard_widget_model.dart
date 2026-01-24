import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/dashboard_widget.dart';

part 'dashboard_widget_model.freezed.dart';
part 'dashboard_widget_model.g.dart';

/// Converts WidgetType enum to/from string for JSON serialization.
class WidgetTypeConverter implements JsonConverter<WidgetType, String> {
  const WidgetTypeConverter();

  @override
  WidgetType fromJson(String json) {
    return WidgetType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => WidgetType.weather,
    );
  }

  @override
  String toJson(WidgetType object) => object.name;
}

/// Data model for DashboardWidget with JSON serialization.
/// Fields have defaults for defensive parsing of remote data.
@freezed
class DashboardWidgetModel with _$DashboardWidgetModel {
  const DashboardWidgetModel._();

  const factory DashboardWidgetModel({
    @Default('') String id,
    @WidgetTypeConverter() @Default(WidgetType.weather) WidgetType type,
    @Default('') String title,
    @Default(0) int position,
    WidgetData? data,
  }) = _DashboardWidgetModel;

  factory DashboardWidgetModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardWidgetModelFromJson(json);

  /// Creates a model from a domain entity.
  factory DashboardWidgetModel.fromEntity(DashboardWidget widget) {
    return DashboardWidgetModel(
      id: widget.id,
      type: widget.type,
      title: widget.title,
      position: widget.position,
      data: widget.widgetData,
    );
  }

  /// Converts to domain entity.
  DashboardWidget toEntity() {
    return DashboardWidget(
      id: id,
      type: type,
      title: title,
      position: position,
      widgetData: data,
    );
  }

  /// Type-safe getter for weather data.
  WeatherData? get weatherData =>
      data is WeatherData ? data as WeatherData : null;

  /// Type-safe getter for stock ticker data.
  StockTickerData? get stockTickerData =>
      data is StockTickerData ? data as StockTickerData : null;

  /// Type-safe getter for news summary data.
  NewsSummaryData? get newsSummaryData =>
      data is NewsSummaryData ? data as NewsSummaryData : null;

  /// Type-safe getter for calendar data.
  CalendarData? get calendarData =>
      data is CalendarData ? data as CalendarData : null;

  /// Type-safe getter for quick notes data.
  QuickNotesData? get quickNotesData =>
      data is QuickNotesData ? data as QuickNotesData : null;
}
