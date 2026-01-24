import 'package:freezed_annotation/freezed_annotation.dart';

part 'widget_data.freezed.dart';
part 'widget_data.g.dart';

/// Sealed class representing type-safe widget data.
/// Each widget type has its own strongly-typed data class.
/// Fields have defaults for defensive parsing of remote data.
@Freezed(unionKey: 'type')
sealed class WidgetData with _$WidgetData {
  const WidgetData._();

  @FreezedUnionValue('weather')
  const factory WidgetData.weather({
    @Default('Unknown') String location,
    @Default(0) int temperature,
    @Default('sunny') String condition,
    @Default(0) int humidity,
  }) = WeatherData;

  @FreezedUnionValue('stockTicker')
  const factory WidgetData.stockTicker({@Default([]) List<Stock> stocks}) =
      StockTickerData;

  @FreezedUnionValue('newsSummary')
  const factory WidgetData.newsSummary({@Default([]) List<String> headlines}) =
      NewsSummaryData;

  @FreezedUnionValue('calendar')
  const factory WidgetData.calendar({@Default([]) List<CalendarEvent> events}) =
      CalendarData;

  @FreezedUnionValue('quickNotes')
  const factory WidgetData.quickNotes({@Default([]) List<String> notes}) =
      QuickNotesData;

  factory WidgetData.fromJson(Map<String, dynamic> json) =>
      _$WidgetDataFromJson(json);
}

/// Stock data for a single stock.
@freezed
class Stock with _$Stock {
  const factory Stock({
    @Default('') String symbol,
    @Default(0.0) double price,
    @Default(0.0) double change,
  }) = _Stock;

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
}

/// Calendar event data.
@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    @Default('') String title,
    @Default('') String time,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);
}
