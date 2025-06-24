import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'subscription.g.dart';

enum SubscriptionStatus {
  active,
  expiringSoon,
  expired,
  cancelled
}

@HiveType(typeId: 2)
class Subscription {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String planId;

  @HiveField(2)
  final String planName;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final DateTime startDate;

  @HiveField(5)
  final DateTime endDate;

  @HiveField(6)
  final SubscriptionStatus status;

  @HiveField(7)
  final String? paymentMethod;

  @HiveField(8)
  final String? transactionId;

  Subscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.paymentMethod,
    this.transactionId,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      planId: json['plan_id'] ?? '',
      planName: json['plan_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: _parseStatus(json['status']),
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'plan_name': planName,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
    };
  }

  static SubscriptionStatus _parseStatus(String? status) {
    if (status == null) return SubscriptionStatus.expired;
    
    switch (status.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expiring_soon':
        return SubscriptionStatus.expiringSoon;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      default:
        return SubscriptionStatus.expired;
    }
  }

  // Calculate days remaining until expiration
  int get daysRemaining {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  // Check if subscription is expiring soon (within 7 days)
  bool get isExpiringSoon {
    return daysRemaining <= 7 && daysRemaining > 0;
  }

  // Check if subscription is expired
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  // Format the end date as a readable string
  String get formattedEndDate {
    return DateFormat('MMMM dd, yyyy').format(endDate);
  }

  // Get the appropriate color based on subscription status
  // This will be used for the circular progress indicator
  String getStatusColor() {
    if (isExpired) return 'red';
    if (daysRemaining <= 3) return 'red';
    if (daysRemaining <= 7) return 'yellow';
    return 'green';
  }

  // Create a copy of this subscription with updated fields
  Subscription copyWith({
    String? id,
    String? planId,
    String? planName,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    SubscriptionStatus? status,
    String? paymentMethod,
    String? transactionId,
  }) {
    return Subscription(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}