import 'package:flutter/material.dart';
import 'package:perfume_hub/objects/saved_product.dart';
import 'package:perfume_hub/product_details.dart';
import 'package:perfume_hub/services/save_product_service.dart';

class SavedProducts extends StatefulWidget {
  const SavedProducts({super.key});

  @override
  State<SavedProducts> createState() => _SavedProductsState();
}

class _SavedProductsState extends State<SavedProducts> {
  final SaveProductService _saveProductService = SaveProductService();
  late List<SavedProduct> _savedProducts;

  @override
  void initState() {
    super.initState();
    _savedProducts = [];
    _loadSavedProducts();
  }

  Future<void> _loadSavedProducts() async {
    List<SavedProduct> savedProducts =
        await _saveProductService.getSavedProducts();
    setState(() {
      _savedProducts = savedProducts;
    });
  }

  Future<void> _removeProduct(SavedProduct product) async {
    await _saveProductService.removeProducts(product);
    _loadSavedProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _savedProducts.isEmpty
          ? const Center(
              child: Text('Brak zapisanych produktów.'),
            )
          : ListView.builder(
              itemCount: _savedProducts.length,
              itemBuilder: (context, index) {
                SavedProduct product = _savedProducts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                  child: Dismissible(
                    key: Key(product
                        .imageUrl), // Użyj odpowiedniego pola, np. product.id
                    onDismissed: (direction) {
                      _removeProduct(product);
                    },
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductDetails(
                                      productURL: product.productUrl,
                                    )));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Text(product.productBrand),
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: Image.network(
                                  product.imageUrl,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const CircularProgressIndicator(),
                                  loadingBuilder:
                                      (context, child, loadingProgress) => child,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      product.productLine,
                                      style: TextStyle(
                                        fontSize: product.imageUrl.length < 20
                                            ? 18
                                            : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      product.subTitle,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
