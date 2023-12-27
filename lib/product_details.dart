import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as htmlparser;
import 'package:perfume_hub_app/objects/offers.dart';
import 'package:perfume_hub_app/objects/type_link.dart';
import 'package:perfume_hub_app/objects/variant_title.dart';
import 'package:perfume_hub_app/product_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetails extends StatefulWidget {
  final String? productURL;

  const ProductDetails({this.productURL, Key? key}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  List<dynamic> priceData = [];
  List<VariantTitle> variantsTitle = [];
  List<Offers> offers = [];
  List<TypeLink> typeLinks = [];
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
      await fetchProductInfo(widget.productURL);
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
          .text
          .toString()
          .trim()
          .split('\n')[0];
      var pricePerMl = element
          .getElementsByClassName(
              'col-6 col-md-3 order-4 order-md-4 px-0 text-end price')
          .first
          .text
          .toString()
          .trim()
          .split('\n')[1];
      var shopUrl =
          element.getElementsByClassName('btn-go-to').first.attributes['href'];

      final offer = Offers(
          shopName: shopName.trim(),
          productName: productName.trim(),
          price: price.trim(),
          shopUrl: decodeUrl(shopUrl),
          pricePerMl: pricePerMl.trim());
      offers.add(offer);
    });
  }

  void getProductTypes(document) {
    final elements = document.getElementsByClassName('type-link');

    elements.forEach((element) {
      var title = element.text;
      var url = element.attributes['href'];
      final typeLink = TypeLink(
        title: title ?? '',
        url: url ?? '',
      );
      typeLinks.add(typeLink);
    });
  }

  Future<void> fetchProductInfo(productURL) async {
    variantsTitle = [];
    final response =
        await http.get(Uri.parse('https://perfumehub.pl${widget.productURL}'));
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
      getProductTypes(document);
    }
  }

  Future<void> openURL(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  String decodeUrl(String encodedUrl) {
    Uri parsedUrl = Uri.parse(encodedUrl);
    String decodedUrl = Uri.decodeFull(parsedUrl.queryParameters['url'] ?? "");
    if (encodedUrl.contains('click?')) {
      decodedUrl = decodedUrl.split(':///click?')[0];
    } else {
      decodedUrl = encodedUrl;
    }
    return decodedUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          InkWell(
            child: const Icon(Icons.favorite_border_outlined),
            onTap: () {
              if (isLoaded) {}
            },
          ),
          const SizedBox(width: 20),
          InkWell(
            child: const Icon(Icons.bar_chart),
            onTap: () {
              if (isLoaded) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductChart(data: priceData),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoaded
          ? SafeArea(
              child: ListView(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2.8,
                    color: Colors.white,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: NetworkImage(productImage),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        productTitle,
                        textAlign: TextAlign.center,
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
                  productTypes(typeLinks),
                  const SizedBox(height: 10),
                  const Divider(),
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
          color: Theme.of(context).colorScheme.primary,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          child: ListTile(
            onTap: () => openURL(offer.shopUrl),
            title: Text(
              offer.productName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(offer.shopUrl),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(offer.price,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(offer.pricePerMl),
              ],
            ),
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
        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProductDetails(productURL: variant.url)));
          },
          child: Container(
            width: 100,
            height: 80,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)),
            child: Center(
              child: Text(
                variant.title,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget productTypes(List<TypeLink> typeLinks) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceEvenly,
      runSpacing: 5,
      children: typeLinks.map((type) {
        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProductDetails(productURL: type.url)));
          },
          child: Container(
            width: 100,
            height: 80,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Center(
              child: Text(
                type.title,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
