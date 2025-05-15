import 'dart:convert';
import 'package:http/http.dart';
import '../models/store_model.dart';

class FacebookMarketingService {
  /// 1️⃣ Create (or fetch) a product catalog on your Page
  Future<String> createProductCatalogForStore(Store store) async {
    final pageId = store.fbPageId;
    final token = store.fbAccessToken;

    // POST /{page-id}/product_catalogs
    final catalogRes = await post(
      Uri.https('graph.facebook.com', '/v14.0/$pageId/product_catalogs', {
        'access_token': token,
        'name': '${store.name} Catalog',
        'vertical': 'ECOMMERCE', // fixed value Facebook requires
      }),
    );
    final catalogBody = jsonDecode(catalogRes.body);
    final catalogId = catalogBody['id'] as String;

    // 2️⃣ Optionally: push individual products into this catalog
    //    e.g. POST /{catalog-id}/products with product fields:
    //    name, description, url, image_url, price, currency, etc.

    // Here’s a skeleton—you’d loop your Store’s products:
    /*
    await post(
      Uri.https(
        'graph.facebook.com',
        '/v14.0/$catalogId/products',
        {'access_token': token},
      ),
      body: {
        'name': store.name,
        'description': store.category.join(', '),
        'image_url': store.imageUrl,
        'url': 'https://your-site.com/stores/${store.id}',
        'price': '0.00 USD', // replace with real price
      },
    );
    */

    return catalogId;
  }
}
