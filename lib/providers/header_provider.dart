import 'package:flutter/material.dart';

class HeaderProvider extends ChangeNotifier {
  String currentUrl = "https://perfumehub.pl/";

  String get url {
    return "https://perfumehub.pl/";
  }

  Uri addQueryParameters(String originalUri, Map<dynamic, dynamic> newParams) {
    return Uri.parse(originalUri).replace(queryParameters: {
      ...Uri.parse(originalUri).queryParameters,
      ...newParams,
    });
  }

  changeUrlHeader(
    String url,
  ) {
    currentUrl = url;
    notifyListeners();
  }

  initialize() {
    currentUrl = "https://perfumehub.pl/";
    notifyListeners();
  }
}
