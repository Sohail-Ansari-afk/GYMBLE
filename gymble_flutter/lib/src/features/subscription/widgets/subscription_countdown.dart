import 'package:flutter/material.dart';
import 'package:gymble_flutter/src/core/models/subscription.dart';

class SubscriptionCountdown extends StatelessWidget {
  final Subscription subscription;
  final double size;
  final double strokeWidth;
  final TextStyle? daysTextStyle;
  final TextStyle? labelTextStyle;

  const SubscriptionCountdown({
    Key? key,
    required this.subscription,
    this.size = 120.0,
    this.strokeWidth = 10.0,
    this.daysTextStyle,
    this.labelTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysRemaining = subscription.daysRemaining;
    final progress = _calculateProgress(daysRemaining);
    final color = subscription.getStatusColor();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // Days remaining text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                daysRemaining.toString(),
                style: daysTextStyle ??
                    TextStyle(
                      fontSize: size / 3,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(
                'days',
                style: labelTextStyle ??
                    TextStyle(
                      fontSize: size / 8,
                      color: Colors.grey.shade700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Calculate progress value (0.0 to 1.0) based on days remaining
  double _calculateProgress(int daysRemaining) {
    if (daysRemaining <= 0) {
      return 0.0; // Expired
    }
    
    // Assuming a standard 30-day subscription period
    // Adjust this calculation based on your subscription model
    const int totalDays = 30;
    
    // Calculate progress (capped at 1.0)
    return (daysRemaining / totalDays).clamp(0.0, 1.0);
  }
}

// A larger widget that includes the countdown and additional information
class SubscriptionCountdownCard extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionCountdownCard({
    Key? key,
    required this.subscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Subscription Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SubscriptionCountdown(subscription: subscription),
            const SizedBox(height: 16),
            Text(
              subscription.planName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Expires on ${subscription.formattedEndDate}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildStatusMessage(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage(BuildContext context) {
    final daysRemaining = subscription.daysRemaining;
    final color = subscription.getStatusColor();
    String message;

    if (subscription.isExpired) {
      message = 'Your subscription has expired. Please renew to continue.';
    } else if (subscription.isExpiringSoon) {
      message = 'Your subscription will expire soon. Renew now to avoid interruption.';
    } else {
      message = 'Your subscription is active.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(subscription.isExpired 
              ? Icons.error_outline 
              : subscription.isExpiringSoon 
                  ? Icons.warning_amber_outlined 
                  : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}