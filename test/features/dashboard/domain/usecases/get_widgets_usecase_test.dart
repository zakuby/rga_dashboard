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
    const DashboardWidget(
      id: 'widget-3',
      type: WidgetType.calendar,
      title: 'Calendar',
      position: 2,
    ),
  ];

  group('GetWidgetsUseCase', () {
    test('should call repository getWidgets', () async {
      when(
        () => mockRepository.getWidgets(),
      ).thenAnswer((_) async => Success(testWidgets));

      await useCase();

      verify(() => mockRepository.getWidgets()).called(1);
    });

    test('should return Success with widgets list', () async {
      when(
        () => mockRepository.getWidgets(),
      ).thenAnswer((_) async => Success(testWidgets));

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      final widgets = (result as Success<List<DashboardWidget>>).data;
      expect(widgets.length, 3);
      expect(widgets[0].id, 'widget-1');
      expect(widgets[1].id, 'widget-2');
      expect(widgets[2].id, 'widget-3');
    });

    test('should return Success with empty list when no widgets', () async {
      when(
        () => mockRepository.getWidgets(),
      ).thenAnswer((_) async => const Success(<DashboardWidget>[]));

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      expect((result as Success<List<DashboardWidget>>).data, isEmpty);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getWidgets()).thenAnswer(
        (_) async =>
            const Failure('Failed to load widgets', type: FailureType.cache),
      );

      final result = await useCase();

      expect(result, isA<Failure<List<DashboardWidget>>>());
      final failure = result as Failure<List<DashboardWidget>>;
      expect(failure.message, 'Failed to load widgets');
      expect(failure.type, FailureType.cache);
    });

    test('should return unknown failure on unexpected error', () async {
      when(() => mockRepository.getWidgets()).thenAnswer(
        (_) async =>
            const Failure('Unexpected error', type: FailureType.unknown),
      );

      final result = await useCase();

      expect(result, isA<Failure<List<DashboardWidget>>>());
      expect(
        (result as Failure<List<DashboardWidget>>).type,
        FailureType.unknown,
      );
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
        const DashboardWidget(
          id: 'widget-2',
          type: WidgetType.stockTicker,
          title: 'Stocks',
          position: 2,
        ),
      ];

      when(
        () => mockRepository.getWidgets(),
      ).thenAnswer((_) async => Success(orderedWidgets));

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      final widgets = (result as Success<List<DashboardWidget>>).data;
      expect(widgets[0].id, 'widget-3');
      expect(widgets[1].id, 'widget-1');
      expect(widgets[2].id, 'widget-2');
    });
  });
}
