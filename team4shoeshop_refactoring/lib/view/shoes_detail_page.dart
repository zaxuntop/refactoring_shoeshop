import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/view/cart.dart';
import 'buy.dart';

class ShoesDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final int selectedSize;


  const ShoesDetailPage({
    required this.product,
    required this.selectedSize,
    super.key,
  });

  @override
  State<ShoesDetailPage> createState() => _ShoesDetailPageState();
}

class _ShoesDetailPageState extends State<ShoesDetailPage> {
  final box = GetStorage();
  int quantity = 1;
  List<Map<String, dynamic>> dealers = [];
  String? selectedDealer;
  

  @override
  void initState() {
    super.initState();
    fetchDealers();
  }

  Future<void> fetchDealers() async {
    final url = Uri.parse("http://192.168.50.236:8000/employee_list");
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));

    if (data["result"] is List) {
      setState(() {
        dealers = List<Map<String, dynamic>>.from(data["result"]);
        if (dealers.isNotEmpty) {
          selectedDealer = dealers.first["eid"];
        }
      });
    }
  }

  Future<void> addToCart() async {
    final cid = box.read("p_userId");
    if (cid == null) return;

    if (selectedDealer == null) {
      Get.snackbar("대리점 선택", "대리점을 선택해주세요");
      return;
    }

    final url = Uri.parse("http://192.168.50.236:8000/add_to_cart");
    final request = http.MultipartRequest("POST", url);
    request.fields["cid"] = cid;
    request.fields["pid"] = widget.product["pid"];
    request.fields["count"] = quantity.toString();
    request.fields["oeid"] = selectedDealer!;

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    final data = json.decode(resBody);

    if (data["result"] == "OK") {
      Get.snackbar("추가 완료", "장바구니에 추가되었습니다.");
    } else {
      Get.snackbar("실패", "장바구니 추가 실패");
    }
  }

  Future<void> goToBuy() async {
    final cid = box.read("p_userId");
    if (cid == null) return;

    // 카드 정보 확인
    final res = await http.get(
      Uri.parse("http://192.168.50.236:8000/customer_info?cid=$cid"),
    );
    final data = json.decode(utf8.decode(res.bodyBytes));

    if (data["result"] != "OK" ||
        data["ccardnum"] == null ||
        data["ccardcvc"] == null ||
        data["ccarddate"] == null) {
      Get.snackbar("카드 정보 없음", "회원정보 수정이 필요합니다.");
      await Future.delayed(const Duration(seconds: 1));
      Get.toNamed('/edit_profile');
      return;
    }

    final dealerName =
        dealers.firstWhere((e) => e["eid"] == selectedDealer)["ename"];

    Get.to(
      () => const BuyPage(),
      arguments: {
        "product": widget.product,
        "quantity": quantity,
        "storeId": selectedDealer,
        "storeName": dealerName,
        "selectedSize": widget.selectedSize,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imageUrl =
        "http://192.168.50.236:8000/view/${product['pid']}?t=${DateTime.now().millisecondsSinceEpoch}";

    return Scaffold(
      appBar: AppBar(
        title: Text("상품 상세"),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => CartPage(), arguments: {
                'userID': box.read('p_userId')
              });
            },
            icon: Icon(Icons.card_travel)
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: Text("이미지 없음")),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(product["pname"], style: const TextStyle(fontSize: 18)),
            Text(
              "${product["pprice"]}원",
              style: const TextStyle(color: Colors.red),
            ),
            Text("색상: ${product["pcolor"]}"),
            Text("사이즈: ${widget.selectedSize}"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("수량", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<int>(
                  value: quantity,
                  items:
                      List.generate(product["pstock"], (i) => i + 1)
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text("$e")),
                          )
                          .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => quantity = v);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "대리점",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedDealer,
                  items:
                      dealers.map((dealer) {
                        return DropdownMenuItem<String>(
                          value: dealer["eid"].toString(),
                          child: Text(dealer["ename"].toString()),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() => selectedDealer = value);
                  },
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: addToCart, child: const Text("장바구니")),
                ElevatedButton(onPressed: goToBuy, child: const Text("구매하기")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
