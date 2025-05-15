import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/negotiation.dart';

class NegotiationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Negotiation> _localNegotiations = {};

  /// Returns the most recent negotiation for a product,
  /// checking cache first, then Firestore.
  Future<Negotiation?> getCurrentNegotiation(String productId) async {
    // 1) In-memory lookup
    final local = _localNegotiations.values.firstWhere(
      (n) => n.productId == productId,
    );
    if (local != null) return local;

    // 2) Firestore fallback
    final snapshot =
        await _firestore
            .collection('negotiations')
            .where('productId', isEqualTo: productId)
            .orderBy('updatedAt', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;
    return _mapDocumentToNegotiation(snapshot.docs.first);
  }

  /// All negotiations where I’m the seller
  Future<List<Negotiation>> getNegotiationsForSeller(String sellerId) async {
    // merge cache + Firestore
    final local =
        _localNegotiations.values.where((n) => n.sellerId == sellerId).toList();

    final snapshot =
        await _firestore
            .collection('negotiations')
            .where('sellerId', isEqualTo: sellerId)
            .get();

    final remote = snapshot.docs.map(_mapDocumentToNegotiation).toList();
    return [...local, ...remote];
  }

  /// All negotiations where I’m the buyer
  Future<List<Negotiation>> getNegotiationsForBuyer(String buyerId) async {
    final local =
        _localNegotiations.values.where((n) => n.buyerId == buyerId).toList();

    final snapshot =
        await _firestore
            .collection('negotiations')
            .where('buyerId', isEqualTo: buyerId)
            .get();

    final remote = snapshot.docs.map(_mapDocumentToNegotiation).toList();
    return [...local, ...remote];
  }

  /// Start a new negotiation (propose a price)
  Future<Negotiation> proposePrice({
    required String productId,
    required String buyerId,
    required double proposedPrice,
    required double originalPrice,
    required String sellerId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    final negotiation = Negotiation(
      id: id,
      productId: productId,
      buyerId: buyerId,
      sellerId: sellerId,
      originalPrice: originalPrice,
      proposedPrice: proposedPrice,
      counterPrice: null,
      status: NegotiationStatus.proposed,
      createdAt: now,
      updatedAt: now,
    );

    // cache + persist
    _localNegotiations[id] = negotiation;
    await _firestore
        .collection('negotiations')
        .doc(id)
        .set(_negotiationToMap(negotiation));
    return negotiation;
  }

  /// Respond to an existing proposal (accept/reject/counter)
  Future<Negotiation> respondToProposal({
    required String negotiationId,
    required String response,
    double? counterPrice,
  }) async {
    // 1) find in cache or fail
    var negotiation = _localNegotiations[negotiationId];
    if (negotiation == null) {
      final doc =
          await _firestore.collection('negotiations').doc(negotiationId).get();
      if (!doc.exists) throw Exception('Negotiation not found');
      negotiation = _mapDocumentToNegotiation(doc);
    }

    // 2) derive new status
    final status = switch (response) {
      'accepted' => NegotiationStatus.accepted,
      'rejected' => NegotiationStatus.rejected,
      'counter_offered' => NegotiationStatus.counterOffered,
      _ => throw Exception('Invalid response'),
    };

    final updated = negotiation.copyWith(
      status: status,
      counterPrice: counterPrice,
      updatedAt: DateTime.now(),
    );

    // 3) update both cache & Firestore
    _localNegotiations[negotiationId] = updated;
    await _firestore
        .collection('negotiations')
        .doc(negotiationId)
        .update(_negotiationToMap(updated));
    return updated;
  }

  /// Helper to serialize for Firestore
  Map<String, dynamic> _negotiationToMap(Negotiation n) => {
    'productId': n.productId,
    'buyerId': n.buyerId,
    'sellerId': n.sellerId,
    'originalPrice': n.originalPrice,
    'proposedPrice': n.proposedPrice,
    'counterPrice': n.counterPrice,
    'status': n.status.toString(),
    'createdAt': n.createdAt,
    'updatedAt': n.updatedAt,
  };

  /// Helper to deserialize from Firestore
  Negotiation _mapDocumentToNegotiation(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Negotiation(
      id: doc.id,
      productId: data['productId'],
      buyerId: data['buyerId'],
      sellerId: data['sellerId'],
      originalPrice: (data['originalPrice'] as num).toDouble(),
      proposedPrice: (data['proposedPrice'] as num).toDouble(),
      counterPrice: (data['counterPrice'] as num?)?.toDouble(),
      status: _parseStatus(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  NegotiationStatus _parseStatus(String status) {
    return NegotiationStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => NegotiationStatus.proposed,
    );
  }
}
