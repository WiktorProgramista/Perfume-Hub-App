import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:perfume_hub_app/product_chart.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> object;
  const ProductDetails({super.key, required this.object});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  List<dynamic> priceData = [];

  bool isLoaded = false;

  Future<List<dynamic>> fetchAPIData(obj) async {
    var url =
        'https://perfumehub.pl/price-history?size=100&mode=product&brand=${obj['brand']}&line=${obj['line']}&gender=male&type=edt&sizeUnit=ml&refill=false&tester=false&isSet=false&period=365';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        priceData = data;
        isLoaded = true;
      });
      return data;
    } else {
      throw Exception('Request API error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> capacity = [30, 50, 100, 200];
    return Scaffold(
        body: FutureBuilder(
      future: fetchAPIData(widget.object),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SafeArea(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: const Icon(Icons.arrow_back),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      GestureDetector(
                        child: const Icon(Icons.bar_chart),
                        onTap: () {
                          if (isLoaded) {
                            print(priceData);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProductChart(data: priceData)));
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
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/armani.jpg'),
                        ),
                      ),
                    ),
                  ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Armani Eau De Cedre',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w800)),
                    Text('Woda toaletowa 100 ml',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300)),
                  ],
                ),
                const SizedBox(height: 10),
                fragranceCapacity(capacity),
                const SizedBox(height: 10),
                siteContainer(widget.object)
              ],
            ),
          );
        }
      },
    ));
  }
}

Widget siteContainer(obj) {
  return Card(
    elevation: 1,
    color: Colors.white,
    shadowColor: Colors.white,
    surfaceTintColor: Colors.white,
    child: ListTile(
      onTap: () {},
      title: Text(
        obj['brand'].toString().toUpperCase(),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(obj['line']),
      //trailing: Text(obj['productLink'].toString()),
      dense: true,
    ),
  );
}

Widget fragranceCapacity(List<int> capacity) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: capacity.map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey, width: 2)),
          child: Center(
            child: Text('$e ml'),
          ),
        ),
      );
    }).toList(),
  );
}
