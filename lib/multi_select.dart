import 'package:flutter/material.dart';

class MultiSelect extends StatefulWidget {
  final List<String> items;
  final Set<String> selectedProducts;
  final String url;
  final Function(String) onChangedUrl;
  const MultiSelect(
      {Key? key,
      required this.items,
      required this.selectedProducts,
      required this.url,
      required this.onChangedUrl})
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

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
        widget.onChangedUrl(_setProductTypeURL(itemValue, widget.url));
      } else {
        _selectedItems.remove(itemValue);
        widget.onChangedUrl("https://perfumehub.pl/");
      }
      Navigator.of(context).pop(_selectedItems.toSet());
    });
  }

  String _setProductTypeURL(String type, String url) {
    Map<String, String> queryParams;

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
        return url;
    }

    return Uri.parse(url).replace(queryParameters: queryParams).toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrowanie'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
