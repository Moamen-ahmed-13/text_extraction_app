import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_extraction_app/core/utils/validators.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_cubit.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_state.dart';
import 'package:text_extraction_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:text_extraction_app/presentation/screens/auth/register_screen.dart';
import 'package:text_extraction_app/presentation/widgets/custom_button.dart';
import 'package:text_extraction_app/presentation/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _showError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _errorMessage = null;
      _showError = false;
    });

    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  String _getFriendlyErrorMessage(String error) {
    error = error.replaceAll('Exception: ', '');

    if (error.contains('user-not-found') || error.contains('No user found')) {
      return 'No account found with this email address.';
    } else if (error.contains('wrong-password') ||
        error.contains('Wrong password') ||
        error.contains('invalid-credential')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return error;
    }
  }

  IconData _getErrorIcon(String error) {
    if (error.contains('user-not-found') || error.contains('No user found')) {
      return Icons.person_off;
    } else if (error.contains('wrong-password') ||
        error.contains('Wrong password') ||
        error.contains('invalid-credential')) {
      return Icons.lock_outline;
    } else if (error.contains('network')) {
      return Icons.wifi_off;
    } else {
      return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthenState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _errorMessage = _getFriendlyErrorMessage(state.message);
              _showError = true;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      _getErrorIcon(state.message),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_getFriendlyErrorMessage(state.message)),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.document_scanner,
                        size: 100,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Text Extractor',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Extract text from images with AI',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      if (_showError && _errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getErrorIcon(_errorMessage!),
                                color: Colors.red.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Login Failed',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade900,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                iconSize: 20,
                                color: Colors.red.shade700,
                                onPressed: () {
                                  setState(() {
                                    _showError = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter your password',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: Validators.validatePasswordSimple,
                      ),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        onPressed: isLoading ? null : _handleLogin,
                        text: 'Login',
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}