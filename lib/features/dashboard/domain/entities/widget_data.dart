import 'package:equatable/equatable.dart';

/// Sealed class representing type-safe widget data.
/// Each widget type has its own strongly-typed data class.
sealed class WidgetData extends Equatable {
  const WidgetData();

  /// Converts the widget data to a map for serialization.
  Map<String, dynamic> toMap();

  /// Creates a WidgetData from a map and widget type.
  static WidgetData? fromMap(String type, Map<String, dynamic>? map) {
    if (map == null) return null;

    return switch (type) {
      'weather' => WeatherData.fromMap(map),
      'stockTicker' => StockTickerData.fromMap(map),
      'newsSummary' => NewsSummaryData.fromMap(map),
      'calendar' => CalendarData.fromMap(map),
      'quickNotes' => QuickNotesData.fromMap(map),
      _ => null,
    };
  }
}

/// Weather widget data.
final class WeatherData extends WidgetData {
  final String location;
  final int temperature;
  final String condition;
  final int humidity;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.humidity,
  });

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
      location: map['location'] as String? ?? 'Unknown',
      temperature: (map['temperature'] as num?)?.toInt() ?? 0,
      condition: map['condition'] as String? ?? 'sunny',
      humidity: (map['humidity'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'location': location,
        'temperature': temperature,
        'condition': condition,
        'humidity': humidity,
      };

  @override
  List<Object?> get props => [location, temperature, condition, humidity];
}

/// Stock data for a single stock.
final class Stock extends Equatable {
  final String symbol;
  final double price;
  final double change;

  const Stock({
    required this.symbol,
    required this.price,
    required this.change,
  });

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      symbol: map['symbol'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      change: (map['change'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'symbol': symbol,
        'price': price,
        'change': change,
      };

  @override
  List<Object?> get props => [symbol, price, change];
}

/// Stock ticker widget data.
final class StockTickerData extends WidgetData {
  final List<Stock> stocks;

  const StockTickerData({required this.stocks});

  factory StockTickerData.fromMap(Map<String, dynamic> map) {
    final stocksList = (map['stocks'] as List<dynamic>?)
            ?.map((s) => Stock.fromMap(s as Map<String, dynamic>))
            .toList() ??
        [];
    return StockTickerData(stocks: stocksList);
  }

  @override
  Map<String, dynamic> toMap() => {
        'stocks': stocks.map((s) => s.toMap()).toList(),
      };

  @override
  List<Object?> get props => [stocks];
}

/// News summary widget data.
final class NewsSummaryData extends WidgetData {
  final List<String> headlines;

  const NewsSummaryData({required this.headlines});

  factory NewsSummaryData.fromMap(Map<String, dynamic> map) {
    return NewsSummaryData(
      headlines:
          (map['headlines'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'headlines': headlines,
      };

  @override
  List<Object?> get props => [headlines];
}

/// Calendar event data.
final class CalendarEvent extends Equatable {
  final String title;
  final String time;

  const CalendarEvent({
    required this.title,
    required this.time,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      title: map['title'] as String? ?? '',
      time: map['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'time': time,
      };

  @override
  List<Object?> get props => [title, time];
}

/// Calendar widget data.
final class CalendarData extends WidgetData {
  final List<CalendarEvent> events;

  const CalendarData({required this.events});

  factory CalendarData.fromMap(Map<String, dynamic> map) {
    final eventsList = (map['events'] as List<dynamic>?)
            ?.map((e) => CalendarEvent.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];
    return CalendarData(events: eventsList);
  }

  @override
  Map<String, dynamic> toMap() => {
        'events': events.map((e) => e.toMap()).toList(),
      };

  @override
  List<Object?> get props => [events];
}

/// Quick notes widget data.
final class QuickNotesData extends WidgetData {
  final List<String> notes;

  const QuickNotesData({required this.notes});

  factory QuickNotesData.fromMap(Map<String, dynamic> map) {
    return QuickNotesData(
      notes: (map['notes'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'notes': notes,
      };

  @override
  List<Object?> get props => [notes];
}
