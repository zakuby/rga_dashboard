import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:rga_dashboard/features/dashboard/data/models/dashboard_widget_model.dart';
import 'package:rga_dashboard/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';

class MockDashboardLocalDataSource extends Mock
    implements DashboardLocalDataSource {}

void main() {
  late DashboardRepositoryImpl repository;
  late MockDashboardLocalDataSource mockDataSource;

  final testWidgetModels = [
    const DashboardWidgetModel(
      id: 'widget-1',
      type: WidgetType.weather,
      title: 'Weather',
      order: 0,
      widgetData: WeatherData(
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
      order: 1,
    ),
  ];

  setUp(() {
    mockDataSource = MockDashboardLocalDataSource();
    repository = DashboardRepositoryImpl(localDataSource: mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(<DashboardWidgetModel>[]);
  });

  group('DashboardRepositoryImpl', () {
    group('getWidgets', () {
      test('should return widgets when they exist in storage', () async {
        when(() => mockDataSource.hasWidgets()).thenAnswer((_) async => true);
        when(() => mockDataSource.getWidgets())
            .thenAnswer((_) async => testWidgetModels);

        final result = await repository.getWidgets();

        expect(result, isA<Success<List<DashboardWidget>>>());
        final widgets = (result as Success<List<DashboardWidget>>).data;
        expect(widgets.length, 2);
        expect(widgets[0].id, 'widget-1');
        verify(() => mockDataSource.hasWidgets()).called(1);
        verify(() => mockDataSource.getWidgets()).called(1);
      });

      test('should initialize with defaults when no widgets exist', () async {
        when(() => mockDataSource.hasWidgets()).thenAnswer((_) async => false);
        when(() => mockDataSource.saveWidgets(any())).thenAnswer((_) async {});

        final result = await repository.getWidgets();

        expect(result, isA<Success<List<DashboardWidget>>>());
        final widgets = (result as Success<List<DashboardWidget>>).data;
        expect(widgets.length, 5); // Default widgets count
        verify(() => mockDataSource.saveWidgets(any())).called(1);
      });

      test('should return Failure when exception is thrown', () async {
        when(() => mockDataSource.hasWidgets())
            .thenThrow(Exception('Database error'));

        final result = await repository.getWidgets();

        expect(result, isA<Failure<List<DashboardWidget>>>());
        expect((result as Failure).type, FailureType.cache);
      });
    });

    group('saveWidgetOrder', () {
      test('should return Success when save succeeds', () async {
        when(() => mockDataSource.saveWidgets(any())).thenAnswer((_) async {});

        final widgets = testWidgetModels.map((m) => m.toEntity()).toList();
        final result = await repository.saveWidgetOrder(widgets);

        expect(result, isA<Success<bool>>());
        expect((result as Success<bool>).data, true);
        verify(() => mockDataSource.saveWidgets(any())).called(1);
      });

      test('should convert entities to models before saving', () async {
        List<DashboardWidgetModel>? capturedModels;
        when(() => mockDataSource.saveWidgets(any())).thenAnswer((inv) async {
          capturedModels =
              inv.positionalArguments[0] as List<DashboardWidgetModel>;
        });

        const entity = DashboardWidget(
          id: 'entity-1',
          type: WidgetType.weather,
          title: 'Test',
          order: 0,
        );

        await repository.saveWidgetOrder([entity]);

        expect(capturedModels, isNotNull);
        expect(capturedModels!.first.id, 'entity-1');
        expect(capturedModels!.first, isA<DashboardWidgetModel>());
      });

      test('should return Failure when save fails', () async {
        when(() => mockDataSource.saveWidgets(any()))
            .thenThrow(Exception('Save error'));

        final result = await repository.saveWidgetOrder([]);

        expect(result, isA<Failure<bool>>());
        expect((result as Failure).type, FailureType.cache);
      });
    });

    group('updateWidget', () {
      test('should return Success when widget is found and updated', () async {
        when(() => mockDataSource.getWidgets())
            .thenAnswer((_) async => testWidgetModels);
        when(() => mockDataSource.saveWidgets(any())).thenAnswer((_) async {});

        const updatedWidget = DashboardWidget(
          id: 'widget-1',
          type: WidgetType.weather,
          title: 'Updated Weather',
          order: 0,
        );

        final result = await repository.updateWidget(updatedWidget);

        expect(result, isA<Success<DashboardWidget>>());
        expect((result as Success<DashboardWidget>).data.title,
            'Updated Weather');
        verify(() => mockDataSource.saveWidgets(any())).called(1);
      });

      test('should return Failure when widget not found', () async {
        when(() => mockDataSource.getWidgets())
            .thenAnswer((_) async => testWidgetModels);

        const nonExistentWidget = DashboardWidget(
          id: 'non-existent',
          type: WidgetType.weather,
          title: 'Test',
          order: 0,
        );

        final result = await repository.updateWidget(nonExistentWidget);

        expect(result, isA<Failure<DashboardWidget>>());
        expect((result as Failure).message, 'Widget not found');
      });

      test('should return Failure when exception is thrown', () async {
        when(() => mockDataSource.getWidgets())
            .thenThrow(Exception('Get error'));

        const widget = DashboardWidget(
          id: 'widget-1',
          type: WidgetType.weather,
          title: 'Test',
          order: 0,
        );

        final result = await repository.updateWidget(widget);

        expect(result, isA<Failure<DashboardWidget>>());
        expect((result as Failure).type, FailureType.cache);
      });
    });

    group('resetToDefaults', () {
      test('should clear widgets and save defaults', () async {
        when(() => mockDataSource.clearWidgets()).thenAnswer((_) async {});
        when(() => mockDataSource.saveWidgets(any())).thenAnswer((_) async {});

        final result = await repository.resetToDefaults();

        expect(result, isA<Success<List<DashboardWidget>>>());
        final widgets = (result as Success<List<DashboardWidget>>).data;
        expect(widgets.length, 5); // Default widgets count
        verify(() => mockDataSource.clearWidgets()).called(1);
        verify(() => mockDataSource.saveWidgets(any())).called(1);
      });

      test('should return Failure when clear fails', () async {
        when(() => mockDataSource.clearWidgets())
            .thenThrow(Exception('Clear error'));

        final result = await repository.resetToDefaults();

        expect(result, isA<Failure<List<DashboardWidget>>>());
        expect((result as Failure).type, FailureType.cache);
      });

      test('should return Failure when save fails', () async {
        when(() => mockDataSource.clearWidgets()).thenAnswer((_) async {});
        when(() => mockDataSource.saveWidgets(any()))
            .thenThrow(Exception('Save error'));

        final result = await repository.resetToDefaults();

        expect(result, isA<Failure<List<DashboardWidget>>>());
        expect((result as Failure).type, FailureType.cache);
      });
    });
  });
}
