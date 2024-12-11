import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as htmlparser;
import 'package:perfume_hub/objects/product.dart';

class NetworkService {
  /*
   --> home_screen.dart
  */

  Uri addQueryParameters(String originalUri, Map<dynamic, dynamic> newParams) {
    return Uri.parse(originalUri).replace(queryParameters: {
      ...Uri.parse(originalUri).queryParameters,
      ...newParams,
    });
  }

  Future<void> fetchProducts(String url, int currentPage, List products) async {
    final response = await http.get(Uri.parse(url));
    url = addQueryParameters(url, {"page": currentPage.toString()}).toString();
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

  void headerTypeSearch(String text, List responseData) async {
    final url = 'https://perfumehub.pl/typeahead?q=$text&t=1700922313025';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      responseData = List<Map<String, dynamic>>.from(data['products']);
    } else {
      throw Exception('Request API error');
    }
  }

  /*
    home_screen.dart <--
  */
}
