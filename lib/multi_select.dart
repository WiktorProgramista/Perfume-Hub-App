import 'package:flutter/material.dart';
import 'package:perfume_hub_app/providers/header_provider.dart';
import 'package:provider/provider.dart';

class MultiSelect extends StatefulWidget {
  final List<String> items;
  final Set<String> selectedProducts;
  const MultiSelect(
      {Key? key, required this.items, required this.selectedProducts})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems.addAll(widget.selectedProducts);
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
        return SingleChildScrollView(
          child: ListBody(
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
        );
      },
    );
  }
}
