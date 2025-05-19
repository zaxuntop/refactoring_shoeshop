import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/dealer/dealer_widget/dealer_widget.dart';

class DealerMain extends StatefulWidget {
  const DealerMain({super.key});

  @override
  State<DealerMain> createState() => _DealerMainState();
}

class _DealerMainState extends State<DealerMain> {
  @override
  final box = GetStorage();
  List data = [];
  String eid = '';
  String dadminname = '';
  String dal = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () async {
      eid = box.read('adminId') ?? '';
      // print("✅ 로그인 ID: $eid");

      if (eid.isNotEmpty) {
        await fetchDistrictName();
        await fetchOrderData();
      }

      setState(() {});
    });
  }

  Future<void> fetchDistrictName() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/district?eid=$eid'));
    final result = json.decode(utf8.decode(response.bodyBytes));
    dadminname = result['ename'] ?? '';
  }

  Future<void> fetchOrderData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/list'));
    final all = json.decode(utf8.decode(response.bodyBytes))['results'] ?? [];

    data = all.where((item) {
      return item['oeid'].toString() == eid && (item['odate'] ?? '').startsWith(dal);
    }).toList();

    print("📦 ${data.length}건 주문 불러옴");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DealerDrawer(),
      appBar: AppBar(
        title: Text("[$dadminname] $dal 매출"),
      ),
      body: data.isEmpty
          ? const Center(child: Text('이번 달 매출이 없습니다.'))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final sales = (item['pprice'] ?? 0) * (item['ocount'] ?? 0);
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("날짜: ${item['odate']}"),
                    subtitle: Text("${item['pbrand']} (${item['ocount']})개"),
                    trailing: Text("₩$sales"),
                  ),
                );
              },
            ),
    );
  }
}
