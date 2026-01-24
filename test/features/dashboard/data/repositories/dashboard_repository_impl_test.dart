import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:rga_dashboard/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:rga_dashboard/features/dashboard/data/models/dashboard_widget_model.dart';
import 'package:rga_dashboard/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';

class MockDashboardLocalDataSource extends Mock
    implements DashboardLocalDataSource {}

class MockDashboardRemoteDataSource extends Mock
    implements DashboardRemoteDataSource {}

void main() {
  late DashboardRepositoryImpl repository;
  late MockDashboardLocalDataSource mockLocalDataSource;
  late MockDashboardRemoteDataSource mockRemoteDataSource;

  final testWidgetModels = [
    const DashboardWidgetModel(
      id: 'widget-1',
      type: WidgetType.weather,
      title: 'Weather',
      position: 0,
      data: WeatherData(
        location: 'Test City',
        temperature: 70,
        condition: 'sunny',
        humidity: 50,
      ),
    ),
    const DashboardWidgetModel(
      id: 'widget-2',
      type: WidgetType.calendar,
      title: 'Calendar',
      position: 1,
    ),
  ];

  final remoteWidgetModels = [
    const DashboardWidgetModel(
      id: 'remote-1',
      type: WidgetType.weather,
      title: 'Remote Weather',
      position: 0,
      data: WeatherData(
        location: 'Remote City',
        temperature: 80,
        condition: 'cloudy',
        humidity: 60,
      ),
    ),
    const DashboardWidgetModel(
      id: 'remote-2',
      type: WidgetType.stockTicker,
      title: 'Remote Stocks',
      position: 1,
    ),
  ];

  setUp(() {
    mockLocalDataSource = MockDashboardLocalDataSource();
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    repository = DashboardRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  setUpAll(() {
    registerFallbackValue(<DashboardWidgetModel>[]);
  });

  group('DashboardRepositoryImpl', () {
    group('getWidgets', () {
      test('should return local widgets when they exist in storage', () async {
        when(
          () => mockLocalDataSource.hasWidgets(),
        ).thenAnswer((_) async => true);
        when(
          () => mockLocalDataSource.getWidgets(),
        ).thenAnswer((_) async => testWidgetModels);

        final result = await repository.getWidgets();

        expect(result, isA<Success<List<DashboardWidget>>>());
        final widgets = (result as Success<List<DashboardWidget>>).data;
        expect(widgets.length, 2);
        expect(widgets[0].id, 'widget-1');
        verify(() => mockLocalDataSource.hasWidgets()).called(1);
        verify(() => mockLocalDataSource.getWidgets()).called(1);
        verifyNever(() => mockRemoteDataSource.fetchWidgets());
      });

      test(
        'should fetch from remote and cache when no local widgets exist',
        () async {
          when(
            () => mockLocalDataSource.hasWidgets(),
          ).thenAnswer((_) async => false);
          when(
            () => mockRemoteDataSource.fetchWidgets(),
          ).thenAnswer((_) async => remoteWidgetModels);
          when(
            () => mockLocalDataSource.saveWidgets(any()),
          ).thenAnswer((_) async {});

          final result = await repository.getWidgets();

          expect(result, isA<Success<List<DashboardWidget>>>());
          final widgets = (result as Success<List<DashboardWidget>>).data;
          expect(widgets.length, 2);
          expect(widgets[0].id, 'remote-1');
          expect(widgets[0].title, 'Remote Weather');
          verify(() => mockRemoteDataSource.fetchWidgets()).called(1);
          verify(() => mockLocalDataSource.saveWidgets(any())).called(1);
        },
      );

      test('should return Failure when exception is thrown', () async {
        when(
          () => mockLocalDataSource.hasWidgets(),
        ).thenThrow(Exception('Database error'));

        final result = await repository.getWidgets();

        expect(result, isA<Failure<List<DashboardWidget>>>());
        expect((result as Failure).type, FailureType.cache);
      });

      test('should return Failure when remote fetch fails', () async {
        when(
          () => mockLocalDataSource.hasWidgets(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRemoteDataSource.fetchWidgets(),
        ).thenThrow(Exception('Network error'));

        final result = await repository.getWidgets();

        expect(result, isA<Failure<List<DashboardWidget>>>());
        expect((result as Failure).type, FailureType.cache);
      });
    });

    group('saveWidgetOrder', () {
      test('should return Success when save succeeds', () async {
        when(
          () => mockLocalDataSource.saveWidgets(any()),
        ).thenAnswer((_) async {});

        final widgets = testWidgetModels.map((m) => m.toEntity()).toList();
        final result = await repository.saveWidgetOrder(widgets);

        expect(result, isA<Success<bool>>());
        expect((result as Success<bool>).data, true);
        verify(() => mockLocalDataSource.saveWidgets(any())).called(1);
      });

      test('should convert entities to models before saving', () async {
        List<DashboardWidgetModel>? capturedModels;
        when(() => mockLocalDataSource.saveWidgets(any())).thenAnswer((
          inv,
        ) async {
          capturedModels =
              inv.positionalArguments[0] as List<DashboardWidgetModel>;
        });

        const entity = DashboardWidget(
          id: 'entity-1',
          type: WidgetType.weather,
          title: 'Test',
          position: 0,
        );

        await repository.saveWidgetOrder([entity]);

        expect(capturedModels, isNotNull);
        expect(capturedModels!.first.id, 'entity-1');
        expect(capturedModels!.first, isA<DashboardWidgetModel>());
      });

      test('should return Failure when save fails', () async {
        when(
          () => mockLocalDataSource.saveWidgets(any()),
        ).thenThrow(Exception('Save error'));

        final result = await repository.saveWidgetOrder([]);

        expect(result, isA<Failure<bool>>());
        expect((result as Failure).type, FailureType.cache);
      });
    });

    group('updateWidget', () {
      test('should return Success when widget is found and updated', () async {
        when(
          () => mockLocalDataSource.getWidgets(),
        ).thenAnswer((_) async => testWidgetModels);
        when(
          () => mockLocalDataSource.saveWidgets(any()),
        ).thenAnswer((_) async {});

        const updatedWidget = DashboardWidget(
          id: 'widget-1',
          type: WidgetType.weather,
          title: 'Updated Weather',
          position: 0,
        );

        final result = await repository.updateWidget(updatedWidget);

        expect(result, isA<Success<DashboardWidget>>());
        expect(
          (result as Success<DashboardWidget>).data.title,
          'Updated Weather',
        );
        verify(() => mockLocalDataSource.saveWidgets(any())).called(1);
      });

      test('should return Failure when widget not found', () async {
        when(
          () => mockLocalDataSource.getWidgets(),
        ).thenAnswer((_) async => testWidgetModels);

        const nonExistentWidget = DashboardWidget(
          id: 'non-existent',
          type: WidgetType.weather,
          title: 'Test',
          position: 0,
        );

        final result = await repository.updateWidget(nonExistentWidget);

        expect(result, isA<Failure<DashboardWidget>>());
        expect((result as Failure).message, 'Widget not found');
      });

      test('should return Failure when exception is thrown', () async {
        when(
          () => mockLocalDataSource.getWidgets(),
        ).thenThrow(Exception('Get error'));

        const widget = DashboardWidget(
          id: 'widget-1',
          type: WidgetType.weather,
          title: 'Test',
          position: 0,
        );

        final result = await repository.updateWidget(widget);

        expect(result, isA<Failure<DashboardWidget>>());
        expect((result as Failure).type, FailureType.cache);
      });
    });

    group('resetToDefaults', () {
      test('should clear widgets and fetch from remote', () async {
        when(() => mockLocalDataSource.clearWidgets()).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.fetchWidgets(),
        ).thenAnswer((_) async => remoteWidgetModels);
        when(
          () => mockLocalDataSource.saveWidgets(any()),
        ).thenAnswer((_) async {});

        final result = await repository.resetToDefaults();

        expect(result, isA<Success<List<DashboardWidget>>>());
        final widgets = (result as Success<List<DashboardWidget>>).data;
        expect(widgets.length, 2);
        expect(widgets[0].id, 'remote-1');
        verify(() => mockLocalDataSource.clearWidgets()).called(1);
        verify(() => mockRemoteDataSource.fetchWidgets()).called(1);
        verify(() => mockLocalDataSource.saveWidgets(any())).called(1);
      });

      test('should return Failure when clear fails', () async {
        when(
          () => mockLocalDataSource.clearWidgets(),
        ).thenThrow(Exception('Clear error'));

        final result = await repository.resetToDefaults();

        expect(result, isA<Failure<List<DashboardWidget>>>());
        expect((result as Failure).type, FailureType.cache);
      });

      test('should return Failure when remote fetch fails', () async {
        when(() => mockLocalDataSource.clearWidgets()).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.fetchWidgets(),
        ).thenThrow(Exception('Fetch error'));

        final result = await repository.resetToDefaults();

        expect(result, isA<Failure<List<DashboardWidget>>>());
        expect((result as Failure).type, FailureType.cache);
      });

      test('should return Failure when save fails', () async {
        when(() => mockLocalDataSource.clearWidgets()).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.fetchWidgets(),
        ).thenAnswer((_) async => remoteWidgetModels);
        when(
          () => mockLocalDataSource.saveWidgets(any()),
        ).thenThrow(Exception('Save error'));

        final result = await repository.resetToDefaults();

        expect(result, isA<Failure<List<DashboardWidget>>>());
        expect((result as Failure).type, FailureType.cache);
      });
    });
  });
}
