import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../app.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Validate form using manual validation since CupertinoTextField doesn't have built-in validation
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showValidationAlert('Please enter a valid email address');
      return;
    }
    
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showValidationAlert('Password must be at least 6 characters');
      return;
    }

    // TODO: Implement authentication logic
    if (_isLogin) {
      // Login logic
      print('Login with: ${_emailController.text}');
      // Navigate to home page on successful login
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Register logic
      print('Register with: ${_emailController.text}');
      // Show success sheet and then navigate to home
      _showSuccessSheet();
    }
  }

  void _showValidationAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Validation Error'),
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

  void _showSuccessSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Registration Successful'),
        message: const Text('Your account has been created successfully.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => const HomePage()),
              );
            },
            child: const Text('Continue to App'),
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isLogin ? 'Login' : 'Register'),
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
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: _submitForm,
                child: Text(_isLogin ? 'Login' : 'Register'),
              ),
              CupertinoButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin
                    ? 'Don\'t have an account? Register'
                    : 'Already have an account? Login'),
              ),
              // Add forgot password option for login mode
              if (_isLogin)
                CupertinoButton(
                  onPressed: () {
                    // Show forgot password sheet
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => _buildForgotPasswordSheet(),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordSheet() {
    final resetEmailController = TextEditingController();
    
    return CupertinoActionSheet(
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
          onPressed: () {
            // TODO: Implement password reset logic
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
          },
          child: const Text('Send Reset Link'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    );
  }
}