import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:team4shoeshop_refactoring/dealer/dealer_return_datail.dart';
import 'package:team4shoeshop_refactoring/dealer/dealer_widget/dealer_widget.dart';


class DealerReturn extends StatefulWidget {
  const DealerReturn({super.key});

  @override
  State<DealerReturn> createState() => _DealerReturnState();
}

class _DealerReturnState extends State<DealerReturn> {
  List data = [];

  @override
  void initState() {
    super.initState();
    getReturnData();
  }

Future<void> getReturnData() async {
  var response = await http.get(Uri.parse('http://192.168.50.236:8000/dreturns'));
  final all = json.decode(utf8.decode(response.bodyBytes))['results'];

  data = all.where((item) {
    final status = item['oreturnstatus']?.toString().trim() ?? '';
    return status == '반품요청';
  }).toList();

  setState(() {});
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DealerDrawer(),
      appBar: AppBar(
        title: const Text("반품 내역"),
      ),
      body: data.isEmpty
          ? const Center(child: Text("반품 내역이 없습니다."))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final hasReturn = (item['oreturndate'] != null && item['oreturndate'].toString().isNotEmpty);

                return Card(
                  margin: const EdgeInsets.all(8),
                  color: hasReturn ? Colors.red[50] : null,
                  child: ListTile(
                    leading: const Icon(Icons.assignment_return),
                    title: Text(item['pname'] ?? '상품명 없음'),
                    subtitle: Text(
                      '주문일: ${item['odate']} / 반품일: ${item['oreturndate'] ?? '없음'}',
                      style: TextStyle(
                        color: hasReturn ? Colors.red : Colors.black87,
                        fontWeight: hasReturn ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result = await Get.to(() => DealerReturnDetail(orderMap: item));
                      if (result == true) {
                        getReturnData();
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
