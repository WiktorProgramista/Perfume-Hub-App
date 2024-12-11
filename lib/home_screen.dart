import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser;
import 'package:perfume_hub/multi_select.dart';
import 'package:perfume_hub/objects/product.dart';
import 'package:perfume_hub/product_details.dart';
import 'package:perfume_hub/providers/header_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
  final Set<String> _selectedProducts = {};
  final Map<String, String> _selectedPrice = {
    "startPrice": "0",
    "endPrice": "0"
  };

  @override
  void initState() {
    scrolController.addListener(_scrollListener);
    Provider.of<HeaderProvider>(context, listen: false)
        .addListener(_onHeaderProviderChange);
    super.initState();
  }

  Future<void> _scrollListener() async {
    if (scrolController.position.pixels ==
        scrolController.position.maxScrollExtent) {
      setState(() {
        _currentPage++;
      });
    }
  }

  Uri addQueryParameters(String originalUri, Map<dynamic, dynamic> newParams) {
    return Uri.parse(originalUri).replace(queryParameters: {
      ...Uri.parse(originalUri).queryParameters,
      ...newParams,
    });
  }

  void _onHeaderProviderChange() {
    String currentUrl =
        Provider.of<HeaderProvider>(context, listen: false).currentUrl;
    setState(() {
      products.clear();
    });
    fetchProducts(_currentPage, currentUrl);
  }

  Future<List<Product>> fetchProducts(int page, String providerUrl) async {
    var url = addQueryParameters(providerUrl, {"page": _currentPage.toString()})
        .toString()
        .toString();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = htmlparser.parse(response.body);
      final elements =
          document.getElementsByClassName('col-6 col-md-4 col-lg-3');

      for (var element in elements) {
        var titleElement = element.querySelector('.card-title');
        var subtitleElement = element.querySelector('.card-subtitle');
        var imageElement = element.querySelector('.image-container img');
        var priceElement = element.querySelector('.price');
        var priceChangeElement = element.querySelector('span');
        var productLink = element
            .getElementsByClassName('d-block h-100')[0]
            .attributes['href'];

        final product = Product(
          title: titleElement?.text.trim() ?? '',
          subtitle: subtitleElement?.text.trim() ?? '',
          imageUrl: imageElement?.attributes['src'] ?? '',
          price: priceElement?.text.trim() ?? '',
          priceChange: priceChangeElement?.text.trim() ?? '',
          productLink: productLink ?? '',
        );
        products.add(product);
      }
      return products;
    } else {
      throw Exception('Request API error');
    }
  }

  void _headerTypeSearch(String text) async {
    final url = 'https://perfumehub.pl/typeahead?q=$text&t=1700922313025';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        responseData = List<Map<String, dynamic>>.from(data['products']);
      });
    } else {
      throw Exception('Request API error');
    }
  }

  void _showMultiSelect(List<String> items) async {
    final Set<String>? results = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return MultiSelect(
            items: items,
            selectedProducts: _selectedProducts,
            selectedPrice: _selectedPrice,
          );
        });
    if (results != null) {
      setState(() {
        _selectedProducts.clear();
        _selectedProducts.addAll(results);
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
                color: Theme.of(context).colorScheme.secondary,
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

  Widget _buildPerfumeContainer(Product product) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetails(
                      productURL: product.productLink,
                    )));
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(product.priceChange),
              SizedBox(
                width: 150,
                height: 150,
                child: Image.network(product.imageUrl,
                    errorBuilder: (context, error, stackTrace) =>
                        const CircularProgressIndicator(),
                    loadingBuilder: (context, child, loadingProgress) => child),
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
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
          TextSpan(
            text: ' zł',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.onSecondary,
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
        color: Theme.of(context).colorScheme.primary,
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
          _headerTypeSearch(textEditingValue.text);
          return responseData
              .map<String>((data) => "${data['brand']}-${data['line']}");
        },
        onSelected: (String selectedValue) {
          var foundedProducts = responseData
              .where((e) => '${e['brand']}-${e['line']}' == selectedValue);

          if (foundedProducts.isNotEmpty) {
            var foundedProduct = foundedProducts.first;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetails(productURL: foundedProduct['productLink']),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produkt nie znaleziony!')),
            );
          }
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          return Row(
            children: [
              SvgPicture.asset('assets/svg/search.svg', width: 30.0, height: 30.0, colorFilter: ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.srcIn)),
              const SizedBox(width: 5.0),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: const InputDecoration(
                    hintText: 'Search here',
                    border: InputBorder.none,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _showMultiSelect(_typProduktu),
                child: SvgPicture.asset('assets/svg/filter.svg', width: 30.0, height: 30.0, colorFilter: ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.srcIn))),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HeaderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: FutureBuilder(
            future: fetchProducts(_currentPage, provider.currentUrl),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
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
                          child: RefreshIndicator(
                            backgroundColor:
                                Theme.of(context).colorScheme.onSecondary,
                            onRefresh: () async {
                              setState(() {
                                products.clear();
                                fetchProducts(1, provider.url);
                              });
                            },
                            child: StaggeredGridView.countBuilder(
                              controller: scrolController,
                              padding: const EdgeInsets.all(5),
                              staggeredTileBuilder: (index) {
                                return StaggeredTile.count(
                                    1, index.isEven ? 2.0 : 2.3);
                              },
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return _buildPerfumeContainer(
                                    snapshot.data![index]);
                              },
                            ),
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
      },
    );
  }
}
