import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminGoodsRevenue extends StatefulWidget {
  const AdminGoodsRevenue({super.key});

  @override
  State<AdminGoodsRevenue> createState() => _AdminGoodsRevenueState();
}

class _AdminGoodsRevenueState extends State<AdminGoodsRevenue> {
  List<GoodsRevenue> chartData = [];

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.50.236:8000/goods_revenue"));
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['result'] != null && data['result'] is List) {
        setState(() {
          chartData = data['result'].map<GoodsRevenue>((item) {
            return GoodsRevenue(
              name: item['name'],
              amount: (item['total'] ?? 0) ~/ 10000, // 만원 단위
            );
          }).toList();
        });
      }
    } catch (e) {
      print('❗ 서버 통신 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품별 매출 현황'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('• 모든 상품별 매출 현황', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: -20,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: '단위: 만원'),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<GoodsRevenue, String>(
                    dataSource: chartData,
                    xValueMapper: (GoodsRevenue data, _) => data.name,
                    yValueMapper: (GoodsRevenue data, _) => data.amount,
                    markerSettings: const MarkerSettings(isVisible: true),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    color: Colors.purple,
                    name: '매출',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoodsRevenue {
  final String name;
  final int amount;

  GoodsRevenue({required this.name, required this.amount});
}