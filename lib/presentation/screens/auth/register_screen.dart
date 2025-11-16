import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_extraction_app/core/utils/validators.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_cubit.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _showError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() {
      _errorMessage = null;
      _showError = false;
    });

    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
    }
  }

  String _getFriendlyErrorMessage(String error) {
    error = error.replaceAll('Exception: ', '');

    if (error.contains('email-already-in-use') ||
        error.contains('already exists')) {
      return 'This email is already registered. Try logging in instead.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return error;
    }
  }

  IconData _getErrorIcon(String error) {
    if (error.contains('email-already-in-use') ||
        error.contains('already exists')) {
      return Icons.person_add_disabled;
    } else if (error.contains('weak-password')) {
      return Icons.shield_outlined;
    } else if (error.contains('network')) {
      return Icons.wifi_off;
    } else {
      return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Account created successfully! Welcome!'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                    'Registration Failed',
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
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icons.person_outlined,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),

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
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword);
                        },
                      ),
                      validator: (value) =>
                          Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password must contain:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildRequirement('At least 6 characters'),
                          _buildRequirement('At least one letter'),
                          _buildRequirement('At least one number'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      onPressed: isLoading ? null : _handleRegister,
                      text: 'Register',
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Login'),
                        ),
                      ],
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

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }
}