import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OrderViewPage extends StatefulWidget {
  const OrderViewPage({super.key});

  @override
  State<OrderViewPage> createState() => _OrderViewPageState();
}

class _OrderViewPageState extends State<OrderViewPage> {
  final box = GetStorage();
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final cid = box.read("p_userId");
    final url = Uri.parse("http://192.168.50.236:8000/order_list?cid=$cid");
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));

    if (data["result"] is List) {
      setState(() {
        orders = List<Map<String, dynamic>>.from(data["result"]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("주문 내역")),
      body: orders.isEmpty
          ? const Center(child: Text("결제 완료된 주문이 없습니다."))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final total = order["pprice"] * order["count"];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(
                      "${order["image_url"]}?t=${DateTime.now().millisecondsSinceEpoch}",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                    title: Text(order["pname"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("색상: ${order["pcolor"]}"),
                        Text("사이즈: ${order["psize"]}"),
                        Text("수량: ${order["count"]}"),
                        Text("가격: ${total}원"),
                        Text("대리점: ${order["ename"] ?? "정보 없음"}"),
                        Text("주문일: ${order["odate"]}"),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}