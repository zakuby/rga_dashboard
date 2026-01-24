import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rga_dashboard/features/dashboard/domain/usecases/update_widget_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late UpdateWidgetUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = UpdateWidgetUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(<DashboardWidget>[]);
    registerFallbackValue(
      const UpdateWidgetParams(
        DashboardWidget(
          id: 'fallback',
          type: WidgetType.weather,
          title: 'Fallback',
          position: 0,
        ),
      ),
    );
  });

  final existingWidgets = [
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

  final updatedWidget = const DashboardWidget(
    id: 'widget-2',
    type: WidgetType.stockTicker,
    title: 'Updated Stocks',
    position: 1,
  );

  group('UpdateWidgetUseCase', () {
    test('should find and update widget by ID', () async {
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenAnswer((_) async => existingWidgets);
      when(() => mockRepository.saveWidgets(any())).thenAnswer((_) async {});

      final result = await useCase(UpdateWidgetParams(updatedWidget));

      expect(result, isA<Success<DashboardWidget>>());
      final widget = (result as Success<DashboardWidget>).data;
      expect(widget.id, 'widget-2');
      expect(widget.title, 'Updated Stocks');
      verify(() => mockRepository.getLocalWidgets()).called(1);
      verify(() => mockRepository.saveWidgets(any())).called(1);
    });

    test('should preserve other widgets when updating', () async {
      List<DashboardWidget>? savedWidgets;
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenAnswer((_) async => existingWidgets);
      when(() => mockRepository.saveWidgets(any())).thenAnswer((invocation) {
        savedWidgets =
            invocation.positionalArguments[0] as List<DashboardWidget>;
        return Future.value();
      });

      await useCase(UpdateWidgetParams(updatedWidget));

      expect(savedWidgets, isNotNull);
      expect(savedWidgets!.length, 3);
      expect(savedWidgets![0].id, 'widget-1');
      expect(savedWidgets![0].title, 'Weather');
      expect(savedWidgets![1].id, 'widget-2');
      expect(savedWidgets![1].title, 'Updated Stocks');
      expect(savedWidgets![2].id, 'widget-3');
      expect(savedWidgets![2].title, 'Calendar');
    });

    test('should return Failure when widget not found', () async {
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenAnswer((_) async => existingWidgets);

      final nonExistentWidget = const DashboardWidget(
        id: 'non-existent',
        type: WidgetType.weather,
        title: 'Ghost',
        position: 0,
      );

      final result = await useCase(UpdateWidgetParams(nonExistentWidget));

      expect(result, isA<Failure<DashboardWidget>>());
      final failure = result as Failure<DashboardWidget>;
      expect(failure.message, 'Widget not found');
      expect(failure.type, FailureType.cache);
      verifyNever(() => mockRepository.saveWidgets(any()));
    });

    test('should return Failure when getLocalWidgets throws', () async {
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenThrow(Exception('Database error'));

      final result = await useCase(UpdateWidgetParams(updatedWidget));

      expect(result, isA<Failure<DashboardWidget>>());
      final failure = result as Failure<DashboardWidget>;
      expect(failure.type, FailureType.cache);
      expect(failure.message, contains('Failed to update widget'));
    });

    test('should return Failure when saveWidgets throws', () async {
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenAnswer((_) async => existingWidgets);
      when(
        () => mockRepository.saveWidgets(any()),
      ).thenThrow(Exception('Save error'));

      final result = await useCase(UpdateWidgetParams(updatedWidget));

      expect(result, isA<Failure<DashboardWidget>>());
      final failure = result as Failure<DashboardWidget>;
      expect(failure.type, FailureType.cache);
      expect(failure.message, contains('Failed to update widget'));
    });

    test('should update first widget correctly', () async {
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenAnswer((_) async => existingWidgets);
      when(() => mockRepository.saveWidgets(any())).thenAnswer((_) async {});

      final firstWidgetUpdate = const DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Updated Weather',
        position: 0,
      );

      final result = await useCase(UpdateWidgetParams(firstWidgetUpdate));

      expect(result, isA<Success<DashboardWidget>>());
      expect(
        (result as Success<DashboardWidget>).data.title,
        'Updated Weather',
      );
    });

    test('should update last widget correctly', () async {
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenAnswer((_) async => existingWidgets);
      when(() => mockRepository.saveWidgets(any())).thenAnswer((_) async {});

      final lastWidgetUpdate = const DashboardWidget(
        id: 'widget-3',
        type: WidgetType.calendar,
        title: 'Updated Calendar',
        position: 2,
      );

      final result = await useCase(UpdateWidgetParams(lastWidgetUpdate));

      expect(result, isA<Success<DashboardWidget>>());
      expect(
        (result as Success<DashboardWidget>).data.title,
        'Updated Calendar',
      );
    });

    test('should handle single widget list', () async {
      final singleWidgetList = [existingWidgets[0]];
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenAnswer((_) async => singleWidgetList);
      when(() => mockRepository.saveWidgets(any())).thenAnswer((_) async {});

      final singleWidgetUpdate = const DashboardWidget(
        id: 'widget-1',
        type: WidgetType.weather,
        title: 'Only Widget Updated',
        position: 0,
      );

      final result = await useCase(UpdateWidgetParams(singleWidgetUpdate));

      expect(result, isA<Success<DashboardWidget>>());
      expect(
        (result as Success<DashboardWidget>).data.title,
        'Only Widget Updated',
      );
    });

    test('should return Failure when widget list is empty', () async {
      when(() => mockRepository.getLocalWidgets()).thenAnswer((_) async => []);

      final result = await useCase(UpdateWidgetParams(updatedWidget));

      expect(result, isA<Failure<DashboardWidget>>());
      expect((result as Failure<DashboardWidget>).message, 'Widget not found');
    });
  });

  group('UpdateWidgetParams', () {
    test('should create params with widget', () {
      const widget = DashboardWidget(
        id: 'test',
        type: WidgetType.weather,
        title: 'Test',
        position: 0,
      );
      const params = UpdateWidgetParams(widget);
      expect(params.widget, widget);
    });

    test('should support equality', () {
      const widget = DashboardWidget(
        id: 'test',
        type: WidgetType.weather,
        title: 'Test',
        position: 0,
      );
      const params1 = UpdateWidgetParams(widget);
      const params2 = UpdateWidgetParams(widget);
      expect(params1, equals(params2));
    });
  });
}
