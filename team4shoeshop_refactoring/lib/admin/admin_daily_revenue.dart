import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDailyRevenue extends StatefulWidget {
  const AdminDailyRevenue({super.key});

  @override
  State<AdminDailyRevenue> createState() => _AdminDailyRevenueState();
}

class _AdminDailyRevenueState extends State<AdminDailyRevenue> {
  List<DailyRevenue> chartData = [];

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    try {
      final url = Uri.parse("http://127.0.0.1:8000/daily_revenue");
      final response = await http.get(url);
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data["result"] != null && data["result"] is List) {
        final List<dynamic> result = data["result"];

        setState(() {
          chartData = result.map((item) {
            return DailyRevenue(
              date: item["date"],
              amount: (item["total"] ?? 0) ~/ 10000, // 만원 단위 변환
            );
          }).toList();
        });
      } else {
        Get.snackbar("오류", "서버에서 매출 데이터를 불러오지 못했습니다.");
      }
    } catch (e) {
      Get.snackbar("에러", "서버 통신 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일자별 매출 현황')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('• 모든 일자별 매출 현황', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(title: AxisTitle(text: '단위: 만원')),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<DailyRevenue, String>(
                    dataSource: chartData,
                    xValueMapper: (DailyRevenue data, _) => data.date,
                    yValueMapper: (DailyRevenue data, _) => data.amount,
                    color: Colors.orange,
                    name: '매출',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
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

class DailyRevenue {
  final String date;
  final int amount;

  DailyRevenue({required this.date, required this.amount});
}