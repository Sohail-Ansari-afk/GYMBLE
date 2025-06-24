import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymble_flutter/src/core/models/subscription.dart';
import 'package:gymble_flutter/src/core/providers/subscription_provider.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final hasSubscription = ref.watch(hasActiveSubscriptionProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payments',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildCurrentPlan(context, ref, subscriptionState.subscription, hasSubscription),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment History',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFFF8BBD0), // Frost pink color
                    ),
                  ),
                  onPressed: () {
                    _showAllPayments(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildPaymentHistory(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlan(BuildContext context, WidgetRef ref, Subscription? subscription, bool hasSubscription) {
    if (subscription == null || !hasSubscription) {
      return _buildNoSubscriptionCard(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey5),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Plan',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(subscription).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(subscription),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  _getStatusText(subscription),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(subscription),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subscription.planName,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${subscription.price.toStringAsFixed(2)}/${_getPlanDuration(subscription)}',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.isExpired ? 'Expired On' : 'Next Payment',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscription.formattedEndDate,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFF8BBD0), // Frost pink color
                borderRadius: BorderRadius.circular(8),
                onPressed: () {
                  Navigator.pushNamed(context, '/subscription');
                },
                child: Text(
                  'Manage Subscription',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey5),
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
          Text(
            'No Active Subscription',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Subscribe to a plan to access premium features',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: const Color(0xFFF8BBD0), // Frost pink color
              borderRadius: BorderRadius.circular(8),
              onPressed: () {
                Navigator.pushNamed(context, '/plans');
              },
              child: Text(
                'View Plans',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(BuildContext context) {
    final payments = [
      {
        'date': '2025-05-15',
        'amount': 49.99,
        'status': 'Paid',
        'method': 'Credit Card',
      },
      {
        'date': '2025-04-15',
        'amount': 49.99,
        'status': 'Paid',
        'method': 'Credit Card',
      },
      {
        'date': '2025-03-15',
        'amount': 49.99,
        'status': 'Paid',
        'method': 'Credit Card',
      },
      {
        'date': '2025-02-15',
        'amount': 49.99,
        'status': 'Paid',
        'method': 'Credit Card',
      },
    ];

    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final date = DateFormat('yyyy-MM-dd').parse(payment['date'] as String);
        final formattedDate = DateFormat('MMM dd, yyyy').format(date);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.systemGrey5,
                width: 0.5,
              ),
            ),
          ),
          child: CupertinoListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                CupertinoIcons.creditcard,
                color: Color(0xFFF8BBD0), // Frost pink color
              ),
            ),
            title: Text(
              'Premium Plan',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              formattedDate,
              style: GoogleFonts.inter(
                color: CupertinoColors.systemGrey,
                fontSize: 14,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${payment['amount']}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    payment['status'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: CupertinoColors.activeGreen,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              _showPaymentDetails(context, payment, formattedDate);
            },
          ),
        );
      },
    );
  }

  void _showAllPayments(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Payment History'),
        message: const Text('View your complete payment history or filter by date'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement view all payments
            },
            child: const Text('View All Payments'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement filter by date
            },
            child: const Text('Filter by Date'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement download receipts
            },
            child: const Text('Download Receipts'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showPaymentDetails(BuildContext context, Map<String, dynamic> payment, String formattedDate) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          children: [
            const SizedBox(height: 8),
            _buildDetailRow('Plan', 'Premium Plan'),
            _buildDetailRow('Date', formattedDate),
            _buildDetailRow('Amount', '₹${payment['amount']}'),
            _buildDetailRow('Status', payment['status'] as String),
            _buildDetailRow('Payment Method', payment['method'] as String),
            _buildDetailRow('Transaction ID', 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement download receipt
            },
            child: const Text('Download Receipt'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(),
          ),
        ],
      ),
    );
  }

  // Helper methods for subscription status
  String _getStatusText(Subscription subscription) {
    if (subscription.isExpired) {
      return 'Expired';
    } else if (subscription.isExpiringSoon) {
      return 'Expiring Soon';
    } else {
      return 'Active';
    }
  }

  Color _getStatusColor(Subscription subscription) {
    if (subscription.isExpired) {
      return CupertinoColors.systemRed;
    } else if (subscription.isExpiringSoon) {
      return CupertinoColors.systemOrange;
    } else {
      return CupertinoColors.activeGreen;
    }
  }

  String _getPlanDuration(Subscription subscription) {
    // This is a placeholder - in a real app, you would determine this from the plan type
    return 'month';
  }
}