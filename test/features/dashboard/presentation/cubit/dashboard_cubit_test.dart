import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/domain/usecases/get_widgets_usecase.dart';
import 'package:rga_dashboard/features/dashboard/domain/usecases/reorder_widgets_usecase.dart';
import 'package:rga_dashboard/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class MockGetWidgetsUseCase extends Mock implements GetWidgetsUseCase {}

class MockReorderWidgetsUseCase extends Mock implements ReorderWidgetsUseCase {}

void main() {
  late DashboardCubit cubit;
  late MockGetWidgetsUseCase mockGetWidgetsUseCase;
  late MockReorderWidgetsUseCase mockReorderWidgetsUseCase;

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

  setUp(() {
    mockGetWidgetsUseCase = MockGetWidgetsUseCase();
    mockReorderWidgetsUseCase = MockReorderWidgetsUseCase();
    cubit = DashboardCubit(
      getWidgetsUseCase: mockGetWidgetsUseCase,
      reorderWidgetsUseCase: mockReorderWidgetsUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(const ReorderParams([]));
  });

  tearDown(() {
    cubit.close();
  });

  group('DashboardCubit', () {
    test('initial state should be DashboardState.initial', () {
      expect(cubit.state, DashboardState.initial());
      expect(cubit.state.status, DashboardStatus.initial);
      expect(cubit.state.widgets, isEmpty);
    });

    group('loadWidgets', () {
      blocTest<DashboardCubit, DashboardState>(
        'emits [loading, loaded] when loadWidgets succeeds',
        build: () {
          when(
            () => mockGetWidgetsUseCase(),
          ).thenAnswer((_) async => Success(testWidgets));
          return cubit;
        },
        act: (cubit) => cubit.loadWidgets(),
        expect: () => [
          DashboardState.loading(),
          DashboardState.loaded(testWidgets),
        ],
        verify: (_) {
          verify(() => mockGetWidgetsUseCase()).called(1);
        },
      );

      blocTest<DashboardCubit, DashboardState>(
        'emits [loading, failure] when loadWidgets fails',
        build: () {
          when(
            () => mockGetWidgetsUseCase(),
          ).thenAnswer((_) async => const Failure('Failed to load widgets'));
          return cubit;
        },
        act: (cubit) => cubit.loadWidgets(),
        expect: () => [
          DashboardState.loading(),
          DashboardState.failure('Failed to load widgets'),
        ],
      );

      blocTest<DashboardCubit, DashboardState>(
        'emits [loading, loaded] with empty list when no widgets',
        build: () {
          when(
            () => mockGetWidgetsUseCase(),
          ).thenAnswer((_) async => const Success([]));
          return cubit;
        },
        act: (cubit) => cubit.loadWidgets(),
        expect: () => [DashboardState.loading(), DashboardState.loaded([])],
      );
    });

    group('reorderWidgets', () {
      blocTest<DashboardCubit, DashboardState>(
        'emits [reordering, loaded] when reorder succeeds (move forward)',
        build: () {
          when(
            () => mockReorderWidgetsUseCase(any()),
          ).thenAnswer((_) async => const Success(true));
          return cubit;
        },
        seed: () => DashboardState.loaded(testWidgets),
        act: (cubit) => cubit.reorderWidgets(0, 2),
        expect: () {
          // Widget 0 moves to position 1 (after adjustment)
          final reordered = [
            testWidgets[1].copyWith(position: 0),
            testWidgets[0].copyWith(position: 1),
            testWidgets[2].copyWith(position: 2),
          ];
          return [
            DashboardState.reordering(reordered),
            DashboardState.loaded(reordered),
          ];
        },
        verify: (_) {
          verify(() => mockReorderWidgetsUseCase(any())).called(1);
        },
      );

      blocTest<DashboardCubit, DashboardState>(
        'emits [reordering, loaded] when reorder succeeds (move backward)',
        build: () {
          when(
            () => mockReorderWidgetsUseCase(any()),
          ).thenAnswer((_) async => const Success(true));
          return cubit;
        },
        seed: () => DashboardState.loaded(testWidgets),
        act: (cubit) => cubit.reorderWidgets(2, 0),
        expect: () {
          // Widget 2 moves to position 0
          final reordered = [
            testWidgets[2].copyWith(position: 0),
            testWidgets[0].copyWith(position: 1),
            testWidgets[1].copyWith(position: 2),
          ];
          return [
            DashboardState.reordering(reordered),
            DashboardState.loaded(reordered),
          ];
        },
      );

      blocTest<DashboardCubit, DashboardState>(
        'reverts to original order when reorder fails',
        build: () {
          when(
            () => mockReorderWidgetsUseCase(any()),
          ).thenAnswer((_) async => const Failure('Failed to save'));
          return cubit;
        },
        seed: () => DashboardState.loaded(testWidgets),
        act: (cubit) => cubit.reorderWidgets(0, 2),
        expect: () {
          final reordered = [
            testWidgets[1].copyWith(position: 0),
            testWidgets[0].copyWith(position: 1),
            testWidgets[2].copyWith(position: 2),
          ];
          return [
            DashboardState.reordering(reordered),
            // Reverts to original (from state.widgets which still has reordered)
            DashboardState.loaded(reordered),
          ];
        },
      );
    });

    group('resetWidgets', () {
      blocTest<DashboardCubit, DashboardState>(
        'calls loadWidgets when resetWidgets is called',
        build: () {
          when(
            () => mockGetWidgetsUseCase(),
          ).thenAnswer((_) async => Success(testWidgets));
          return cubit;
        },
        act: (cubit) => cubit.resetWidgets(),
        expect: () => [
          DashboardState.loading(),
          DashboardState.loaded(testWidgets),
        ],
        verify: (_) {
          verify(() => mockGetWidgetsUseCase()).called(1);
        },
      );
    });
  });

  group('DashboardState', () {
    test('initial state has correct values', () {
      final state = DashboardState.initial();
      expect(state.status, DashboardStatus.initial);
      expect(state.widgets, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('loading state has correct status', () {
      final state = DashboardState.loading();
      expect(state.status, DashboardStatus.loading);
      expect(state.widgets, isEmpty);
    });

    test('loaded state contains widgets', () {
      final state = DashboardState.loaded(testWidgets);
      expect(state.status, DashboardStatus.loaded);
      expect(state.widgets, testWidgets);
    });

    test('reordering state contains widgets', () {
      final state = DashboardState.reordering(testWidgets);
      expect(state.status, DashboardStatus.reordering);
      expect(state.widgets, testWidgets);
    });

    test('failure state contains error message', () {
      final state = DashboardState.failure('Error occurred');
      expect(state.status, DashboardStatus.failure);
      expect(state.errorMessage, 'Error occurred');
    });

    test('copyWith returns new state with updated values', () {
      final state = DashboardState.loaded(testWidgets);
      final copied = state.copyWith(status: DashboardStatus.reordering);

      expect(copied.status, DashboardStatus.reordering);
      expect(copied.widgets, testWidgets);
    });

    test('copyWith preserves values when not specified', () {
      final state = DashboardState.loaded(testWidgets);
      final copied = state.copyWith();

      expect(copied.status, state.status);
      expect(copied.widgets, state.widgets);
    });

    test('states with same values are equal', () {
      final state1 = DashboardState.loaded(testWidgets);
      final state2 = DashboardState.loaded(testWidgets);

      expect(state1, equals(state2));
    });

    test('states with different values are not equal', () {
      final state1 = DashboardState.loaded(testWidgets);
      final state2 = DashboardState.loading();

      expect(state1, isNot(equals(state2)));
    });

    test('all fields are accessible', () {
      final state = DashboardState.loaded(testWidgets);

      expect(state.status, DashboardStatus.loaded);
      expect(state.widgets, testWidgets);
      expect(state.errorMessage, isNull);
    });
  });

  group('DashboardStatus', () {
    test('should have all expected statuses', () {
      expect(DashboardStatus.values, contains(DashboardStatus.initial));
      expect(DashboardStatus.values, contains(DashboardStatus.loading));
      expect(DashboardStatus.values, contains(DashboardStatus.loaded));
      expect(DashboardStatus.values, contains(DashboardStatus.reordering));
      expect(DashboardStatus.values, contains(DashboardStatus.failure));
    });

    test('should have exactly 5 statuses', () {
      expect(DashboardStatus.values.length, 5);
    });
  });
}
