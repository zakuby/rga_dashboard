import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rga_dashboard/features/dashboard/domain/usecases/reset_widgets_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late ResetWidgetsUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = ResetWidgetsUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(<DashboardWidget>[]);
  });

  final freshWidgets = [
    const DashboardWidget(
      id: 'fresh-1',
      type: WidgetType.weather,
      title: 'Fresh Weather',
      position: 0,
    ),
    const DashboardWidget(
      id: 'fresh-2',
      type: WidgetType.stockTicker,
      title: 'Fresh Stocks',
      position: 1,
    ),
  ];

  group('ResetWidgetsUseCase', () {
    test(
      'should clear cache and fetch fresh widgets',
      () async {
        when(() => mockRepository.clearWidgets()).thenAnswer((_) async {});
        when(() => mockRepository.getWidgets())
            .thenAnswer((_) async => freshWidgets);

        final result = await useCase();

        expect(result, isA<Success<List<DashboardWidget>>>());
        final widgets = (result as Success<List<DashboardWidget>>).data;
        expect(widgets.length, 2);
        expect(widgets[0].id, 'fresh-1');
        expect(widgets[1].id, 'fresh-2');

        verifyInOrder([
          () => mockRepository.clearWidgets(),
          () => mockRepository.getWidgets(),
        ]);
      },
    );

    test('should return Failure when clearWidgets throws', () async {
      when(() => mockRepository.clearWidgets())
          .thenThrow(Exception('Clear error'));

      final result = await useCase();

      expect(result, isA<Failure<List<DashboardWidget>>>());
      final failure = result as Failure<List<DashboardWidget>>;
      expect(failure.type, FailureType.cache);
      expect(failure.message, contains('Failed to reset widgets'));
      verifyNever(() => mockRepository.getWidgets());
    });

    test('should return Failure when getWidgets throws', () async {
      when(() => mockRepository.clearWidgets()).thenAnswer((_) async {});
      when(() => mockRepository.getWidgets())
          .thenThrow(Exception('Network error'));

      final result = await useCase();

      expect(result, isA<Failure<List<DashboardWidget>>>());
      final failure = result as Failure<List<DashboardWidget>>;
      expect(failure.type, FailureType.cache);
      expect(failure.message, contains('Failed to reset widgets'));
      verify(() => mockRepository.clearWidgets()).called(1);
    });

    test('should handle empty widgets', () async {
      when(() => mockRepository.clearWidgets()).thenAnswer((_) async {});
      when(() => mockRepository.getWidgets()).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      expect((result as Success<List<DashboardWidget>>).data, isEmpty);
    });
  });
}
