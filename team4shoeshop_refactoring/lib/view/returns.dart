import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class Returns extends StatefulWidget {
  const Returns({super.key});

  @override
  State<Returns> createState() => _ReturnsState();
}

class _ReturnsState extends State<Returns> {
  final box = GetStorage();
  List<Map<String, dynamic>> returns = [];

  @override
  void initState() {
    super.initState();
    fetchReturns();
  }

  Future<void> fetchReturns() async {
    final cid = box.read('p_userId');
    final url = Uri.parse('http://192.168.50.236:8000/returns?cid=$cid');
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));

    if (data['result'] is List) {
      setState(() {
        returns = List<Map<String, dynamic>>.from(data['result']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("반품 내역")),
      body: returns.isEmpty
          ? const Center(child: Text("반품 내역이 없습니다."))
          : ListView.builder(
              itemCount: returns.length,
              itemBuilder: (context, index) {
                final item = returns[index];
                final total = item["pprice"] * item["count"];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("${item["pname"]} (${item["count"]}개)"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("색상: ${item["pcolor"]} / 사이즈: ${item["psize"]}"),
                        Text("반품상태: ${item["return_status"]}"),
                        Text("주문일: ${item["date"]}"),
                        Text("환불금액: ${total}원"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}