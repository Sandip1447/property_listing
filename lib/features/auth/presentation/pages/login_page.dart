import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_listing/core/constants/app_constants.dart';
import 'package:property_listing/core/constants/auth_constants.dart';
import 'package:property_listing/core/utils/validators.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_event.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_event.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: BlocConsumer<LoginBloc, LoginState>(
                listenWhen: (LoginState previous, LoginState current) =>
                    current is LoginSuccess,
                listener: (BuildContext context, LoginState state) {
                  if (state case LoginSuccess(:final session)) {
                    context.read<AuthBloc>().add(AuthSessionChanged(session));
                  }
                },
                builder: (BuildContext context, LoginState state) {
                  final bool isLoading = state is LoginLoading;
                  return Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.home_work_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 64,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome back. Sign in to continue.',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Continue as',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<UserRole>(
                            segments: const <ButtonSegment<UserRole>>[
                              ButtonSegment<UserRole>(
                                value: UserRole.user,
                                label: Text('User'),
                                icon: Icon(Icons.person_outline),
                              ),
                              ButtonSegment<UserRole>(
                                value: UserRole.propertyOwner,
                                label: Text('Property Owner'),
                                icon: Icon(Icons.business_outlined),
                              ),
                            ],
                            selected: <UserRole>{_selectedRole},
                            onSelectionChanged: isLoading
                                ? null
                                : (Set<UserRole> selection) {
                                    setState(() {
                                      _selectedRole = selection.first;
                                    });
                                  },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            key: const Key('login_email_field'),
                            controller: _emailController,
                            autofillHints: const <String>[
                              AutofillHints.email,
                              AutofillHints.username,
                            ],
                            enabled: !isLoading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('login_password_field'),
                            controller: _passwordController,
                            autofillHints: const <String>[
                              AutofillHints.password,
                            ],
                            enabled: !isLoading,
                            obscureText: !state.isPasswordVisible,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: isLoading
                                ? null
                                : (String value) => _submit(context),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: state.isPasswordVisible
                                    ? 'Hide password'
                                    : 'Show password',
                                onPressed: isLoading
                                    ? null
                                    : () => context.read<LoginBloc>().add(
                                        const LoginPasswordVisibilityChanged(),
                                      ),
                                icon: Icon(
                                  state.isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (String? value) => Validators.required(
                              value,
                              fieldName: 'Password',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DummyCredentialsHint(role: _selectedRole),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: state is LoginFailure
                                ? Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      state.message,
                                      key: const Key('login_error'),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            key: const Key('login_submit_button'),
                            onPressed: isLoading
                                ? null
                                : () => _submit(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: isLoading
                                  ? const SizedBox.square(
                                      dimension: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Sign in'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<LoginBloc>().add(
      LoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
      ),
    );
  }
}

class _DummyCredentialsHint extends StatelessWidget {
  const _DummyCredentialsHint({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final ({String email, String password}) credentials = switch (role) {
      UserRole.user => (
        email: AuthConstants.userEmail,
        password: AuthConstants.userPassword,
      ),
      UserRole.propertyOwner => (
        email: AuthConstants.ownerEmail,
        password: AuthConstants.ownerPassword,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Demo account\n${credentials.email}\n${credentials.password}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
