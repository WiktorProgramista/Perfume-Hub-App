import 'package:flutter/material.dart';

class MultiSelect extends StatefulWidget {
  final List<String> items;
  final Set<String> selectedProducts;
  final Map<String, String> selectedPrice;
  final String url;
  final Function(String) onChangedUrlCallback;

  const MultiSelect({
    Key? key,
    required this.items,
    required this.selectedProducts,
    required this.selectedPrice,
    required this.url,
    required this.onChangedUrlCallback,
  }) : super(key: key);

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

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
        widget.onChangedUrlCallback(_setProductTypeURL(itemValue, widget.url));
      } else {
        _selectedItems.remove(itemValue);
        widget.onChangedUrlCallback("https://perfumehub.pl/");
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
      content: ListView(
        children: [
          ListBody(
            children: widget.items
                .map((item) => CheckboxListTile(
                      value: _selectedItems.contains(item),
                      title: Text(item),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (isChecked) => _itemChange(item, isChecked!),
                    ))
                .toList(),
          ),
          const SizedBox(height: 5.0),
          Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _startPrice,
                  keyboardType: TextInputType.number,
                  onChanged: (startVal) {
                    setState(() {
                      _selectedPrice["startPrice"] = startVal;
                      widget.onChangedUrlCallback(
                        Uri.parse(widget.url).replace(
                          queryParameters: {
                            "price_from": startVal.toString(),
                            "price_to": _selectedPrice["endPrice"],
                          },
                        ).toString(),
                      );
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
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
                      widget.onChangedUrlCallback(
                        Uri.parse(widget.url).replace(
                          queryParameters: {
                            "price_to": endVal.toString(),
                            "price_from": _selectedPrice["startPrice"]
                          },
                        ).toString(),
                      );
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Do",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
