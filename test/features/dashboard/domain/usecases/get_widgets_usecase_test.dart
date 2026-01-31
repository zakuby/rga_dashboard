import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rga_dashboard/features/dashboard/domain/usecases/get_widgets_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetWidgetsUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetWidgetsUseCase(mockRepository);
  });

  final testWidgets = [
    const DashboardWidget(
      id: 'widget-1',
      type: WidgetType.weather,
      title: 'Weather',
      position: 0,
    ),
    const DashboardWidget(
      id: 'widget-2',
      type: WidgetType.stockTicker,
      title: 'Stocks',
      position: 1,
    ),
  ];

  group('GetWidgetsUseCase', () {
    test('should return widgets from repository', () async {
      when(
        () => mockRepository.getWidgets(),
      ).thenAnswer((_) async => testWidgets);

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      final widgets = (result as Success<List<DashboardWidget>>).data;
      expect(widgets.length, 2);
      expect(widgets[0].id, 'widget-1');
      verify(() => mockRepository.getWidgets()).called(1);
    });

    test('should return empty list when no widgets available', () async {
      when(() => mockRepository.getWidgets()).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      expect((result as Success<List<DashboardWidget>>).data, isEmpty);
    });

    test('should return Failure when repository throws', () async {
      when(
        () => mockRepository.getWidgets(),
      ).thenThrow(Exception('Database error'));

      final result = await useCase();

      expect(result, isA<Failure<List<DashboardWidget>>>());
      expect((result as Failure).type, FailureType.cache);
    });

    test('should preserve widget order from repository', () async {
      final orderedWidgets = [
        const DashboardWidget(
          id: 'widget-3',
          type: WidgetType.calendar,
          title: 'Calendar',
          position: 0,
        ),
        const DashboardWidget(
          id: 'widget-1',
          type: WidgetType.weather,
          title: 'Weather',
          position: 1,
        ),
      ];

      when(
        () => mockRepository.getWidgets(),
      ).thenAnswer((_) async => orderedWidgets);

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      final widgets = (result as Success<List<DashboardWidget>>).data;
      expect(widgets[0].id, 'widget-3');
      expect(widgets[1].id, 'widget-1');
    });
  });
}
