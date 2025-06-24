import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymble_flutter/src/core/models/subscription.dart';
import 'package:gymble_flutter/src/core/providers/subscription_provider.dart';
import 'package:gymble_flutter/src/features/subscription/widgets/subscription_countdown.dart';
import 'package:gymble_flutter/src/features/subscription/widgets/upi_payment_widget.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch subscription data when the screen loads
    Future.microtask(() => ref.read(subscriptionProvider.notifier).fetchCurrentSubscription());
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscription'),
        backgroundColor: const Color(0xFFF8BBD0), // Frost pink color
      ),
      body: _buildBody(subscriptionState),
    );
  }

  Widget _buildBody(SubscriptionState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(subscriptionProvider.notifier).fetchCurrentSubscription(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final subscription = state.subscription;
    if (subscription == null) {
      return _buildNoSubscriptionView();
    }

    return _buildSubscriptionView(subscription);
  }

  Widget _buildNoSubscriptionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.subscriptions_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Active Subscription',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Subscribe to a plan to access premium features',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to plans screen
              Navigator.pushNamed(context, '/plans');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8BBD0), // Frost pink color
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionView(Subscription subscription) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subscription countdown card
          SubscriptionCountdownCard(subscription: subscription),
          const SizedBox(height: 24),
          
          // Plan details card
          _buildPlanDetailsCard(subscription),
          const SizedBox(height: 24),
          
          // Action buttons
          _buildActionButtons(subscription),
        ],
      ),
    );
  }

  Widget _buildPlanDetailsCard(Subscription subscription) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow('Plan', subscription.planName),
            _buildDetailRow('Price', '₹${subscription.price.toStringAsFixed(2)}'),
            _buildDetailRow('Start Date', _formatDate(subscription.startDate)),
            _buildDetailRow('End Date', _formatDate(subscription.endDate)),
            _buildDetailRow('Status', _getStatusText(subscription)),
            _buildDetailRow('Payment Method', subscription.paymentMethod),
            if (subscription.transactionId != null)
              _buildDetailRow('Transaction ID', subscription.transactionId!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Subscription subscription) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (subscription.isExpiringSoon || subscription.isExpired)
          ElevatedButton.icon(
            onPressed: () => _showRenewSubscriptionDialog(subscription),
            icon: const Icon(Icons.refresh),
            label: const Text('Renew Subscription'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8BBD0), // Frost pink color
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        const SizedBox(height: 12),
        if (!subscription.isExpired)
          OutlinedButton.icon(
            onPressed: () => _showCancelSubscriptionDialog(),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel Subscription'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
      ],
    );
  }

  void _showRenewSubscriptionDialog(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renew Subscription'),
        content: const Text('Would you like to renew your subscription for another period?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentOptions(subscription);
            },
            child: const Text('Renew'),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? You will still have access until the end date.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSubscription();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPaymentOptions(Subscription subscription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Payment Options',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('UPI Payment'),
              subtitle: const Text('Pay using any UPI app'),
              onTap: () {
                Navigator.pop(context);
                _showUpiPayment(subscription);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit/Debit Card'),
              subtitle: const Text('Pay using card'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement card payment
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card payment not implemented yet')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showUpiPayment(Subscription subscription) {
    UpiPaymentDialog.show(
      context: context,
      upiId: 'example@upi', // Replace with actual UPI ID
      payeeName: 'GYMBLE Fitness',
      amount: subscription.price.toString(),
      transactionNote: 'Renewal of ${subscription.planName}',
      referenceId: 'SUB${DateTime.now().millisecondsSinceEpoch}',
      onPaymentSuccess: () {
        // Handle successful payment
        _verifyPayment(subscription);
      },
      onPaymentFailure: () {
        // Handle payment failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _verifyPayment(Subscription subscription) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verifying payment...'),
          ],
        ),
      ),
    );

    // Simulate payment verification
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Call the provider to renew subscription
        ref.read(subscriptionProvider.notifier).renewSubscription(
          subscription.id,
          subscription.planId,
          subscription.price,
        ).then((_) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription renewed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }).catchError((error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error renewing subscription: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    });
  }

  void _cancelSubscription() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing cancellation...'),
          ],
        ),
      ),
    );

    // Call the provider to cancel subscription
    ref.read(subscriptionProvider.notifier).cancelSubscription().then((_) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription cancelled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }).catchError((error) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling subscription: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(Subscription subscription) {
    if (subscription.isExpired) {
      return 'Expired';
    } else if (subscription.isExpiringSoon) {
      return 'Expiring Soon';
    } else {
      return 'Active';
    }
  }
}