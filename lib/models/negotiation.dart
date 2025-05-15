enum NegotiationStatus { proposed, accepted, rejected, counterOffered }

class Negotiation {
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final double originalPrice;
  final double proposedPrice;
  final double? counterPrice;
  final NegotiationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Negotiation({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.originalPrice,
    required this.proposedPrice,
    this.counterPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Negotiation copyWith({
    String? id,
    String? productId,
    String? buyerId,
    String? sellerId,
    double? originalPrice,
    double? proposedPrice,
    double? counterPrice,
    NegotiationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Negotiation(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      originalPrice: originalPrice ?? this.originalPrice,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      counterPrice: counterPrice ?? this.counterPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
