// ignore: depend_on_referenced_packages
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProductChart extends StatelessWidget {
  final List<dynamic> data;

  const ProductChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];

    // Przetwarzanie danych na FlSpot
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]['price'].toDouble()));
    }

    return Scaffold(
        body: data.isNotEmpty
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
            : const Center(
                child: Text('Nie znaleziono cen produktu.',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ));
  }
}
