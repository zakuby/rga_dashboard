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

  group('ReorderWidgetsUseCase', () {
    group('index adjustment', () {
      test(
        'should adjust index when moving forward (oldIndex < newIndex)',
        () async {
          List<DashboardWidget>? savedWidgets;
          when(() => mockRepository.saveWidgets(any())).thenAnswer((inv) async {
            savedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
          });

          // Move widget-1 (index 0) to position 2 (after adjustment becomes 1)
          await useCase(
            ReorderParams(widgets: testWidgets, oldIndex: 0, newIndex: 2),
          );

          expect(savedWidgets, isNotNull);
          // Order should be: widget-2, widget-1, widget-3
          expect(savedWidgets![0].id, 'widget-2');
          expect(savedWidgets![1].id, 'widget-1');
          expect(savedWidgets![2].id, 'widget-3');
        },
      );

      test(
        'should not adjust index when moving backward (oldIndex > newIndex)',
        () async {
          List<DashboardWidget>? savedWidgets;
          when(() => mockRepository.saveWidgets(any())).thenAnswer((inv) async {
            savedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
          });

          // Move widget-3 (index 2) to position 0
          await useCase(
            ReorderParams(widgets: testWidgets, oldIndex: 2, newIndex: 0),
          );

          expect(savedWidgets, isNotNull);
          // Order should be: widget-3, widget-1, widget-2
          expect(savedWidgets![0].id, 'widget-3');
          expect(savedWidgets![1].id, 'widget-1');
          expect(savedWidgets![2].id, 'widget-2');
        },
      );
    });

    group('position assignment', () {
      test('should assign correct position values after reordering', () async {
        List<DashboardWidget>? savedWidgets;
        when(() => mockRepository.saveWidgets(any())).thenAnswer((inv) async {
          savedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
        });

        // Move widget-1 (index 0) to end
        await useCase(
          ReorderParams(widgets: testWidgets, oldIndex: 0, newIndex: 3),
        );

        expect(savedWidgets, isNotNull);
        // Positions should be sequential: 0, 1, 2
        expect(savedWidgets![0].position, 0);
        expect(savedWidgets![1].position, 1);
        expect(savedWidgets![2].position, 2);
      });

      test('should preserve widget properties except position', () async {
        List<DashboardWidget>? savedWidgets;
        when(() => mockRepository.saveWidgets(any())).thenAnswer((inv) async {
          savedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
        });

        const notesData = QuickNotesData(notes: ['test note']);
        final widgetsWithData = [
          const DashboardWidget(
            id: 'widget-data',
            type: WidgetType.quickNotes,
            title: 'Notes',
            position: 0,
            widgetData: notesData,
          ),
          testWidgets[0],
        ];

        await useCase(
          ReorderParams(widgets: widgetsWithData, oldIndex: 1, newIndex: 0),
        );

        expect(savedWidgets, isNotNull);
        // widget-data should now be at index 1
        final notesWidget = savedWidgets!.firstWhere(
          (w) => w.id == 'widget-data',
        );
        expect(notesWidget.type, WidgetType.quickNotes);
        expect(notesWidget.title, 'Notes');
        expect(notesWidget.widgetData, notesData);
      });
    });

    group('return value', () {
      test('should return Success with reordered widgets', () async {
        when(() => mockRepository.saveWidgets(any())).thenAnswer((_) async {});

        final result = await useCase(
          ReorderParams(widgets: testWidgets, oldIndex: 0, newIndex: 2),
        );

        expect(result, isA<Success<List<DashboardWidget>>>());
        final widgets = (result as Success<List<DashboardWidget>>).data;
        expect(widgets.length, 3);
        expect(widgets[0].id, 'widget-2');
        expect(widgets[1].id, 'widget-1');
        expect(widgets[2].id, 'widget-3');
      });

      test('should return Failure when save throws', () async {
        when(
          () => mockRepository.saveWidgets(any()),
        ).thenThrow(Exception('Save error'));

        final result = await useCase(
          ReorderParams(widgets: testWidgets, oldIndex: 0, newIndex: 2),
        );

        expect(result, isA<Failure<List<DashboardWidget>>>());
        final failure = result as Failure<List<DashboardWidget>>;
        expect(failure.type, FailureType.cache);
        expect(failure.message, contains('Failed to save widget order'));
      });
    });

    group('edge cases', () {
      test('should handle single widget', () async {
        List<DashboardWidget>? savedWidgets;
        when(() => mockRepository.saveWidgets(any())).thenAnswer((inv) async {
          savedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
        });

        final singleWidget = [testWidgets[0]];
        await useCase(
          ReorderParams(widgets: singleWidget, oldIndex: 0, newIndex: 0),
        );

        expect(savedWidgets, isNotNull);
        expect(savedWidgets!.length, 1);
        expect(savedWidgets![0].position, 0);
      });

      test('should handle moving to same position', () async {
        List<DashboardWidget>? savedWidgets;
        when(() => mockRepository.saveWidgets(any())).thenAnswer((inv) async {
          savedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
        });

        await useCase(
          ReorderParams(widgets: testWidgets, oldIndex: 1, newIndex: 1),
        );

        expect(savedWidgets, isNotNull);
        // Order should be unchanged
        expect(savedWidgets![0].id, 'widget-1');
        expect(savedWidgets![1].id, 'widget-2');
        expect(savedWidgets![2].id, 'widget-3');
      });

      test('should handle moving first to last', () async {
        List<DashboardWidget>? savedWidgets;
        when(() => mockRepository.saveWidgets(any())).thenAnswer((inv) async {
          savedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
        });

        await useCase(
          ReorderParams(
            widgets: testWidgets,
            oldIndex: 0,
            newIndex: 3, // End of list
          ),
        );

        expect(savedWidgets, isNotNull);
        // widget-1 should be at the end
        expect(savedWidgets![0].id, 'widget-2');
        expect(savedWidgets![1].id, 'widget-3');
        expect(savedWidgets![2].id, 'widget-1');
      });

      test('should handle moving last to first', () async {
        List<DashboardWidget>? savedWidgets;
        when(() => mockRepository.saveWidgets(any())).thenAnswer((inv) async {
          savedWidgets = inv.positionalArguments[0] as List<DashboardWidget>;
        });

        await useCase(
          ReorderParams(widgets: testWidgets, oldIndex: 2, newIndex: 0),
        );

        expect(savedWidgets, isNotNull);
        // widget-3 should be at the start
        expect(savedWidgets![0].id, 'widget-3');
        expect(savedWidgets![1].id, 'widget-1');
        expect(savedWidgets![2].id, 'widget-2');
      });
    });

    test('should call repository saveWidgets', () async {
      when(() => mockRepository.saveWidgets(any())).thenAnswer((_) async {});

      await useCase(
        ReorderParams(widgets: testWidgets, oldIndex: 0, newIndex: 2),
      );

      verify(() => mockRepository.saveWidgets(any())).called(1);
    });
  });

  group('ReorderParams', () {
    test('should create params with all required fields', () {
      final params = ReorderParams(
        widgets: testWidgets,
        oldIndex: 0,
        newIndex: 2,
      );

      expect(params.widgets, testWidgets);
      expect(params.oldIndex, 0);
      expect(params.newIndex, 2);
    });

    test('should support equality', () {
      final params1 = ReorderParams(
        widgets: testWidgets,
        oldIndex: 0,
        newIndex: 2,
      );
      final params2 = ReorderParams(
        widgets: testWidgets,
        oldIndex: 0,
        newIndex: 2,
      );

      expect(params1, equals(params2));
    });

    test('should not be equal with different indices', () {
      final params1 = ReorderParams(
        widgets: testWidgets,
        oldIndex: 0,
        newIndex: 2,
      );
      final params2 = ReorderParams(
        widgets: testWidgets,
        oldIndex: 1,
        newIndex: 2,
      );

      expect(params1, isNot(equals(params2)));
    });
  });
}
