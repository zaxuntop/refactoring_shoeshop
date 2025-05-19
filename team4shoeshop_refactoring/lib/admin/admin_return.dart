import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';


class AdminReturn extends StatefulWidget {
  const AdminReturn({super.key});

  @override
  State<AdminReturn> createState() => _AdminReturnState();
}

class _AdminReturnState extends State<AdminReturn> {
  Future<List<Map<String, dynamic>>> fetchReturnedOrders() async {
    final url = Uri.parse('http://127.0.0.1:8000/return_orders');
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));

    if (data["result"] != null && data["result"] is List) {
      return List<Map<String, dynamic>>.from(data["result"]);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('반품 내역 확인')),
      drawer: AdminDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchReturnedOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('반품 내역이 없습니다.'));
          }

          final dataList = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text('· 반품 접수 및 처리 상태',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('반품번호 | 브랜드 | 제품명 | 컬러 | 사이즈 | 수량 | 반품일자'),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    final item = dataList[index];
                    final date = (item['oreturndate'] as String).split('T').first;

                    return Card(
                      color: Colors.blue[50],
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '${item["oreturnstatus"]} : '
                          '반품번호:${item["oid"]} | ${item["pbrand"]} | ${item["pname"]} | '
                          '${item["pcolor"]} | ${item["psize"]} | ${item["oreturncount"]}개 | $date',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}