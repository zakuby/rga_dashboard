import 'dart:convert';

import '../../domain/entities/dashboard_widget.dart';

/// Data model for DashboardWidget with SQLite serialization.
class DashboardWidgetModel extends DashboardWidget {
  const DashboardWidgetModel({
    required super.id,
    required super.type,
    required super.title,
    required super.order,
    super.isVisible = true,
    super.widgetData,
  });

  /// Creates a model from a database map.
  factory DashboardWidgetModel.fromMap(Map<String, dynamic> map) {
    final type = WidgetType.values[map['type_index'] as int];
    final dataJson = map['data'] as String?;
    final dataMap =
        dataJson != null ? jsonDecode(dataJson) as Map<String, dynamic> : null;

    return DashboardWidgetModel(
      id: map['id'] as String,
      type: type,
      title: map['title'] as String,
      order: map['widget_order'] as int,
      isVisible: (map['is_visible'] as int) == 1,
      widgetData: WidgetData.fromMap(type.name, dataMap),
    );
  }

  /// Converts the model to a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type_index': type.index,
      'title': title,
      'widget_order': order,
      'is_visible': isVisible ? 1 : 0,
      'data': widgetData != null ? jsonEncode(widgetData!.toMap()) : null,
    };
  }

  /// Creates a model from a domain entity.
  factory DashboardWidgetModel.fromEntity(DashboardWidget widget) {
    return DashboardWidgetModel(
      id: widget.id,
      type: widget.type,
      title: widget.title,
      order: widget.order,
      isVisible: widget.isVisible,
      widgetData: widget.widgetData,
    );
  }

  /// Converts to domain entity.
  DashboardWidget toEntity() {
    return DashboardWidget(
      id: id,
      type: type,
      title: title,
      order: order,
      isVisible: isVisible,
      widgetData: widgetData,
    );
  }
}
