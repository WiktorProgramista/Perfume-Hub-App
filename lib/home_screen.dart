import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:perfume_hub_app/multi_select.dart';
import 'package:perfume_hub_app/objects/product.dart';
import 'package:perfume_hub_app/product_details.dart';
import 'package:perfume_hub_app/services/network_service.dart';

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _typProduktu = [
    'tester',
    'nie tester',
    'zestaw',
    'nie zestaw'
  ];
  List<Map<String, dynamic>> responseData = [];
  List<Product> products = [];
  final scrolController = ScrollController();
  int _currentPage = 1;
  bool isLoading = false;
  final defaultImage = "https://perfumehub.pl/images/default_image.jpg";
  var url = "https://perfumehub.pl/";
  NetworkService networkService = NetworkService();
  final Set<String> _selectedTypProduktu = <String>{};
  final Map<String, String> _selectedPrice = {
    "price_from": "0",
    "price_to": "0"
  };

  @override
  void initState() {
    super.initState();
    scrolController.addListener(_scrollListener);
    networkService.fetchProducts(url, _currentPage, products);
  }

  Future<void> _scrollListener() async {
    if (scrolController.position.pixels ==
        scrolController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      _currentPage++;
      await networkService.fetchProducts(url, _currentPage, products);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMultiSelect(
      List<String> items, Map<String, String> selectedPrice) async {
    final Set<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
            items: items,
            selectedProducts: _selectedTypProduktu,
            selectedPrice: selectedPrice,
            url: url,
            onChangedUrlCallback: (newUrl) {
              setState(() {
                responseData = [];
                products = [];
                url = newUrl;
              });
            });
      },
    );

    if (results != null) {
      setState(() {
        _selectedTypProduktu.clear();
        _selectedTypProduktu.addAll(results);
      });
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.sort, size: 33),
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'Perfume',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: 'Hub',
              style: TextStyle(
                color: Colors.red,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
        ),
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            image: const DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/profile.jpg'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerfumeContainer(int index) {
    final product = products[index];
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(
              productURL: product.productLink,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(product.priceChange),
            SizedBox(
              width: 150,
              height: 150,
              child: !isLoading
                  ? Image.network(
                      product.imageUrl,
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Image.network(defaultImage);
                      },
                    )
                  : const CircularProgressIndicator(strokeWidth: 1.0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: product.title.length < 20 ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    product.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  _buildPriceText(product.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceText(String price) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: price,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          TextSpan(
            text: ' zł',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          networkService.headerTypeSearch(textEditingValue.text, responseData);
          return responseData
              .map<String>((data) => "${data['brand']}-${data['line']}");
        },
        onSelected: (String selectedValue) {
          var foundedProduct = responseData
              .where((e) => '${e['brand']}-${e['line']}' == selectedValue)
              .first;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetails(productURL: foundedProduct['productLink']),
            ),
          );
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onEditingComplete: onEditingComplete,
            decoration: InputDecoration(
              hintText: 'Search here',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: InkWell(
                onTap: () => _showMultiSelect(_typProduktu, _selectedPrice),
                child: const Icon(Icons.filter_list),
              ),
              border: InputBorder.none,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: networkService.fetchProducts(url, _currentPage, products),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 10.0),
                    _buildSearchBar(),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Lista Produktów',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: StaggeredGridView.countBuilder(
                        controller: scrolController,
                        padding: const EdgeInsets.all(5),
                        staggeredTileBuilder: (index) {
                          return StaggeredTile.count(
                              1, index.isEven ? 2.2 : 2.3);
                        },
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return _buildPerfumeContainer(index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
