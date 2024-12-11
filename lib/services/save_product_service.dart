import 'dart:convert';
import 'package:perfume_hub/objects/saved_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveProductService {
  static const _kSavedProductsKey = 'saved_products';

  Future<void> saveProducts(List<SavedProduct> newProducts) async {
    final prefs = await SharedPreferences.getInstance();

    // Pobierz istniejącą listę produktów
    List<SavedProduct> existingProducts = await getSavedProducts();

    // Filtruj nowe produkty, aby nie dodawać produktów o tym samym imageUrl
    List<SavedProduct> filteredNewProducts = newProducts.where((newProduct) {
      return !existingProducts.any(
          (existingProduct) => existingProduct.imageUrl == newProduct.imageUrl);
    }).toList();

    // Dodaj nowe produkty do istniejącej listy
    existingProducts.addAll(filteredNewProducts);

    // Konwertuj listę obiektów SavedProduct na listę map JSON
    final List<Map<String, dynamic>> jsonList =
        existingProducts.map((product) => product.toJson()).toList();

    // Zapisz listę map JSON do SharedPreferences
    await prefs.setString(_kSavedProductsKey, json.encode(jsonList));
  }

  Future<void> removeProducts(SavedProduct product) async {
    final prefs = await SharedPreferences.getInstance();

    // Pobierz istniejącą listę produktów
    List<SavedProduct> existingProducts = await getSavedProducts();

    // Dodaj nowe produkty do istniejącej listy
    existingProducts.removeWhere((e) => e.imageUrl == product.imageUrl);

    // Konwertuj listę obiektów SavedProduct na listę map JSON
    final List<Map<String, dynamic>> jsonList =
        existingProducts.map((product) => product.toJson()).toList();

    // Zapisz listę map JSON do SharedPreferences
    await prefs.setString(_kSavedProductsKey, json.encode(jsonList));
  }

  Future<List<SavedProduct>> getSavedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kSavedProductsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    // Parsuj listę map JSON na listę obiektów SavedProduct
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => SavedProduct.fromJson(json)).toList();
  }
}
