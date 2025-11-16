import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_extraction_app/core/utils/validators.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_cubit.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(_emailController.text.trim());
    }
  }

  String _getFriendlyErrorMessage(String error) {
    error = error.replaceAll('Exception: ', '');

    if (error.contains('user-not-found') || error.contains('No account found')) {
      return 'No account found with this email address.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return error;
    }
  }

  IconData _getErrorIcon(String error) {
    if (error.contains('user-not-found') || error.contains('No account found')) {
      return Icons.person_off;
    } else if (error.contains('too-many-requests')) {
      return Icons.block;
    } else if (error.contains('network')) {
      return Icons.wifi_off;
    } else {
      return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: BlocConsumer<AuthCubit, AuthenState>(
        listener: (context, state) {
          if (state is AuthError) {
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
          } else if (state is AuthPasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Password reset email sent! Check your inbox.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final hasError = state is AuthError;
          final errorMessage = hasError ? _getFriendlyErrorMessage(state.message) : null;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 100,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.lock_reset, size: 100, color: Colors.blueAccent),
                    const SizedBox(height: 24),
                    Text(
                      'Forgot Your Password?',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    if (hasError && errorMessage != null)
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
                              _getErrorIcon(state.message),
                              color: Colors.red.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reset Failed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    errorMessage,
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
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
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: isLoading ? null : _handleResetPassword,
                      text: 'Send Reset Link',
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}