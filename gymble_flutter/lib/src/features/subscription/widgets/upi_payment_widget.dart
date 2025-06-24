import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiPaymentWidget extends StatelessWidget {
  final String upiId;
  final String payeeName;
  final String amount;
  final String transactionNote;
  final String? referenceId;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailure;

  const UpiPaymentWidget({
    Key? key,
    required this.upiId,
    required this.payeeName,
    required this.amount,
    required this.transactionNote,
    this.referenceId,
    this.onPaymentSuccess,
    this.onPaymentFailure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upiLink = _generateUpiLink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Code
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Scan to Pay',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: upiLink,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                embeddedImage: const AssetImage('assets/images/upi_logo.png'),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '₹$amount',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                transactionNote,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Pay with UPI Apps button
        ElevatedButton.icon(
          onPressed: () => _launchUpiApp(context),
          icon: const Icon(Icons.payment),
          label: const Text('Pay with UPI Apps'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Copy UPI ID
        OutlinedButton.icon(
          onPressed: () => _copyUpiLink(context),
          icon: const Icon(Icons.copy),
          label: const Text('Copy UPI Link'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // Generate UPI deep link
  String _generateUpiLink() {
    final params = {
      'pa': upiId, // Payee address (UPI ID)
      'pn': payeeName, // Payee name
      'am': amount, // Amount
      'tn': transactionNote, // Transaction note
      'cu': 'INR', // Currency (Indian Rupee)
    };

    // Add reference ID if provided
    if (referenceId != null && referenceId!.isNotEmpty) {
      params['tr'] = referenceId!; // Transaction reference ID
    }

    // Build the UPI link
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'upi://pay?$queryString';
  }

  // Launch UPI app
  Future<void> _launchUpiApp(BuildContext context) async {
    final upiLink = _generateUpiLink();
    final uri = Uri.parse(upiLink);

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Note: In a real app, you would implement a callback mechanism
        // to verify the payment status after the user returns from the UPI app
        if (onPaymentSuccess != null) {
          onPaymentSuccess!();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No UPI app found on your device'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (onPaymentFailure != null) {
          onPaymentFailure!();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching UPI app: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (onPaymentFailure != null) {
        onPaymentFailure!();
      }
    }
  }

  // Copy UPI link to clipboard
  void _copyUpiLink(BuildContext context) {
    final upiLink = _generateUpiLink();
    Clipboard.setData(ClipboardData(text: upiLink));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('UPI link copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// A dialog to display the UPI payment widget
class UpiPaymentDialog extends StatelessWidget {
  final String upiId;
  final String payeeName;
  final String amount;
  final String transactionNote;
  final String? referenceId;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailure;

  const UpiPaymentDialog({
    Key? key,
    required this.upiId,
    required this.payeeName,
    required this.amount,
    required this.transactionNote,
    this.referenceId,
    this.onPaymentSuccess,
    this.onPaymentFailure,
  }) : super(key: key);

  // Show the payment dialog
  static Future<void> show({
    required BuildContext context,
    required String upiId,
    required String payeeName,
    required String amount,
    required String transactionNote,
    String? referenceId,
    VoidCallback? onPaymentSuccess,
    VoidCallback? onPaymentFailure,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: UpiPaymentDialog(
                upiId: upiId,
                payeeName: payeeName,
                amount: amount,
                transactionNote: transactionNote,
                referenceId: referenceId,
                onPaymentSuccess: onPaymentSuccess,
                onPaymentFailure: onPaymentFailure,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UPI Payment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        UpiPaymentWidget(
          upiId: upiId,
          payeeName: payeeName,
          amount: amount,
          transactionNote: transactionNote,
          referenceId: referenceId,
          onPaymentSuccess: () {
            Navigator.of(context).pop();
            if (onPaymentSuccess != null) {
              onPaymentSuccess!();
            }
          },
          onPaymentFailure: onPaymentFailure,
        ),
      ],
    );
  }
}