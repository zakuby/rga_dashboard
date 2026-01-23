import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';
import 'package:rga_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:rga_dashboard/features/dashboard/presentation/pages/dashboard_page.dart';

class MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockDashboardCubit mockDashboardCubit;
  late MockAuthCubit mockAuthCubit;

  final sampleWidgets = [
    const DashboardWidget(
      id: 'widget-1',
      type: WidgetType.weather,
      title: 'Weather',
      order: 0,
      widgetData: WeatherData(
        location: 'San Francisco',
        temperature: 72,
        condition: 'sunny',
        humidity: 45,
      ),
    ),
    const DashboardWidget(
      id: 'widget-2',
      type: WidgetType.stockTicker,
      title: 'Stocks',
      order: 1,
    ),
  ];

  final testUser = User(
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test User',
    lastLoginAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockDashboardCubit = MockDashboardCubit();
    mockAuthCubit = MockAuthCubit();

    when(
      () => mockDashboardCubit.state,
    ).thenReturn(const DashboardState.initial());
    when(
      () => mockAuthCubit.state,
    ).thenReturn(AuthState.authenticated(testUser));
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardCubit>.value(value: mockDashboardCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: const DashboardPage(),
      ),
    );
  }

  group('DashboardPage', () {
    testWidgets('renders loading view when state is initial or loading', (
      tester,
    ) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(const DashboardState.loading());
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error view when state is failure', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(const DashboardState.failure('Test error'));
      when(() => mockDashboardCubit.loadWidgets()).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      verify(() => mockDashboardCubit.loadWidgets()).called(1);
    });

    testWidgets('renders widget list when state is loaded', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ReorderableListView), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('renders empty message when no widgets', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(const DashboardState.loaded([]));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('No widgets available'), findsOneWidget);
    });

    testWidgets('logout functionality works correctly', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));
      when(() => mockAuthCubit.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      // Tap logout button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);

      // Confirm logout
      await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
      await tester.pumpAndSettle();

      verify(() => mockAuthCubit.logout()).called(1);
    });

    testWidgets('cancel logout does not call logout', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockAuthCubit.logout());
    });
  });
}
