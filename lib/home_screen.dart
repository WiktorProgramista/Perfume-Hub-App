import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as htmlparser;
import 'package:perfume_hub_app/multi_select.dart';
import 'package:perfume_hub_app/objects/product.dart';
import 'package:perfume_hub_app/product_details.dart';

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

  final Set<String> _selectedTypProduktu = <String>{};
  final Map<String, String> _selectedPrice = {
    "price_from": "0",
    "price_to": "0"
  };

  @override
  void initState() {
    super.initState();
    scrolController.addListener(_scrollListener);
    fetchProducts(1);
  }

  Future<void> _scrollListener() async {
    if (scrolController.position.pixels ==
        scrolController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      _currentPage++;
      await fetchProducts(_currentPage);
      setState(() {
        isLoading = false;
      });
    }
  }

  Uri addQueryParameters(String originalUri, Map<dynamic, dynamic> newParams) {
    return Uri.parse(originalUri).replace(queryParameters: {
      ...Uri.parse(originalUri).queryParameters,
      ...newParams,
    });
  }

  Future<void> fetchProducts(int page) async {
    final response = await http.get(Uri.parse(url));
    url = addQueryParameters(url, {"page": _currentPage.toString()}).toString();
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
              child: Image.network(
                product.imageUrl,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child; // Obraz został wczytany, zwróć go
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Image.network(
                      defaultImage); // Zwróć domyślny obraz w przypadku błędu
                },
              ),
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
          _headerTypeSearch(textEditingValue.text);
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
        future: fetchProducts(_currentPage),
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
