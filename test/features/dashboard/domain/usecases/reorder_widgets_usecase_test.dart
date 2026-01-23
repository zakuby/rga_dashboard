import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rga_dashboard/features/dashboard/domain/usecases/reorder_widgets_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late ReorderWidgetsUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = ReorderWidgetsUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(<DashboardWidget>[]);
  });

  final testWidgets = [
    const DashboardWidget(
      id: 'widget-1',
      type: WidgetType.weather,
      title: 'Weather',
      order: 0,
    ),
    const DashboardWidget(
      id: 'widget-2',
      type: WidgetType.stockTicker,
      title: 'Stocks',
      order: 1,
    ),
    const DashboardWidget(
      id: 'widget-3',
      type: WidgetType.calendar,
      title: 'Calendar',
      order: 2,
    ),
  ];

  group('ReorderWidgetsUseCase', () {
    test('should call repository saveWidgetOrder', () async {
      when(() => mockRepository.saveWidgetOrder(any()))
          .thenAnswer((_) async => const Success(true));

      await useCase(ReorderParams(testWidgets));

      verify(() => mockRepository.saveWidgetOrder(any())).called(1);
    });

    test('should update order values based on list position', () async {
      List<DashboardWidget>? capturedWidgets;
      when(() => mockRepository.saveWidgetOrder(any())).thenAnswer((inv) async {
        capturedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
        return const Success(true);
      });

      // Reorder: widget-3 first, then widget-1, then widget-2
      final reorderedList = [testWidgets[2], testWidgets[0], testWidgets[1]];
      await useCase(ReorderParams(reorderedList));

      expect(capturedWidgets, isNotNull);
      expect(capturedWidgets![0].id, 'widget-3');
      expect(capturedWidgets![0].order, 0);
      expect(capturedWidgets![1].id, 'widget-1');
      expect(capturedWidgets![1].order, 1);
      expect(capturedWidgets![2].id, 'widget-2');
      expect(capturedWidgets![2].order, 2);
    });

    test('should return Success when save succeeds', () async {
      when(() => mockRepository.saveWidgetOrder(any()))
          .thenAnswer((_) async => const Success(true));

      final result = await useCase(ReorderParams(testWidgets));

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('should return Failure when save fails', () async {
      when(() => mockRepository.saveWidgetOrder(any()))
          .thenAnswer((_) async => const Failure(
                'Failed to save order',
                type: FailureType.cache,
              ));

      final result = await useCase(ReorderParams(testWidgets));

      expect(result, isA<Failure<bool>>());
      final failure = result as Failure<bool>;
      expect(failure.message, 'Failed to save order');
      expect(failure.type, FailureType.cache);
    });

    test('should handle empty widgets list', () async {
      when(() => mockRepository.saveWidgetOrder(any()))
          .thenAnswer((_) async => const Success(true));

      final result = await useCase(const ReorderParams([]));

      expect(result, isA<Success<bool>>());
      verify(() => mockRepository.saveWidgetOrder([])).called(1);
    });

    test('should handle single widget', () async {
      List<DashboardWidget>? capturedWidgets;
      when(() => mockRepository.saveWidgetOrder(any())).thenAnswer((inv) async {
        capturedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
        return const Success(true);
      });

      final singleWidget = [testWidgets[0]];
      await useCase(ReorderParams(singleWidget));

      expect(capturedWidgets, isNotNull);
      expect(capturedWidgets!.length, 1);
      expect(capturedWidgets![0].order, 0);
    });

    test('should preserve widget properties except order', () async {
      List<DashboardWidget>? capturedWidgets;
      when(() => mockRepository.saveWidgetOrder(any())).thenAnswer((inv) async {
        capturedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
        return const Success(true);
      });

      const notesData = QuickNotesData(notes: ['test note']);
      const widgetWithData = DashboardWidget(
        id: 'widget-data',
        type: WidgetType.quickNotes,
        title: 'Notes',
        order: 5,
        isVisible: false,
        widgetData: notesData,
      );

      await useCase(const ReorderParams([widgetWithData]));

      expect(capturedWidgets, isNotNull);
      expect(capturedWidgets![0].id, 'widget-data');
      expect(capturedWidgets![0].type, WidgetType.quickNotes);
      expect(capturedWidgets![0].title, 'Notes');
      expect(capturedWidgets![0].order, 0); // Updated
      expect(capturedWidgets![0].isVisible, false);
      expect(capturedWidgets![0].widgetData, notesData);
      expect(capturedWidgets![0].quickNotesData?.notes, ['test note']);
    });
  });

  group('ReorderParams', () {
    test('should create ReorderParams with widgets list', () {
      final params = ReorderParams(testWidgets);

      expect(params.widgets, testWidgets);
      expect(params.widgets.length, 3);
    });

    test('should support equality for same widgets', () {
      final params1 = ReorderParams(testWidgets);
      final params2 = ReorderParams(testWidgets);

      expect(params1, equals(params2));
    });

    test('should not be equal for different widgets', () {
      final params1 = ReorderParams(testWidgets);
      final params2 = ReorderParams([testWidgets[0]]);

      expect(params1, isNot(equals(params2)));
    });

    test('should not be equal for different order', () {
      final params1 = ReorderParams(testWidgets);
      final params2 = ReorderParams(testWidgets.reversed.toList());

      expect(params1, isNot(equals(params2)));
    });

    test('should have correct props for Equatable', () {
      final params = ReorderParams(testWidgets);

      expect(params.props, [testWidgets]);
    });

    test('should handle empty list', () {
      const params = ReorderParams([]);

      expect(params.widgets, isEmpty);
    });
  });
}
