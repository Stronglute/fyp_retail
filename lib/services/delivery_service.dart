/// Delivery status states
enum DeliveryStatus { pending, confirmed, shipped, enRoute, delivered }

/// Model for delivery event
class DeliveryEvent {
  final DeliveryStatus status;
  final DateTime timestamp;
  final String description;
  DeliveryEvent({
    required this.status,
    required this.timestamp,
    required this.description,
  });
}

/// Service to fetch delivery events for an order (mock implementation)
class DeliveryService {
  /// Simulate fetching delivery history for orderId in real-time
  Stream<List<DeliveryEvent>> getDeliveryHistory(String orderId) async* {
    final events = <DeliveryEvent>[];
    final allEvents = [
      DeliveryEvent(
        status: DeliveryStatus.pending,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        description: 'Order placed',
      ),
      DeliveryEvent(
        status: DeliveryStatus.confirmed,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        description: 'Payment confirmed',
      ),
      DeliveryEvent(
        status: DeliveryStatus.shipped,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        description: 'Package shipped',
      ),
      DeliveryEvent(
        status: DeliveryStatus.enRoute,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        description: 'Out for delivery',
      ),
      DeliveryEvent(
        status: DeliveryStatus.delivered,
        timestamp: DateTime.now(),
        description: 'Delivered to customer',
      ),
    ];

    for (final event in allEvents) {
      await Future<void>.delayed(const Duration(seconds: 2));
      events.add(event);
      yield List<DeliveryEvent>.from(events);
    }
  }
}
