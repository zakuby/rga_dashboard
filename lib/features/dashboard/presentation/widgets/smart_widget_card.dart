import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_widget.dart';
import 'calendar_card.dart';
import 'news_summary_card.dart';
import 'quick_notes_card.dart';
import 'stock_ticker_card.dart';
import 'weather_card.dart';

/// Factory widget that renders the appropriate card based on widget type.
class SmartWidgetCard extends StatelessWidget {
  final DashboardWidget widget;

  const SmartWidgetCard({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return switch (widget.type) {
      WidgetType.weather => WeatherCard(widget: widget),
      WidgetType.stockTicker => StockTickerCard(widget: widget),
      WidgetType.newsSummary => NewsSummaryCard(widget: widget),
      WidgetType.calendar => CalendarCard(widget: widget),
      WidgetType.quickNotes => QuickNotesCard(widget: widget),
    };
  }
}
