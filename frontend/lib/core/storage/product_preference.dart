import 'package:shared_preferences/shared_preferences.dart';

enum ProductDirection {
  dota('dota', '/dota', 'Dota Lab'),
  cs2('cs2', '/cs2', 'CS2 Lab');

  const ProductDirection(this.key, this.path, this.label);

  final String key;
  final String path;
  final String label;

  static ProductDirection? fromKey(String? key) {
    for (final value in ProductDirection.values) {
      if (value.key == key) return value;
    }
    return null;
  }

  static ProductDirection? fromPath(String path) {
    if (path.startsWith('/dota')) return ProductDirection.dota;
    if (path.startsWith('/cs2')) return ProductDirection.cs2;
    return null;
  }
}

abstract final class ProductPreference {
  static const _key = 'gamementor.selected_product';

  static Future<ProductDirection?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProductDirection.fromKey(prefs.getString(_key));
  }

  static Future<void> save(ProductDirection product) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, product.key);
  }
}
