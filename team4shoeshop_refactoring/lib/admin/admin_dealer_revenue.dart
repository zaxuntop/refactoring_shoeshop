import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDealerRevenue extends StatefulWidget {
  const AdminDealerRevenue({super.key});

  @override
  State<AdminDealerRevenue> createState() => _AdminDealerRevenueState();
}

class _AdminDealerRevenueState extends State<AdminDealerRevenue> {
  List<DealerRevenue> chartData = [];

  String selectedYear = DateTime.now().year.toString();
  String selectedMonth = DateTime.now().month.toString().padLeft(2, '0');

  final List<String> years = ['2024', '2025'];
  final List<String> months = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    try {
      final url = Uri.parse(
        'http://192.168.50.236:8000/dealer_revenue?year=$selectedYear&month=$selectedMonth',
      );

      final response = await http.get(url);
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['result'] != null && data['result'] is List) {
        setState(() {
          chartData = data['result'].map<DealerRevenue>((item) {
            return DealerRevenue(
              name: item['ename'],
              amount: (item['total'] ?? 0) ~/ 10000, // 만원 단위
            );
          }).toList();
        });
      } else {
        setState(() {
          chartData = [];
        });
      }
    } catch (e) {
      print('❗ 에러: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매장별 매출 현황'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('• 선택한 월의 매장별 매출 (단위: 만원)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedYear,
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y년'))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedYear = val);
                      fetchChartData();
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedMonth,
                  items: months.map((m) => DropdownMenuItem(value: m, child: Text('$m월'))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedMonth = val);
                      fetchChartData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: '매장명'),
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: '매출 (만원)'),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<DealerRevenue, String>(
                    dataSource: chartData,
                    xValueMapper: (DealerRevenue data, _) => data.name,
                    yValueMapper: (DealerRevenue data, _) => data.amount.toDouble(),
                    color: Colors.deepOrange,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DealerRevenue {
  final String name;
  final int amount;

  DealerRevenue({required this.name, required this.amount});
}