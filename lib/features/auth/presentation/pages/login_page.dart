import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/ui.dart';
import '../../../../injection.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/login_cubit.dart';

/// Login page with email/password authentication.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: const _LoginPageContent(),
    );
  }
}

class _LoginPageContent extends StatefulWidget {
  const _LoginPageContent();

  @override
  State<_LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<_LoginPageContent> {
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
    context.read<LoginCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _onInputChanged() {
    context.read<LoginCubit>().clearErrors();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            // Trigger auth check to navigate to dashboard
            context.read<AuthCubit>().checkAuthStatus();
          } else if (state.hasError) {
            AppSnackbar.showError(
              context,
              message: state.errorMessage!,
              failureType: state.failureType,
            );
          }
        },
        listenWhen: (previous, current) =>
            (!previous.isSuccess && current.isSuccess) ||
            (!previous.hasError && current.hasError),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingXl,
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
                    const SizedBox(height: AppSpacing.xxxl),
                    _buildEmailField(),
                    AppSpacing.gapVerticalLg,
                    _buildPasswordField(),
                    AppSpacing.gapVerticalXl,
                    _buildLoginButton(),
                    AppSpacing.gapVerticalLg,
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
    return BlocSelector<LoginCubit, LoginState, String?>(
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
    return BlocSelector<LoginCubit, LoginState, String?>(
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
    return BlocSelector<LoginCubit, LoginState, bool>(
      selector: (state) => state.isLoading,
      builder: (context, isLoading) {
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
