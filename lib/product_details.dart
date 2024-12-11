import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser;
import 'package:perfume_hub/objects/offers.dart';
import 'package:perfume_hub/objects/price_history.dart';
import 'package:perfume_hub/objects/saved_product.dart';
import 'package:perfume_hub/objects/type_link.dart';
import 'package:perfume_hub/objects/variant_title.dart';
import 'package:perfume_hub/product_chart.dart';
import 'package:perfume_hub/services/save_product_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetails extends StatefulWidget {
  final String? productURL;

  const ProductDetails({this.productURL, super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  List<VariantTitle> variantsTitle = [];
  List<Offers> offers = [];
  List<TypeLink> typeLinks = [];
  String productImage = '';
  String productBrand = '';
  String productLine = "";
  String productSubtitle = '';
  bool isLoaded = false;
  bool isLiked = false;
  late PriceHistory priceHistory;

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

      var historyTrigger =
          document.getElementsByClassName('price-history-trigger')[0];
      var dataBrand = historyTrigger.attributes['data-brand'];
      var dataLine = historyTrigger.attributes['data-line'];
      var dataGender = historyTrigger.attributes['data-gender'];
      var dataType = historyTrigger.attributes['data-type'];
      var dataSize = historyTrigger.attributes['data-size'];
      var dataSizeUnit = historyTrigger.attributes['data-sizeunit'];
      var dataRefill = historyTrigger.attributes['data-refill'];
      var dataTester = historyTrigger.attributes['data-tester'];
      var dataIsset = historyTrigger.attributes['data-isset'];
      var dataMode = historyTrigger.attributes['data-mode'];

      priceHistory = PriceHistory(
          dataBrand: dataBrand!,
          dataLine: dataLine!,
          dataGender: dataGender!,
          dataType: dataType!,
          dataSize: dataSize!,
          dataSizeUnit: dataSizeUnit!,
          dataRefill: dataRefill!,
          dataTester: dataTester!,
          dataIsset: dataIsset!,
          dataMode: dataMode!);

      productImage =
          document.getElementsByTagName('img')[0].attributes['src'] ??
              'https://perfumehub.pl/images/default_image.jpg';
      productBrand = document.getElementsByClassName('brand')[1].text;
      productLine = document.getElementsByClassName('line')[1].text;
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
          IconButton(
            icon: Icon(Icons.favorite_border_outlined,
                color: isLiked == false ? Colors.white : Colors.red),
            onPressed: () {
              setState(() {
                isLiked = !isLiked;
              });
              if (isLoaded) {
                SaveProductService service = SaveProductService();
                service.saveProducts([
                  SavedProduct(
                      productUrl: widget.productURL!,
                      productBrand: productBrand,
                      productLine: productLine,
                      subTitle: productSubtitle,
                      imageUrl: productImage,
                      isLiked: false)
                ]);
                service.getSavedProducts();
              }
            },
          ),
          const SizedBox(width: 20),
          InkWell(
            child: const Icon(Icons.bar_chart),
            onTap: () {
              if (isLoaded &&
                  productBrand.isNotEmpty &&
                  productLine.isNotEmpty) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProductChart(priceHistory: priceHistory)));
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
                        productBrand,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        productLine,
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
          child: Card(
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
