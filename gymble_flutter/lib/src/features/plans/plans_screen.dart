import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymble_flutter/src/core/models/subscription.dart';
import 'package:gymble_flutter/src/core/providers/subscription_provider.dart';
import 'package:gymble_flutter/src/features/subscription/widgets/upi_payment_widget.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membership Plans',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the plan that works best for you',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildPlansList(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, WidgetRef ref) {
    final plans = [
      {
        'id': 'basic_monthly',
        'name': 'Basic',
        'price': 2999,
        'duration': 'Monthly',
        'features': [
          'Access to main gym area',
          'Standard equipment usage',
          'Locker access',
          'Online workout tracking',
        ],
        'isPopular': false,
      },
      {
        'id': 'premium_monthly',
        'name': 'Premium',
        'price': 4999,
        'duration': 'Monthly',
        'features': [
          'Full gym access',
          'Group fitness classes',
          'Personal trainer (1 session/month)',
          'Nutrition consultation',
          'Locker and towel service',
        ],
        'isPopular': true,
      },
      {
        'id': 'annual',
        'name': 'Annual',
        'price': 29999,
        'duration': 'Yearly',
        'features': [
          'All Premium features',
          'Significant savings vs monthly',
          'Guest passes (2 per month)',
          'Priority booking for classes',
          'Exclusive member events',
        ],
        'isPopular': false,
      },
      {
        'id': 'family_monthly',
        'name': 'Family',
        'price': 8999,
        'duration': 'Monthly',
        'features': [
          'Access for up to 4 family members',
          'All Premium features',
          'Family fitness classes',
          'Shared personal training sessions',
          'Family locker area',
        ],
        'isPopular': false,
      },
    ];

    return ListView.builder(
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return _buildPlanCard(plan, context, ref);
      },
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: plan['isPopular']
              ? const Color(0xFFF8BBD0) // Frost pink color
              : CupertinoColors.systemGrey5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey6,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: plan['isPopular']
                  ? const Color(0xFFF8BBD0).withOpacity(0.1) // Frost pink color
                  : CupertinoColors.systemGrey6,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['name'],
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: plan['isPopular']
                            ? const Color(0xFFF8BBD0) // Frost pink color
                            : CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${(plan['price'] / 100).toStringAsFixed(2)} ${plan['duration']}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                if (plan['isPopular'])
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8BBD0), // Frost pink color
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Popular',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Plan features
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  (plan['features'] as List).length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: CupertinoColors.activeGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            plan['features'][index],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: CupertinoColors.label,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: () {
                      _showPlanDetails(context, plan, ref);
                    },
                    color: const Color(0xFFF8BBD0), // Frost pink color
                    child: Text(
                      'Select Plan',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanDetails(BuildContext context, Map<String, dynamic> plan, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('${plan['name']} Plan'),
        message: Text(
          'Would you like to subscribe to the ${plan['name']} plan for ₹${(plan['price'] / 100).toStringAsFixed(2)} ${plan['duration']}?',
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentOptions(context, plan, ref);
            },
            child: const Text('Subscribe Now'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement comparison
            },
            child: const Text('Compare Plans'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, Map<String, dynamic> plan, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CupertinoColors.systemBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Payment Method',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred payment method to continue with the subscription.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 24),
            _buildPaymentOption(
              icon: CupertinoIcons.money_dollar_circle,
              title: 'UPI Payment',
              subtitle: 'Pay using any UPI app',
              onTap: () {
                Navigator.pop(context);
                _showUpiPaymentDialog(context, plan, ref);
              },
            ),
            const Divider(height: 1),
            _buildPaymentOption(
              icon: CupertinoIcons.creditcard,
              title: 'Credit/Debit Card',
              subtitle: 'Pay using your card',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement card payment
                _processSubscription(context, plan, ref, 'Card');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8BBD0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFF8BBD0),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showUpiPaymentDialog(BuildContext context, Map<String, dynamic> plan, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => UpiPaymentDialog(
        amount: plan['price'] / 100,
        description: '${plan['name']} Plan Subscription',
        onPaymentComplete: (success) {
          Navigator.pop(context);
          if (success) {
            _processSubscription(context, plan, ref, 'UPI');
          }
        },
      ),
    );
  }

  void _processSubscription(BuildContext context, Map<String, dynamic> plan, WidgetRef ref, String paymentMethod) {
    // Create a new subscription
    final now = DateTime.now();
    final endDate = plan['duration'] == 'Monthly'
        ? DateTime(now.year, now.month + 1, now.day)
        : DateTime(now.year + 1, now.month, now.day);

    final subscription = Subscription(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      planId: plan['id'],
      planName: plan['name'],
      price: plan['price'] / 100,
      startDate: now,
      endDate: endDate,
      status: SubscriptionStatus.active,
      paymentMethod: paymentMethod,
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Save the subscription using the provider
    ref.read(subscriptionProvider.notifier).renewSubscription(subscription);

    // Show success dialog
    _showSuccessDialog(context, plan);
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> plan) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Subscription Successful'),
        content: Text(
          'You have successfully subscribed to the ${plan['name']} plan. Your membership is now active.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('View Subscription'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}