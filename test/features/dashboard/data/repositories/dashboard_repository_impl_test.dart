import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
    group('fetchRemoteWidgets', () {
      test('should fetch widgets from remote data source', () async {
        when(
          () => mockRemoteDataSource.fetchWidgets(),
        ).thenAnswer((_) async => remoteWidgetModels);

        final result = await repository.fetchRemoteWidgets();

        expect(result.length, 1);
        expect(result[0].id, 'remote-1');
        verify(() => mockRemoteDataSource.fetchWidgets()).called(1);
      });

      test('should convert models to entities', () async {
        when(
          () => mockRemoteDataSource.fetchWidgets(),
        ).thenAnswer((_) async => testWidgetModels);

        final result = await repository.fetchRemoteWidgets();

        expect(result, isA<List<DashboardWidget>>());
        expect(result[0], isA<DashboardWidget>());
      });

      test('should throw when remote fetch fails', () async {
        when(
          () => mockRemoteDataSource.fetchWidgets(),
        ).thenThrow(Exception('Network error'));

        expect(
          () => repository.fetchRemoteWidgets(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getLocalWidgets', () {
      test('should get widgets from local data source', () async {
        when(
          () => mockLocalDataSource.getWidgets(),
        ).thenAnswer((_) async => testWidgetModels);

        final result = await repository.getLocalWidgets();

        expect(result.length, 2);
        expect(result[0].id, 'widget-1');
        verify(() => mockLocalDataSource.getWidgets()).called(1);
      });

      test('should return empty list when no local widgets', () async {
        when(
          () => mockLocalDataSource.getWidgets(),
        ).thenAnswer((_) async => []);

        final result = await repository.getLocalWidgets();

        expect(result, isEmpty);
      });
    });

    group('saveWidgets', () {
      test('should save widgets to local data source', () async {
        when(
          () => mockLocalDataSource.saveWidgets(any()),
        ).thenAnswer((_) async {});

        final widgets = testWidgetModels.map((m) => m.toEntity()).toList();
        await repository.saveWidgets(widgets);

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

        await repository.saveWidgets([entity]);

        expect(capturedModels, isNotNull);
        expect(capturedModels!.first.id, 'entity-1');
      });

      test('should throw when save fails', () async {
        when(
          () => mockLocalDataSource.saveWidgets(any()),
        ).thenThrow(Exception('Save error'));

        expect(() => repository.saveWidgets([]), throwsA(isA<Exception>()));
      });
    });

    group('clearWidgets', () {
      test('should clear widgets from local data source', () async {
        when(() => mockLocalDataSource.clearWidgets()).thenAnswer((_) async {});

        await repository.clearWidgets();

        verify(() => mockLocalDataSource.clearWidgets()).called(1);
      });
    });

    group('hasLocalWidgets', () {
      test('should return true when local widgets exist', () async {
        when(
          () => mockLocalDataSource.hasWidgets(),
        ).thenAnswer((_) async => true);

        final result = await repository.hasLocalWidgets();

        expect(result, isTrue);
      });

      test('should return false when no local widgets', () async {
        when(
          () => mockLocalDataSource.hasWidgets(),
        ).thenAnswer((_) async => false);

        final result = await repository.hasLocalWidgets();

        expect(result, isFalse);
      });
    });
  });
}
