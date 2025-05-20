import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:team4shoeshop_refactoring/admin/admin_approval.dart';
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';

class AdminInvenPage extends StatefulWidget {
  const AdminInvenPage({super.key});

  @override
  _AdminInvenPageState createState() => _AdminInvenPageState();
}

class _AdminInvenPageState extends State<AdminInvenPage> {
  final GetStorage _storage = GetStorage();
  late String _adminLevel;
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // GetStorage에서 관리자 등급 읽어오기
    _adminLevel = _storage.read('adminLevel') ?? 'guest';
    _fetchInventory();
  }

  void _fetchInventory() async {
    try {
      final uri = Uri.parse('http://192.168.50.236:8000/a_inventory');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Admin-Level': _adminLevel,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
          _items = data['result'] as List<dynamic>;
          _isLoading = false;
          _items.sort((a, b) => a['pstock'].compareTo(b['pstock']));
        setState(() { });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(),
      appBar: AppBar(
        title: Text('관리자 재고 현황'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(AdminApproval());
            }, 
            icon: Icon(Icons.approval)
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isLow = item['pstock'] < 30;
                return Card(
                  color: isLow ? Colors.redAccent.shade100 : Colors.grey,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      '${item['pbrand']} ${item['pname']}',
                      style: TextStyle(
                          color: isLow ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '사이즈: ${item['psize']}, 색상: ${item['pcolor']}\n재고: ${item['pstock']}',
                      style: TextStyle(
                          color: isLow ? Colors.white70 : Colors.black87),
                    ),
                  ),
                );
              },
            ),
    );
  }
}