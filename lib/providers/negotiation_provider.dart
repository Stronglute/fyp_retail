import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/negotiation.dart';
import '../services/negotiation_service.dart';

final negotiationServiceProvider = Provider<NegotiationService>((ref) {
  return NegotiationService();
});

// Provider for a specific product negotiation
final negotiationProvider = StateNotifierProvider.family<
  NegotiationNotifier,
  AsyncValue<Negotiation?>,
  String
>((ref, productId) {
  return NegotiationNotifier(productId, ref.read(negotiationServiceProvider));
});

// Provider for all seller negotiations
final sellerNegotiationsProvider =
    FutureProvider.family<List<Negotiation>, String>((ref, sellerId) async {
      return ref
          .read(negotiationServiceProvider)
          .getNegotiationsForSeller(sellerId);
    });

class NegotiationNotifier extends StateNotifier<AsyncValue<Negotiation?>> {
  final String productId;
  final NegotiationService _service;

  NegotiationNotifier(this.productId, this._service)
    : super(const AsyncValue.loading()) {
    _loadNegotiation();
  }

  Future<void> _loadNegotiation() async {
    state = const AsyncValue.loading();
    try {
      final negotiation = await _service.getCurrentNegotiation(productId);
      state = AsyncValue.data(negotiation);
    } catch (e) {
      if (e.toString().contains("No element")) {
        state = AsyncValue.data(null);
        return;
      }
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> proposePrice(
    String buyerId,
    double proposedPrice,
    double originalPrice,
    String sellerId,
  ) async {
    try {
      state = const AsyncValue.loading();
      final negotiation = await _service.proposePrice(
        productId: productId,
        buyerId: buyerId,
        proposedPrice: proposedPrice,
        originalPrice: originalPrice,
        sellerId: sellerId,
      );
      state = AsyncValue.data(negotiation);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> respondToProposal(
    String negotiationId,
    String response, [
    double? counterPrice,
  ]) async {
    try {
      state = const AsyncValue.loading();
      final negotiation = await _service.respondToProposal(
        negotiationId: negotiationId,
        response: response,
        counterPrice: counterPrice,
      );
      state = AsyncValue.data(negotiation);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Provider for all buyer negotiations
final buyerNegotiationsProvider =
    FutureProvider.family<List<Negotiation>, String>((ref, buyerId) {
      return ref
          .read(negotiationServiceProvider)
          .getNegotiationsForBuyer(buyerId);
    });
