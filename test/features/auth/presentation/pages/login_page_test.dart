import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/core/ui/ui.dart';
import 'package:rga_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:rga_dashboard/features/auth/presentation/cubit/login_cubit.dart';
import 'package:rga_dashboard/features/auth/presentation/pages/login_page.dart';
import 'package:rga_dashboard/injection.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockLoginCubit mockLoginCubit;

  setUpAll(() {
    // Allow reassignment for tests
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockLoginCubit = MockLoginCubit();

    // Register mock in GetIt
    if (getIt.isRegistered<LoginCubit>()) {
      getIt.unregister<LoginCubit>();
    }
    getIt.registerFactory<LoginCubit>(() => mockLoginCubit);

    when(() => mockAuthCubit.state).thenReturn(AuthState.unauthenticated());
    when(() => mockLoginCubit.state).thenReturn(const LoginState());
    when(() => mockLoginCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockLoginCubit.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockLoginCubit.clearErrors()).thenReturn(null);
    when(() => mockLoginCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    // Clean up after each test
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders login form with all fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('calls login when submit button is pressed', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      verify(
        () => mockLoginCubit.login(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    testWidgets('displays validation errors from state', (tester) async {
      when(() => mockLoginCubit.state).thenReturn(
        const LoginState(
          emailError: 'Please enter your email',
          passwordError: 'Please enter your password',
        ),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('calls clearErrors when input changes', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byKey(const Key('login_email_field')), 'a');
      await tester.pump();

      verify(() => mockLoginCubit.clearErrors()).called(1);
    });

    testWidgets('shows loading indicator when state is loading', (
      tester,
    ) async {
      when(
        () => mockLoginCubit.state,
      ).thenReturn(const LoginState(isLoading: true));

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<PrimaryButton>(
        find.byKey(const Key('login_submit_button')),
      );
      expect(button.isLoading, isTrue);
    });

    testWidgets('shows error snackbar on authentication failure', (
      tester,
    ) async {
      final statesController = StreamController<LoginState>.broadcast();
      when(
        () => mockLoginCubit.stream,
      ).thenAnswer((_) => statesController.stream);
      whenListen(
        mockLoginCubit,
        statesController.stream,
        initialState: const LoginState(),
      );

      await tester.pumpWidget(createTestWidget());

      statesController.add(
        const LoginState(
          errorMessage: 'Invalid email or password',
          failureType: FailureType.authentication,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Invalid email or password'), findsOneWidget);
      await statesController.close();
    });

    testWidgets('triggers checkAuthStatus on login success', (tester) async {
      final statesController = StreamController<LoginState>.broadcast();
      when(
        () => mockLoginCubit.stream,
      ).thenAnswer((_) => statesController.stream);
      whenListen(
        mockLoginCubit,
        statesController.stream,
        initialState: const LoginState(),
      );
      when(() => mockAuthCubit.checkAuthStatus()).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      statesController.add(const LoginState(isSuccess: true));
      await tester.pump();

      verify(() => mockAuthCubit.checkAuthStatus()).called(1);
      await statesController.close();
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Hint: test@example.com / password123'), findsOneWidget);
    });

    testWidgets('displays subtitle text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sign in to access your dashboard'), findsOneWidget);
    });

    testWidgets('calls login on password field submission', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password123',
      );

      // Submit password field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(
        () => mockLoginCubit.login(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    testWidgets('calls clearErrors when password input changes', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'a',
      );
      await tester.pump();

      verify(() => mockLoginCubit.clearErrors()).called(1);
    });

    testWidgets('displays email icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('displays dashboard icon in header', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
    });

    testWidgets('button shows Sign In label', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('displays email field label', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('displays password field label', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays email hint text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('displays password hint text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('shows error snackbar on network failure', (tester) async {
      final statesController = StreamController<LoginState>.broadcast();
      when(
        () => mockLoginCubit.stream,
      ).thenAnswer((_) => statesController.stream);
      whenListen(
        mockLoginCubit,
        statesController.stream,
        initialState: const LoginState(),
      );

      await tester.pumpWidget(createTestWidget());

      statesController.add(
        const LoginState(
          errorMessage: 'No internet connection',
          failureType: FailureType.network,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No internet connection'), findsOneWidget);
      await statesController.close();
    });

    testWidgets('shows error snackbar on timeout failure', (tester) async {
      final statesController = StreamController<LoginState>.broadcast();
      when(
        () => mockLoginCubit.stream,
      ).thenAnswer((_) => statesController.stream);
      whenListen(
        mockLoginCubit,
        statesController.stream,
        initialState: const LoginState(),
      );

      await tester.pumpWidget(createTestWidget());

      statesController.add(
        const LoginState(
          errorMessage: 'Request timed out',
          failureType: FailureType.timeout,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Request timed out'), findsOneWidget);
      await statesController.close();
    });

    testWidgets('does not trigger listener when success to success', (
      tester,
    ) async {
      final statesController = StreamController<LoginState>.broadcast();
      when(
        () => mockLoginCubit.stream,
      ).thenAnswer((_) => statesController.stream);
      whenListen(
        mockLoginCubit,
        statesController.stream,
        initialState: const LoginState(isSuccess: true),
      );
      when(() => mockAuthCubit.checkAuthStatus()).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      // Emit same success state again
      statesController.add(const LoginState(isSuccess: true));
      await tester.pump();

      // checkAuthStatus should not be called because listenWhen returns false
      verifyNever(() => mockAuthCubit.checkAuthStatus());
      await statesController.close();
    });

    testWidgets('does not trigger listener when error to same error', (
      tester,
    ) async {
      final statesController = StreamController<LoginState>.broadcast();
      when(
        () => mockLoginCubit.stream,
      ).thenAnswer((_) => statesController.stream);
      whenListen(
        mockLoginCubit,
        statesController.stream,
        initialState: const LoginState(
          errorMessage: 'Error',
          failureType: FailureType.authentication,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      // Emit same error state again
      statesController.add(
        const LoginState(
          errorMessage: 'Error',
          failureType: FailureType.authentication,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await statesController.close();
    });

    testWidgets('password is initially obscured', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the TextField for password
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('login_password_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.obscureText, isTrue);
    });

    testWidgets('password is visible after toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Toggle visibility
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Find the TextField for password
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('login_password_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.obscureText, isFalse);
    });

    testWidgets('button is not loading in initial state', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final button = tester.widget<PrimaryButton>(
        find.byKey(const Key('login_submit_button')),
      );
      expect(button.isLoading, isFalse);
    });

    testWidgets('displays only email error when password is valid', (
      tester,
    ) async {
      when(
        () => mockLoginCubit.state,
      ).thenReturn(const LoginState(emailError: 'Invalid email'));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Invalid email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('displays only password error when email is valid', (
      tester,
    ) async {
      when(
        () => mockLoginCubit.state,
      ).thenReturn(const LoginState(passwordError: 'Password too short'));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Password too short'), findsOneWidget);
      expect(find.text('Please enter your email'), findsNothing);
    });

    testWidgets('password toggle can be toggled back', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initial state - password obscured
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Toggle to visible
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Toggle back to obscured
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('displays lock icon in password field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });

    testWidgets('login with empty fields sends empty strings', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      verify(() => mockLoginCubit.login(email: '', password: '')).called(1);
    });
  });
}
