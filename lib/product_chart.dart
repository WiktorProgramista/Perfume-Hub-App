// ignore: depend_on_referenced_packages
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:perfume_hub_app/objects/price_history.dart';

class ProductChart extends StatefulWidget {
  final PriceHistory priceHistory;

  const ProductChart({super.key, required this.priceHistory});

  @override
  State<ProductChart> createState() => _ProductChartState();
}

class _ProductChartState extends State<ProductChart> {
  List<dynamic> priceData = [];
  List<FlSpot> spots = [];

  Future<void> fetchAPIData() async {
    var p = widget.priceHistory;
    var url =
        "https://perfumehub.pl/price-history?size=${p.dataSize}&mode=${p.dataMode}&brand=${p.dataBrand}&line=${p.dataLine}&gender=${p.dataGender}&type=${p.dataType}&sizeUnit=${p.dataSizeUnit}&refill=${p.dataRefill}&tester=${p.dataTester}&isSet=${p.dataIsset}&period=365";
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      setState(() {
        priceData = data;
      });
      for (int i = 0; i < priceData.length; i++) {
        spots.add(FlSpot(i.toDouble(), priceData[i]['price'].toDouble()));
      }
    } else {
      throw Exception('Request API error');
    }
  }

  @override
  void initState() {
    fetchAPIData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: priceData.isNotEmpty
            ? SafeArea(
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.blue,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    titlesData: const FlTitlesData(leftTitles: AxisTitles()),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
              ));
  }
}
