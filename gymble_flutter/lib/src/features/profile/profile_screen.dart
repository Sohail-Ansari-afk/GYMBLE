import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),
          
          // Account settings section
          _buildSectionHeader(context, 'Account Settings'),
          _buildSettingItem(
            context, 
            CupertinoIcons.person, 
            'Personal Information',
            onTap: () {
              // Navigate to personal info screen
              _showComingSoonAlert(context);
            },
          ),
          _buildSettingItem(
            context, 
            CupertinoIcons.lock, 
            'Security',
            onTap: () {
              // Navigate to security settings
              _showComingSoonAlert(context);
            },
          ),
          _buildSettingItem(
            context, 
            CupertinoIcons.bell, 
            'Notifications',
            onTap: () {
              // Navigate to notification settings
              _showComingSoonAlert(context);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Gym membership section
          _buildSectionHeader(context, 'Gym Membership'),
          _buildSettingItem(
            context, 
            CupertinoIcons.creditcard, 
            'Billing Information',
            onTap: () {
              // Navigate to billing info
              _showComingSoonAlert(context);
            },
          ),
          _buildSettingItem(
            context, 
            CupertinoIcons.doc_text, 
            'Membership Details',
            onTap: () {
              // Navigate to membership details
              _showComingSoonAlert(context);
            },
          ),
          
          const SizedBox(height: 24),
          
          // App settings section
          _buildSectionHeader(context, 'App Settings'),
          _buildSettingItem(
            context, 
            CupertinoIcons.globe, 
            'Language',
            onTap: () {
              // Navigate to language settings
              _showComingSoonAlert(context);
            },
          ),
          _buildSettingItem(
            context, 
            CupertinoIcons.question_circle, 
            'Help & Support',
            onTap: () {
              // Navigate to help & support
              _showComingSoonAlert(context);
            },
          ),
          
          const Spacer(),
          
          // Logout button
          Center(
            child: CupertinoButton(
              color: CupertinoColors.destructiveRed,
              onPressed: () {
                _showLogoutConfirmation(context, ref);
              },
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Row(
      children: [
        // Profile image
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            shape: BoxShape.circle,
            image: user?.profileImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(user!.profileImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: user?.profileImageUrl == null
              ? const Icon(
                  CupertinoIcons.person_fill,
                  size: 40,
                  color: CupertinoColors.systemGrey,
                )
              : null,
        ),
        const SizedBox(width: 16),
        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? 'Gymble User',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'user@example.com',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.gymName ?? 'No gym selected',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
        ),
        // Edit button
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            _showComingSoonAlert(context);
          },
          child: const Icon(
            CupertinoIcons.pencil,
            color: CupertinoColors.activeBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey5,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: CupertinoColors.activeBlue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is under development and will be available soon.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authNotifierProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}