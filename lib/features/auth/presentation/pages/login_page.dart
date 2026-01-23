import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/design_system/design_system.dart';
import '../cubit/auth_cubit.dart';

/// Login page with email/password authentication.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    context.read<AuthCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _onInputChanged() {
    context.read<AuthCubit>().clearValidationErrors();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure) {
            AppSnackbar.showError(
              context,
              message: state.errorMessage ?? 'An error occurred',
              failureType: state.failureType,
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PageHeader(
                      icon: Icons.dashboard_rounded,
                      iconSize: 80,
                      title: 'Welcome Back',
                      subtitle: 'Sign in to access your dashboard',
                    ),
                    const SizedBox(height: 48),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    _buildLoginButton(),
                    const SizedBox(height: 16),
                    _buildHintText(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return BlocSelector<AuthCubit, AuthState, String?>(
      selector: (state) => state.emailError,
      builder: (context, emailError) {
        return AppTextField(
          fieldKey: const Key('login_email_field'),
          controller: _emailController,
          label: 'Email',
          hintText: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: emailError,
          onChanged: (_) => _onInputChanged(),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return BlocSelector<AuthCubit, AuthState, String?>(
      selector: (state) => state.passwordError,
      builder: (context, passwordError) {
        return AppTextField.password(
          fieldKey: const Key('login_password_field'),
          controller: _passwordController,
          label: 'Password',
          hintText: 'Enter your password',
          obscureText: _obscurePassword,
          onToggleVisibility: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _onLoginPressed(),
          errorText: passwordError,
          onChanged: (_) => _onInputChanged(),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return SizedBox(
          height: 48,
          child: PrimaryButton(
            key: const Key('login_submit_button'),
            label: 'Sign In',
            onPressed: _onLoginPressed,
            isLoading: isLoading,
          ),
        );
      },
    );
  }

  Widget _buildHintText(ThemeData theme) {
    return Text(
      'Hint: test@example.com / password123',
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.outline,
      ),
    );
  }
}
