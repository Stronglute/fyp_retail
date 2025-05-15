import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../providers/delivery_provider.dart';
import '../services/delivery_service.dart';

class DeliveryTrackingScreen extends ConsumerWidget {
  final String orderId;
  const DeliveryTrackingScreen({Key? key, required this.orderId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync = ref.watch(deliveryTrackingProvider(orderId));
    final historyAsync = ref.watch(deliveryHistoryProvider(orderId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: trackingAsync.when(
        data: (trackingData) {
          return historyAsync.when(
            data: (events) {
              final currentEvent = events.last;
              final currentIndex = events.indexOf(currentEvent);
              final deliveryPerson =
                  trackingData['deliveryPerson'] as Map<String, dynamic>;
              final estimatedTime = trackingData['estimatedDeliveryTime'].toDate();
              final currentLocation =
                  trackingData['currentLocation'] as Map<String, dynamic>;

              return Column(
                children: [
                  // Delivery info card with current status
                  _buildDeliveryInfoCard(
                    currentEvent,
                    deliveryPerson,
                    estimatedTime,
                  ),

                  // Map view
                  SizedBox(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          currentLocation['lat'],
                          currentLocation['lng'],
                        ),
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('delivery_person'),
                          position: LatLng(
                            currentLocation['lat'],
                            currentLocation['lng'],
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          ),
                          infoWindow: const InfoWindow(
                            title: 'Your order is on the way',
                          ),
                        ),
                      },
                    ),
                  ),

                  // Timeline of all statuses
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final isCurrent = index == currentIndex;
                        final isCompleted = index < currentIndex;

                        return _buildTimelineItem(
                          event: event,
                          isFirst: index == 0,
                          isLast: index == events.length - 1,
                          isCurrent: isCurrent,
                          isCompleted: isCompleted,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading:
                () => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade800,
                    ),
                  ),
                ),
            error:
                (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading delivery details',
                        style: TextStyle(color: Colors.red[400], fontSize: 18),
                      ),
                    ],
                  ),
                ),
          );
        },
        loading:
            () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade800,
                ),
              ),
            ),
        error:
            (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading tracking information',
                    style: TextStyle(color: Colors.red[400], fontSize: 18),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildDeliveryInfoCard(
    DeliveryEvent currentEvent,
    Map<String, dynamic> deliveryPerson,
    DateTime estimatedTime,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current status row
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(currentEvent.status),
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      _statusToString(currentEvent.status),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Estimated delivery time
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.green[800], size: 20),
              const SizedBox(width: 8),
              Text(
                'Estimated delivery:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                DateFormat.jm().format(estimatedTime),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Delivery person info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.person, color: Colors.green[800]),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deliveryPerson['name'] ?? 'Delivery Partner',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Contact: ${deliveryPerson['phone'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              if (deliveryPerson['phone'] != null)
                IconButton(
                  icon: Icon(Icons.phone, color: Colors.green[800]),
                  onPressed: () => _callDeliveryPerson(deliveryPerson['phone']),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTimelineItem({
    required DeliveryEvent event,
    required bool isFirst,
    required bool isLast,
    required bool isCurrent,
    required bool isCompleted,
  }) {
    final iconColor =
        isCurrent
            ? Colors.green.shade800
            : isCompleted
            ? Colors.green.shade400
            : Colors.grey[300];

    final textColor =
        isCurrent
            ? Colors.green.shade800
            : isCompleted
            ? Colors.grey[800]
            : Colors.grey[400];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: isCompleted ? Colors.green.shade400 : Colors.grey[300],
                ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child:
                    isCompleted
                        ? Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? Colors.green.shade400 : Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Status content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusToString(event.status),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: TextStyle(color: textColor!.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(delay: (100 * event.status.index).ms),
    );
  }

  String _statusToString(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Order Received';
      case DeliveryStatus.confirmed:
        return 'Order Confirmed';
      case DeliveryStatus.shipped:
        return 'Shipped';
      case DeliveryStatus.enRoute:
        return 'Out for Delivery';
      case DeliveryStatus.delivered:
        return 'Delivered';
    }
  }

  IconData _getStatusIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return Icons.shopping_cart;
      case DeliveryStatus.confirmed:
        return Icons.verified;
      case DeliveryStatus.shipped:
        return Icons.local_shipping;
      case DeliveryStatus.enRoute:
        return Icons.directions_bike;
      case DeliveryStatus.delivered:
        return Icons.home;
    }
  }

  void _callDeliveryPerson(String phone) {
    launchUrl(Uri.parse('tel:$phone'));
  }
}
