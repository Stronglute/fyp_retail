import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_model.dart';
import '../models/facebook_product.dart';
import '../services/facebook_store_service.dart';
import '../services/facebook_marketing_service.dart';

final facebookStoreServiceProvider = Provider((_) => FacebookStoreService());

final facebookMarketingServiceProvider = Provider(
  (_) => FacebookMarketingService(),
);

final facebookProductsProvider =
    FutureProvider.family<List<FacebookProduct>, Store>((ref, store) {
      return ref
          .read(facebookStoreServiceProvider)
          .fetchProducts(store.fbPageId, store.fbAccessToken);
    });
