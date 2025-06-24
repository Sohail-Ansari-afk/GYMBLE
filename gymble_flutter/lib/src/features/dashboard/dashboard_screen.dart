import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use CupertinoPageScaffold instead of Scaffold
    // The navigation bar is handled by the parent CupertinoTabScaffold in app.dart
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Gymble',
              style: GoogleFonts.inter(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatsCard(context),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            _buildRecentActivities(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: GoogleFonts.inter(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Check-ins', '12'),
              _buildStatItem('Workouts', '8'),
              _buildStatItem('Classes', '4'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18, 
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(context, 'Check-in', CupertinoIcons.location),
            _buildActionButton(context, 'Book Class', CupertinoIcons.calendar_badge_plus),
            _buildActionButton(context, 'View Plan', CupertinoIcons.doc_text),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Show action sheet on tap (iOS style)
        showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
            title: Text(label),
            message: Text('Would you like to proceed with $label?'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement action
                },
                child: const Text('Proceed'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: CupertinoColors.white),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.inter(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: GoogleFonts.inter(
            fontSize: 18, 
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildActivityItem(context, 'Checked in at Main Gym', '2 hours ago'),
        _buildActivityItem(context, 'Attended Yoga Class', 'Yesterday'),
        _buildActivityItem(context, 'Renewed Monthly Plan', '3 days ago'),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, String activity, String time) {
    return GestureDetector(
      onLongPress: () {
        // Show context menu on long press (iOS style)
        showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement view details
                },
                child: const Text('View Details'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement share
                },
                child: const Text('Share'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(CupertinoIcons.clock, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity,
                    style: GoogleFonts.inter(),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      color: CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}