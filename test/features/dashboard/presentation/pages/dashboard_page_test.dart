import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/theme/theme_cubit.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';
import 'package:rga_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:rga_dashboard/features/dashboard/domain/entities/dashboard_widget.dart';
import 'package:rga_dashboard/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:rga_dashboard/features/dashboard/presentation/pages/dashboard_page.dart';

class MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockThemeCubit extends MockCubit<ThemeMode> implements ThemeCubit {
  @override
  bool isDarkMode(BuildContext context) => state == ThemeMode.dark;
}

void main() {
  late MockDashboardCubit mockDashboardCubit;
  late MockAuthCubit mockAuthCubit;
  late MockThemeCubit mockThemeCubit;

  final sampleWidgets = [
    const DashboardWidget(
      id: 'widget-1',
      type: WidgetType.weather,
      title: 'Weather',
      position: 0,
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
      position: 1,
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
    mockThemeCubit = MockThemeCubit();

    when(() => mockDashboardCubit.state).thenReturn(DashboardState.initial());
    when(() => mockDashboardCubit.loadWidgets()).thenAnswer((_) async {});
    when(
      () => mockAuthCubit.state,
    ).thenReturn(AuthState.authenticated(testUser));
    when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          BlocProvider<DashboardCubit>.value(value: mockDashboardCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: const DashboardPage(),
      ),
    );
  }

  group('DashboardPage', () {
    testWidgets('renders skeleton loading view when state is loading', (
      tester,
    ) async {
      when(() => mockDashboardCubit.state).thenReturn(DashboardState.loading());
      await tester.pumpWidget(createTestWidget());
      // SkeletonLoadingView contains multiple SkeletonCard widgets
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders error view when state is failure', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.failure('Test error'));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Clear the call from initState before testing retry
      clearInteractions(mockDashboardCubit);

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
      expect(find.text('Hi, Test User'), findsOneWidget);
    });

    testWidgets('renders empty message when no widgets', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded([]));

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

    testWidgets('displays default user name when no user', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));
      when(() => mockAuthCubit.state).thenReturn(AuthState.unauthenticated());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Hi, User'), findsOneWidget);
    });

    testWidgets('theme toggle switch is displayed', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('theme toggle calls toggleTheme', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));
      when(() => mockThemeCubit.toggleTheme()).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(Switch));
      await tester.pump();

      verify(() => mockThemeCubit.toggleTheme()).called(1);
    });

    testWidgets('reorder widgets calls reorderWidgets', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));
      when(
        () => mockDashboardCubit.reorderWidgets(any(), any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      // Find the ReorderableListView
      expect(find.byType(ReorderableListView), findsOneWidget);

      // Simulate drag from index 0 to index 1
      final firstItem = find.byKey(const ValueKey('widget-1'));
      expect(firstItem, findsOneWidget);

      // Perform long press drag
      final gesture = await tester.startGesture(tester.getCenter(firstItem));
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      verify(() => mockDashboardCubit.reorderWidgets(any(), any())).called(1);
    });

    testWidgets('reordering state still shows widgets', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.reordering(sampleWidgets));

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ReorderableListView), findsOneWidget);
    });

    testWidgets('initial state renders skeleton loading', (tester) async {
      when(() => mockDashboardCubit.state).thenReturn(DashboardState.initial());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('logout button has tooltip', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));

      await tester.pumpWidget(createTestWidget());

      final logoutButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.logout),
      );
      expect(logoutButton.tooltip, 'Logout');
    });

    testWidgets('logout dialog has correct title', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsWidgets);
    });

    testWidgets('uses default error message when errorMessage is null', (
      tester,
    ) async {
      when(() => mockDashboardCubit.state).thenReturn(
        const DashboardState(
          status: DashboardStatus.failure,
          errorMessage: null,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('loads widgets on init', (tester) async {
      await tester.pumpWidget(createTestWidget());

      verify(() => mockDashboardCubit.loadWidgets()).called(1);
    });

    testWidgets('switch shows correct state in light mode', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));
      when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);

      await tester.pumpWidget(createTestWidget());

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('switch shows correct state in dark mode', (tester) async {
      when(
        () => mockDashboardCubit.state,
      ).thenReturn(DashboardState.loaded(sampleWidgets));
      when(() => mockThemeCubit.state).thenReturn(ThemeMode.dark);

      await tester.pumpWidget(createTestWidget());

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });
  });
}
