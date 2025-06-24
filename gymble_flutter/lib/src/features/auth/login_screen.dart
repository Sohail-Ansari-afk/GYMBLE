import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/biometric_service.dart' hide biometricServiceProvider;
import '../../app.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isBiometricAvailable = false;
  bool _useBiometric = false;
  String _biometricType = 'Biometric';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final biometricService = ref.read(biometricServiceProvider);
    final isAvailable = await biometricService.isBiometricAvailable();
    final typeName = await biometricService.getBiometricTypeName();
    
    setState(() {
      _isBiometricAvailable = isAvailable;
      _biometricType = typeName;
    });
  }

  Future<void> _authenticateWithBiometric() async {
    final biometricService = ref.read(biometricServiceProvider);
    final success = await biometricService.authenticate();
    
    if (success) {
      // TODO: Implement biometric login logic
      // For now, just navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  void _submitForm() async {
    // Validate form
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showValidationAlert('Please enter a valid email address');
      return;
    }
    
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showValidationAlert('Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Login with the auth notifier
      final success = await ref.read(authNotifierProvider).login(
        _emailController.text,
        _passwordController.text,
      );
      
      if (success) {
        // Login successful, navigation will be handled by the app.dart
        // since it's watching the auth state
      } else {
        // Login failed, show error message
        final authRepo = ref.read(authRepositoryChangeProvider);
        if (mounted && authRepo.error != null) {
          _showValidationAlert(authRepo.error!);
        }
      }
    } catch (e) {
      if (mounted) {
        _showValidationAlert('Login failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showValidationAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordSheet() {
    final resetEmailController = TextEditingController();
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Reset Password'),
        message: const Text('Enter your email to receive a password reset link'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: CupertinoTextField(
              controller: resetEmailController,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey4),
                borderRadius: BorderRadius.circular(8),
              ),
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              if (resetEmailController.text.isEmpty || !resetEmailController.text.contains('@')) {
                Navigator.of(context).pop();
                _showValidationAlert('Please enter a valid email address');
                return;
              }
              
              try {
                await ref.read(authNotifierProvider.notifier).forgotPassword(
                  resetEmailController.text,
                );
                
                if (mounted) {
                  Navigator.of(context).pop();
                  // Show confirmation
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Password Reset Email Sent'),
                      content: const Text('Please check your email for instructions to reset your password.'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  _showValidationAlert('Failed to send reset email: ${e.toString()}');
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.initial;
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(CupertinoIcons.mail, color: CupertinoColors.systemGrey),
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
                clearButtonMode: OverlayVisibilityMode.editing,
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Password',
                obscureText: _obscurePassword,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(CupertinoIcons.lock, color: CupertinoColors.systemGrey),
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              if (_isBiometricAvailable) ...[  
                const SizedBox(height: 16),
                Row(
                  children: [
                    CupertinoSwitch(
                      value: _useBiometric,
                      onChanged: (value) {
                        setState(() {
                          _useBiometric = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Use $_biometricType',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (_useBiometric)
                      GestureDetector(
                        onTap: _authenticateWithBiometric,
                        child: Icon(
                          _biometricType == 'Face ID' 
                              ? CupertinoIcons.person_crop_circle_fill
                              : CupertinoIcons.person_crop_circle,
                          size: 28,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : const Text('Login'),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Register'),
              ),
              CupertinoButton(
                onPressed: _showForgotPasswordSheet,
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}