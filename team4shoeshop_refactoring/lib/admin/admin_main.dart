/*
2025.05.05 이학현 / admin 폴더, admin 로그인 후 넘어오는 메인 화면 생성
*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';


class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  // late DatabaseHandler handler;
  final box = GetStorage();
  int lowStock = 0;
  int todaySales = 0;
  int yesterdaySales = 0;
  int approval = 0;
  int returnCount = 0;

  @override
  void initState() {
    super.initState();
    final permission = box.read('adminPermission');
    // handler = DatabaseHandler();
    getJSONData();
    getApprovalCount(permission);
  }

    getJSONData()async{
    var response = await http.get(Uri.parse("http://127.0.0.1:8000/a_low_stock"));
    var response1 = await http.get(Uri.parse("http://127.0.0.1:8000/a_today_sales"));
    var response2 = await http.get(Uri.parse("http://127.0.0.1:8000/a_yesterday_sales"));
    var response4 = await http.get(Uri.parse("http://127.0.0.1:8000/a_return_count"));
    lowStock = (json.decode(utf8.decode(response.bodyBytes))['result'])??0;
    todaySales = (json.decode(utf8.decode(response1.bodyBytes))['result'])??0;
    yesterdaySales = (json.decode(utf8.decode(response2.bodyBytes))['result'])??0;
    returnCount = (json.decode(utf8.decode(response4.bodyBytes))['result'])??0;
    setState(() {});
    // print(aData); // 데이터 잘 들어오는지 확인용
  }

    getApprovalCount(int permission)async{
    var response3 = await http.get(Uri.parse("http://127.0.0.1:8000/a_approval_count/$permission"));
    approval = (json.decode(utf8.decode(response3.bodyBytes))['result'])??0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AdminDrawer(),
          appBar: AppBar(
      title: Text(
          '매장 통합 관리 시스템',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
    ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
Container(
  color: Colors.white,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // 중앙 콘텐츠
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 60),
        child: SizedBox(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue[100]
              ),
              height: 80,
              width: 300,
              child: Center(
                child: Text("재고가 30개 미만인 상품이 $lowStock개 있습니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        child: Center(
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue[100]
              ),
            height: 80,
            width: 300,
            child: Center(
              child: Text("전일 매출은 $yesterdaySales원 입니다.\n금일 매출은 $todaySales원 입니다.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 60, 0, 60),
        child: SizedBox(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue[100]
              ),
              height: 80,
              width: 300,
              child: Center(
                child: Text("결재할 문서가 $approval건 있습니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        child: Center(
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue[100]
              ),
            height: 80,
            width: 300,
            child: Center(
              child: Text("반품 접수가 $returnCount건 있습니다.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
        ],
      ),
    );
  } // build

// Future<int> getLowStockCount() async {
//   final Database db = await handler.initializeDB();
//   final result = await db.rawQuery('select count(*) from product where pstock < 30');
//   return Sqflite.firstIntValue(result) ?? 0;
// }

// Future<int> getTodaySales() async {
//   final Database db = await handler.initializeDB();
//   final String today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

  // final result = await db.rawQuery('select sum(p.pprice*o.ocount) from product p, orders o where o.opid=p.pid and o.oreturncount=0 and o.odate=?',[today]);
//   return Sqflite.firstIntValue(result) ?? 0;
// }

// Future<int> getYesterdaySales() async {
//   final Database db = await handler.initializeDB();
//   final DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
//   final String yesterdayString = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

//   final result = await db.rawQuery('select sum(p.pprice*o.ocount) from product p, orders o where o.opid=p.pid and o.odate=?',[yesterdayString]);
//   return Sqflite.firstIntValue(result) ?? 0;
// }

// Future<int> getapprovalCount() async {
//   final Database db = await handler.initializeDB();
//   final adminPermission = box.read('adminPermission');
//   int count = 0;
//   if (adminPermission == 2) {
//     final result = await db.rawQuery('select count(*) from approval a where a.astatus = "대기"');
//     count = Sqflite.firstIntValue(result) ?? 0;
//   } else if (adminPermission == 3) {
//     final result = await db.rawQuery('select count(*) from approval a where a.astatus = "팀장승인"');
//     count = Sqflite.firstIntValue(result) ?? 0;
//   }
//   return count;
// }

// Future<int> getReturnCount() async {
//   final Database db = await handler.initializeDB();
//   final result = await db.rawQuery('select count(*) from orders where oreturnstatus = "요청"');
//   return Sqflite.firstIntValue(result) ?? 0;
// }
} // class