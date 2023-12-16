import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as htmlparser;
import 'package:perfume_hub_app/product_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> object;

  const ProductDetails({Key? key, required this.object}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  List<dynamic> priceData = [];
  List<VariantTitle> variantsTitle = [];
  List<Offers> offers = [];
  String productImage = '';
  String productTitle = '';
  String productSubtitle = '';
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (!isLoaded) {
      await fetchAPIData(widget.object);
      await fetchProductInfo(widget.object);
      setState(() {
        isLoaded = true;
      });
    }
  }

  Future<void> fetchAPIData(obj) async {
    var url =
        'https://perfumehub.pl/price-history?size=100&mode=product&brand=${obj['brand']}&line=${obj['line']}&gender=male&type=edt&sizeUnit=ml&refill=false&tester=false&isSet=false&period=365';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        priceData = data;
      });
    } else {
      throw Exception('Request API error');
    }
  }

  void getProductCapacities(document) {
    final elements = document.getElementsByClassName('variant-tile  d-block ');

    elements.forEach((element) {
      var title = element.querySelector('.variant-tile-title')?.text;
      var subTitle =
          element.querySelector('.variant-tile-subtitle.price')?.text;
      var url = element.attributes['href'];

      final variantTitle = VariantTitle(
        title: title ?? '',
        subtitle: subTitle ?? '',
        url: url ?? '',
      );
      variantsTitle.add(variantTitle);
    });
  }

  void getProductOffers(document) {
    final elements = document
        .getElementsByClassName('row offer border-top mx-0 align-items-center');

    elements.forEach((element) {
      var shopName = element
          .getElementsByClassName(
              'col-6 col-md-3 order-3 order-md-1 px-0 ps-lg-3 shop-name')
          .first
          .text;
      var productName = element
          .getElementsByClassName(
              'col-12 col-md-4 order-1 order-md-2 mb-3 mb-md-0 px-0 shop-title')
          .first
          .text;
      var price = element
          .getElementsByClassName(
              'col-6 col-md-3 order-4 order-md-4 px-0 text-end price')
          .first
          .text;
      var shopUrl =
          element.getElementsByClassName('btn-go-to').first.attributes['href'];

      final offer = Offers(
          shopName: shopName.trim() ?? '',
          productName: productName.trim() ?? '',
          price: price.trim() ?? '',
          shopUrl: shopUrl.trim());
      offers.add(offer);
    });
  }

  Future<void> fetchProductInfo(obj) async {
    variantsTitle = [];
    final response =
        await http.get(Uri.parse('https://perfumehub.pl${obj['productLink']}'));

    if (response.statusCode == 200) {
      final document = htmlparser.parse(response.body);
      productImage =
          document.getElementsByTagName('img')[0].attributes['src'] ??
              'https://perfumehub.pl/images/default_image.jpg';
      productTitle =
          document.getElementsByClassName('title d-none d-md-block')[0].text;
      productSubtitle =
          document.getElementsByClassName('subtitle d-none d-md-block')[0].text;

      getProductCapacities(document);
      getProductOffers(document);
    }
  }

  Future<void> openURL(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoaded
          ? SafeArea(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: const Icon(Icons.arrow_back),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        InkWell(
                          child: const Icon(Icons.bar_chart),
                          onTap: () {
                            if (isLoaded) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductChart(data: priceData),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2.8,
                    color: Colors.white,
                    child: Center(
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(productImage),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        productTitle,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        productSubtitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  fragranceCapacity(variantsTitle),
                  const SizedBox(height: 10),
                  siteContainer(),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget siteContainer() {
    return Column(
      children: offers.map((offer) {
        return Card(
          elevation: 1,
          color: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          child: ListTile(
            onTap: () => openURL(offer.shopUrl),
            title: Text(
              offer.productName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(offer.shopUrl),
            trailing: Text(offer.price),
            dense: true,
          ),
        );
      }).toList(),
    );
  }

  Widget fragranceCapacity(List<VariantTitle> variantsTitle) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceEvenly,
      runSpacing: 5,
      children: variantsTitle.map((variant) {
        return Container(
          width: 100,
          height: 80,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2),
          ),
          child: Center(
            child: Text(
              variant.title,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class VariantTitle {
  final String title;
  final String subtitle;
  final String url;

  VariantTitle({
    required this.title,
    required this.subtitle,
    required this.url,
  });
}

class Offers {
  final String shopName;
  final String productName;
  final String price;
  final String shopUrl;

  Offers({
    required this.shopName,
    required this.productName,
    required this.price,
    required this.shopUrl,
  });
}
