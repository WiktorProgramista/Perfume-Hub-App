import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:perfume_hub/objects/price_history.dart';

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
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.green],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.3),
                              Colors.green.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        dotData: const FlDotData(show: true),
                        barWidth: 3,
                      ),
        
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value % 10 == 0) {
                              return Text(
                                'Day ${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          interval: 10,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            '\$${value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          interval: 10,
                          reservedSize: 40,
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      verticalInterval: 10,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: Colors.black12,
                        strokeWidth: 0.8,
                      ),
                      getDrawingVerticalLine: (value) => const FlLine(
                        color: Colors.black12,
                        strokeWidth: 0.8,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        bottom: BorderSide(color: Colors.black, width: 1),
                        left: BorderSide(color: Colors.black, width: 1),
                        right: BorderSide(color: Colors.transparent),
                        top: BorderSide(color: Colors.transparent),
                      ),
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
