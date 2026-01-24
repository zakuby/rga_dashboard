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
  ];

  final remoteWidgets = [
    const DashboardWidget(
      id: 'remote-1',
      type: WidgetType.calendar,
      title: 'Remote Calendar',
      position: 0,
    ),
  ];

  group('GetWidgetsUseCase', () {
    test('should return local widgets when they exist', () async {
      when(
        () => mockRepository.hasLocalWidgets(),
      ).thenAnswer((_) async => true);
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenAnswer((_) async => testWidgets);

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      final widgets = (result as Success<List<DashboardWidget>>).data;
      expect(widgets.length, 2);
      expect(widgets[0].id, 'widget-1');
      verify(() => mockRepository.hasLocalWidgets()).called(1);
      verify(() => mockRepository.getLocalWidgets()).called(1);
      verifyNever(() => mockRepository.fetchRemoteWidgets());
    });

    test('should fetch from remote and cache when no local widgets', () async {
      when(
        () => mockRepository.hasLocalWidgets(),
      ).thenAnswer((_) async => false);
      when(
        () => mockRepository.fetchRemoteWidgets(),
      ).thenAnswer((_) async => remoteWidgets);
      when(() => mockRepository.saveWidgets(any())).thenAnswer((_) async {});

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      final widgets = (result as Success<List<DashboardWidget>>).data;
      expect(widgets.length, 1);
      expect(widgets[0].id, 'remote-1');
      verify(() => mockRepository.fetchRemoteWidgets()).called(1);
      verify(() => mockRepository.saveWidgets(any())).called(1);
    });

    test('should return empty list when no widgets available', () async {
      when(
        () => mockRepository.hasLocalWidgets(),
      ).thenAnswer((_) async => false);
      when(
        () => mockRepository.fetchRemoteWidgets(),
      ).thenAnswer((_) async => []);
      when(() => mockRepository.saveWidgets(any())).thenAnswer((_) async {});

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      expect((result as Success<List<DashboardWidget>>).data, isEmpty);
    });

    test('should return Failure when hasLocalWidgets throws', () async {
      when(
        () => mockRepository.hasLocalWidgets(),
      ).thenThrow(Exception('Database error'));

      final result = await useCase();

      expect(result, isA<Failure<List<DashboardWidget>>>());
      expect((result as Failure).type, FailureType.cache);
    });

    test('should return Failure when remote fetch throws', () async {
      when(
        () => mockRepository.hasLocalWidgets(),
      ).thenAnswer((_) async => false);
      when(
        () => mockRepository.fetchRemoteWidgets(),
      ).thenThrow(Exception('Network error'));

      final result = await useCase();

      expect(result, isA<Failure<List<DashboardWidget>>>());
      expect((result as Failure).type, FailureType.cache);
    });

    test('should return Failure when save throws', () async {
      when(
        () => mockRepository.hasLocalWidgets(),
      ).thenAnswer((_) async => false);
      when(
        () => mockRepository.fetchRemoteWidgets(),
      ).thenAnswer((_) async => remoteWidgets);
      when(
        () => mockRepository.saveWidgets(any()),
      ).thenThrow(Exception('Save error'));

      final result = await useCase();

      expect(result, isA<Failure<List<DashboardWidget>>>());
      expect((result as Failure).type, FailureType.cache);
    });

    test('should preserve widget order from local storage', () async {
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
        () => mockRepository.hasLocalWidgets(),
      ).thenAnswer((_) async => true);
      when(
        () => mockRepository.getLocalWidgets(),
      ).thenAnswer((_) async => orderedWidgets);

      final result = await useCase();

      expect(result, isA<Success<List<DashboardWidget>>>());
      final widgets = (result as Success<List<DashboardWidget>>).data;
      expect(widgets[0].id, 'widget-3');
      expect(widgets[1].id, 'widget-1');
    });
  });
}
