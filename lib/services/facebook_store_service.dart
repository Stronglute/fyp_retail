import 'dart:convert';
import 'package:http/http.dart';
import '../models/facebook_product.dart';

class FacebookStoreService {
  Future<List<FacebookProduct>> fetchProducts(
    String pageId,
    String token,
  ) async {
    final uri = Uri.https('graph.facebook.com', '/v14.0/$pageId/products', {
      'access_token': token,
    });
    final res = await get(uri);
    final body = jsonDecode(res.body);
    final data = (body['data'] as List?) ?? [];
    return data.map((e) => FacebookProduct.fromJson(e)).toList();
  }
}
