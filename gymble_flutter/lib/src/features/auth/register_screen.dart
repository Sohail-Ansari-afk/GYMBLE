import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/gym.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/gym_provider.dart';
import '../../core/widgets/async_dropdown_button.dart';
import '../../app.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  Gym? _selectedGym;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load gyms when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gymNotifierProvider.notifier).refreshGyms();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // Validate form
    if (_nameController.text.isEmpty) {
      _showValidationAlert('Please enter your name');
      return;
    }
    
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showValidationAlert('Please enter a valid email address');
      return;
    }
    
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showValidationAlert('Password must be at least 6 characters');
      return;
    }
    
    if (_selectedGym == null) {
      _showValidationAlert('Please select your gym');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Register with the auth notifier
      final success = await ref.read(authNotifierProvider).register(
        _emailController.text,
        _passwordController.text,
        _selectedGym!.id,
      );
      
      if (success) {
        // Registration successful, navigation will be handled by the app.dart
        // since it's watching the auth state
      } else {
        // Registration failed, show error message
        final authRepo = ref.read(authRepositoryChangeProvider);
        if (mounted && authRepo.error != null) {
          _showValidationAlert(authRepo.error!);
        }
      }
    } catch (e) {
      if (mounted) {
        _showValidationAlert('Registration failed: ${e.toString()}');
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final gymState = ref.watch(gymNotifierProvider);
    final isLoading = authState.status == AuthStatus.initial;
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Register'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Full Name',
                keyboardType: TextInputType.name,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(CupertinoIcons.person, color: CupertinoColors.systemGrey),
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
              const SizedBox(height: 16),
              AsyncDropdownButton<Gym>(
                hint: 'Select Your Gym',
                value: _selectedGym,
                items: gymState.gyms,
                isLoading: gymState.status == GymStatus.loading,
                itemText: (gym) => gym.name,
                onChanged: (gym) {
                  setState(() {
                    _selectedGym = gym;
                  });
                },
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : const Text('Register'),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}