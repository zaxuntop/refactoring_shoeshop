import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';

class AdminAddApproval extends StatefulWidget {
  const AdminAddApproval({super.key});

  @override
  State<AdminAddApproval> createState() => _AdminAddApprovalState();
}

class _AdminAddApprovalState extends State<AdminAddApproval> {
  // late DatabaseHandler handler;
  String selectedProduct = ''; // 드롭다운에서 선택한 상품
  late TextEditingController controller; // 수량 입력
  List productDetail = [];
  List productList = []; // 재고 30개 미만 상품명
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    // handler = DatabaseHandler();
    controller = TextEditingController();
    loadProducts();
  }

  loadProducts()async{
    var response = await http.get(Uri.parse("http://127.0.0.1:8000/a_low_prd_name"));
    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      productList = decoded['result'].map((e) => e[0]).toList();
    }
    setState(() {});
  }

  lowPrdDetail(String selectedProduct)async{
    var response = await http.get(Uri.parse("http://127.0.0.1:8000/a_low_prd_detail/$selectedProduct"));
    productDetail = (json.decode(utf8.decode(response.bodyBytes))['result'])??[];
    setState(() {});
  }

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            '품의서',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          actions: [
            DropdownButton(
              hint: selectedProduct==''?
              Text('선택')
              :Text(selectedProduct),
              items: productList.map((e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                );
              }).toList(), 
              onChanged: (value) {
                selectedProduct = value!;
                lowPrdDetail(selectedProduct);
                setState(() {});
              },
            ),
          ],
      ),
      drawer: AdminDrawer(),
    body: Center(
    child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 80),
              child: Text("브랜드 | 상품명 | 색상 | 사이즈 | 재고"),
            ),
            Container(
              color: Colors.blue[50],
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: productDetail.isEmpty
                ? Text("정보 없음")
                : Text('${productDetail[0]} | ${productDetail[1]} | ${productDetail[2]} | ${productDetail[3]} | ${productDetail[4]}')
                ,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(100, 20, 100, 20),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '수량',
                  hintText: '주문할 수량을 입력해 주세요'
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if(selectedProduct == "" || controller.text.isEmpty){
                  Get.snackbar(
                    '전송 할 수 없습니다', '상품과 수량을 입력해 주세요',
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.redAccent);
                }else{
                insertAction();
                Navigator.pop(context);
                Get.snackbar(
                  '전송 성공', '품의서를 전송했습니다',
                  backgroundColor: Colors.purple[100]
                  );
                }
              }, 
              child: Text('전송'),
            ),
          ],
        ),
    ),
    ),
  );
} // build

  insertAction()async{
    final eid = box.read('adminId');
    var request = http.MultipartRequest(
      "POST", 
      Uri.parse("http://127.0.0.1:8000/a_insert")
    );
    request.fields['aeid'] = eid;
    request.fields['abaljoo'] = controller.text;
    request.fields['astatus'] = "대기";
    request.fields['apid'] = selectedProduct;
    request.fields['adate'] = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    await request.send();
  }
  
    errorSnackBar(){
    Get.snackbar(
      "경고", 
      "입력 중 문제가 발생했습니다",
      colorText: Theme.of(context).colorScheme.onError,
      backgroundColor: Theme.of(context).colorScheme.error,
      );
  }

  showDialog(){
    Get.defaultDialog(
      title: '입력 결과',
      middleText: '입력이 완료되었습니다.',
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          }, 
          child: Text('나가기'),
        ),
      ]
    );
  }
  // Future<List<String>> getLowStockProducts() async {
  //   final Database db = await handler.initializeDB();
  //   final result = await db.rawQuery('select pname from product where pstock < 30');
  //   return result.map((e) => e['pname'] as String).toList();
  // }

  // Future<void> loadProducts() async {
  //   final db = await handler.initializeDB();
  //   final result = await db.rawQuery('select pname from product where pstock < 30');
  //   setState(() {
  //     productList = result.map((e) => e['pname'] as String).toList();
  //   });
  // }

//   Future<List<String>> getLowStockProducts() async {
//   final Database db = await handler.initializeDB();
//   final result = await db.rawQuery('select p.pbrand, p.pname, p.pcolor, p.psize, p.pstock from product p where p.pname="$selectedProduct"');
//   return result.map((e) => "${e['pbrand']} | ${e['pname']} | ${e['pcolor']} | ${e['psize']} | ${e['pstock']}").toList();
// }

//   Future<int> insertApproval(Approval approval) async{
//     int result = 0;
//     final Database db = await handler.initializeDB();

//     result = await db.rawInsert(
//       'insert into approval(aeid, afid, apid, abaljoo, asoojoo, astatus, adate, ateamappdate, achiefappdate) values (?,?,?,?,?,?,?,?,?)',
//       [approval.aeid, approval.afid, approval.apid, approval.abaljoo, approval.asoojoo, approval.astatus, approval.adate, approval.ateamappdate, approval.achiefappdate]
//     );
//     return result;
//   }
  

//   insertAction()async{
//     final String eid = box.read('adminId');
//     Approval(
//       aeid: eid, 
//       afid: (await getFidByProductName(selectedProduct))!, 
//       abaljoo: int.parse(controller.text), 
//       asoojoo: 0, 
//       astatus: '대기', 
//       adate: "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}", 
//       ateamappdate: '', 
//       achiefappdate: '', 
//       apid: (await getPidByProductName(selectedProduct))!,
//     );
//     // int result = await insertApproval(approvalInsert);
//   }

//   Future<String?> getPidByProductName(String pname) async {
//   final db = await handler.initializeDB();
//   final result = await db.rawQuery(
//     'select pid from product where pname = ?',
//     [pname],
//   );
//   if (result.isNotEmpty) {
//     return result.first['pid'] as String;
//   } else {
//     return null;
//   }
//   }

//   Future<String?> getFidByProductName(String pname) async {
//   final db = await handler.initializeDB();
//   final result = await db.rawQuery(
//     'select fid from product p, factory f where pname = ? and pbrand = fbrand',
//     [pname],
//   );
//   if (result.isNotEmpty) {
//     return result.first['fid'] as String;
//   } else {
//     return null;
//   }
// }
} // class