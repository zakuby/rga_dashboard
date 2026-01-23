import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/presentation/design_system/design_system.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:rga_dashboard/features/auth/presentation/pages/login_page.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(const AuthState.unauthenticated());
    when(() => mockAuthCubit.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async {});
    when(() => mockAuthCubit.clearValidationErrors()).thenReturn(null);
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

      await tester.enterText(find.byKey(const Key('login_email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      verify(() => mockAuthCubit.login(email: 'test@example.com', password: 'password123')).called(1);
    });

    testWidgets('displays validation errors from state', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(
        const AuthState.validationError(
          emailError: 'Please enter your email',
          passwordError: 'Please enter your password',
        ),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('calls clearValidationErrors when input changes', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byKey(const Key('login_email_field')), 'a');
      await tester.pump();

      verify(() => mockAuthCubit.clearValidationErrors()).called(1);
    });

    testWidgets('shows loading indicator when state is loading', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState.loading());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<PrimaryButton>(find.byKey(const Key('login_submit_button')));
      expect(button.isLoading, isTrue);
    });

    testWidgets('shows error snackbar on authentication failure', (tester) async {
      final statesController = StreamController<AuthState>.broadcast();
      whenListen(mockAuthCubit, statesController.stream, initialState: const AuthState.unauthenticated());

      await tester.pumpWidget(createTestWidget());

      statesController.add(const AuthState.failure(
        message: 'Invalid email or password',
        type: FailureType.authentication,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Invalid email or password'), findsOneWidget);
      await statesController.close();
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
