import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as htmlparser;
import 'package:perfume_hub_app/multi_select.dart';
import 'package:perfume_hub_app/product_details.dart';

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

class Product {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String price;
  final String priceChange;
  final String productLink;

  Product({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    required this.priceChange,
    required this.productLink,
  });
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
  List filteredData = [];
  List<Product> products = [];
  final scrolController = ScrollController();
  int _currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrolController.addListener(_scrollListener);
  }

  Future<void> _scrollListener() async {
    if (scrolController.position.pixels ==
        scrolController.position.maxScrollExtent) {
      setState(() {
        _currentPage++;
      });
    }
  }

  Future<List<Product>> fetchProducts(int page) async {
    final response =
        await http.get(Uri.parse('https://perfumehub.pl/?page=$page'));
    print(page);
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
        //print(responseData.toString());
      });
    } else {
      throw Exception('Request API error');
    }
  }

  void _showMultiSelect(List<String> items) async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: items);
      },
    );

    if (results != null) {
      setState(() {});
    }
  }

  void _filterData(String text) {
    filteredData = responseData
        .where((item) =>
            (item['brand']?.toLowerCase().contains(text.toLowerCase()) ??
                false) ||
            (item['line']?.toLowerCase().contains(text.toLowerCase()) ??
                false) ||
            (item['productLink']?.toLowerCase().contains(text.toLowerCase()) ??
                false))
        .toList();
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
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
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          _headerTypeSearch(textEditingValue.text);
          _filterData(textEditingValue.text);
          return responseData.map<String>((data) => data['line']).toList();
        },
        onSelected: (String selectedValue) {
          var selectedObject = filteredData.firstWhere(
            (element) => element.containsValue(selectedValue),
            orElse: () => <String, dynamic>{},
          );
          //print(selectedObject['productLink']);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductDetails(
                      productURL: selectedObject['productLink'])));
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
                onTap: () => _showMultiSelect(_typProduktu),
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
                          return _buildPerfumeContainer(snapshot.data![index]);
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
