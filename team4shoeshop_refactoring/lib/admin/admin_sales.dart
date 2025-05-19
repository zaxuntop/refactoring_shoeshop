import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';

class AdminSales extends StatefulWidget {
  const AdminSales({super.key});

  @override
  State<AdminSales> createState() => _AdminSalesState();
}

class _AdminSalesState extends State<AdminSales> {
  List<dynamic> salesData = [];
  bool _isLoading = true;

@override
  void initState() {
    super.initState();
    fetchSalesData();
  }

Future fetchSalesData()async{
  try{
    var response = await http.get(Uri.parse('http://127.0.0.1:8000/a_dealer_sales'));
    if (response.statusCode == 200){
      final data = json.decode(utf8.decode(response.bodyBytes));
      salesData = data['result'];
      _isLoading = false;
      setState(() { });
    }else{
      _isLoading = true;
    }
  } catch(e) {
    setState(() { });
    _isLoading = false;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(),
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
        ? Text('데이터를 불러오고 있습니다.')
        : ListView.builder(
          itemCount: salesData.length,
          itemBuilder: (context, index) {
            final item = salesData[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Text(item['ename'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text('어제 매출: ${item['yesterday']}원'),
                    Text('오늘 매출: ${item['today']}원'),
                  ],
                ),
              ),
            );
          },
          ),
      )
    );
  }
}