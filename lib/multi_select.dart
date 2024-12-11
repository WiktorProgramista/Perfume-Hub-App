import 'package:flutter/material.dart';
import 'package:perfume_hub/providers/header_provider.dart';
import 'package:provider/provider.dart';

class MultiSelect extends StatefulWidget {
  final List<String> items;
  final Set<String> selectedProducts;
  final Map<String, String> selectedPrice;
  const MultiSelect(
      {super.key,
      required this.items,
      required this.selectedProducts,
      required this.selectedPrice});

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final List<String> _selectedItems = [];
  Map<dynamic, dynamic> _selectedPrice = {};
  final _startPrice = TextEditingController();
  final _endPrice = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedItems.addAll(widget.selectedProducts);
    _selectedPrice = widget.selectedPrice;
    _startPrice.text = _selectedPrice['startPrice']!;
    _endPrice.text = _selectedPrice['endPrice']!;
  }

  String _setProductTypeURL(String type, HeaderProvider provider) {
    Map<dynamic, dynamic> queryParams;

    switch (type) {
      case "tester":
        queryParams = {"tester": "true"};
        break;
      case "nie tester":
        queryParams = {"ntester": "true"};
        break;
      case "zestaw":
        queryParams = {"is_set": "true"};
        break;
      case "nie zestaw":
        queryParams = {"is_nset": "true"};
        break;
      default:
        return provider.url;
    }

    return provider
        .addQueryParameters(provider.currentUrl, queryParams)
        .toString();
  }

  void _itemChange(
      String productType, bool isSelected, HeaderProvider provider) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(productType);
        provider.currentUrl = provider.url;
        provider.changeUrlHeader(_setProductTypeURL(productType, provider));
      } else {
        _selectedItems.remove(productType);
        provider.changeUrlHeader(provider.url);
      }
    });
    Navigator.of(context).pop(_selectedItems.toSet());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HeaderProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Wrap(
            children: [
              _priceRange(provider),
              _productTypes(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _productTypes(HeaderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Typ produktu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        Column(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) =>
                        _itemChange(item, isChecked!, provider),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _priceRange(HeaderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cena',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        Row(
          children: [
            Flexible(
              child: TextField(
                controller: _startPrice,
                keyboardType: TextInputType.number,
                onChanged: (startVal) {
                  setState(() {
                    _selectedPrice["startPrice"] = startVal;
                    provider
                        .changeUrlHeader(provider.addQueryParameters(
                            provider.currentUrl,
                            {"price_from": startVal.toString()}).toString())
                        .toString();
                  });
                },
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary)),
                  border: InputBorder.none,
                  hintText: "Od",
                ),
              ),
            ),
            Flexible(
              child: TextField(
                controller: _endPrice,
                keyboardType: TextInputType.number,
                onChanged: (endVal) {
                  setState(() {
                    _selectedPrice["endPrice"] = endVal;
                    provider
                        .changeUrlHeader(provider.addQueryParameters(
                            provider.currentUrl,
                            {"price_to": endVal.toString()}).toString())
                        .toString();
                  });
                },
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary)),
                  border: InputBorder.none,
                  hintText: "Do",
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
