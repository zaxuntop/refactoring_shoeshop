import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'shoeslistpage.dart'; // ✅ 추가

class BuyPage extends StatefulWidget {
  const BuyPage({super.key});

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  final box = GetStorage();
  final TextEditingController passwordController = TextEditingController();
  bool isProcessing = false;

  Widget passwordField() {
    return TextField(
      controller: passwordController,
      obscureText: true,
      maxLength: 2,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "카드 비밀번호 앞 2자리",
        counterText: "",
      ),
    );
  }

  Future<void> submitPurchase() async {
    if (passwordController.text.length != 2) {
      Get.snackbar("비밀번호", "카드 비밀번호 앞 2자리를 입력해주세요");
      return;
    }

    final cid = box.read("p_userId");
    if (cid == null) return;

    final arguments = Get.arguments;
    final isSingleBuy = arguments["product"] != null;

    setState(() => isProcessing = true);

    if (isSingleBuy) {
      final product = arguments["product"];
      final quantity = arguments["quantity"];
      final oeid = arguments["storeId"];

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("http://127.0.0.1:8000/buy_direct"),
      );
      request.fields["cid"] = cid;
      request.fields["pid"] = product["pid"];
      request.fields["count"] = quantity.toString();
      request.fields["oeid"] = oeid;

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);

      if (data["result"] == "OK") {
        Get.snackbar("구매 완료", "상품을 구매하였습니다");
        await Future.delayed(const Duration(seconds: 1));
        Get.offAll(() => const Shoeslistpage()); // ✅ 홈으로 이동
      } else {
        Get.snackbar("실패", "구매 실패: ${data["message"] ?? "알 수 없음"}");
      }
    } else {
      final selectedItems = arguments["items"] as List;
      final encodedItems = json.encode(selectedItems);

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("http://127.0.0.1:8000/buy_selected"),
      );
      request.fields["cid"] = cid;
      request.fields["items"] = encodedItems;

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);

      if (data["result"] == "OK") {
        Get.snackbar("구매 완료", "선택한 상품을 모두 구매하였습니다");
        await Future.delayed(const Duration(seconds: 1));
        Get.offAll(() => const Shoeslistpage()); // ✅ 홈으로 이동
      } else {
        Get.snackbar("실패", "구매 실패: ${data["message"] ?? "알 수 없음"}");
      }
    }

    setState(() => isProcessing = false);
  }

@override
Widget build(BuildContext context) {
  final arguments = Get.arguments ?? {};
  final isSingleBuy = arguments["product"] != null;
  final items = arguments["items"] ?? [];

  return Scaffold(
    appBar: AppBar(title: const Text("결제하기")),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isSingleBuy)
            _buildSingleBuySummary(arguments)
          else
            _buildMultipleBuySummary(items),
          const SizedBox(height: 16),
          passwordField(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isProcessing ? null : submitPurchase,
            child: const Text("결제하기"),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSingleBuySummary(Map args) {
    final product = args["product"];
    final quantity = args["quantity"];
    final price = product["pprice"] * quantity;
    final selectedSize = args["selectedSize"];
    final ename = args["storeName"] ?? "알 수 없음";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("상품 정보", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text("- 상품명: ${product["pname"]}"),
        Text("- 색상: ${product["pcolor"]}"),
        Text("- 사이즈: $selectedSize"),
        Text("- 수량: $quantity"),
        Text("- 대리점: $ename"),
        Text("- 가격: ${price}원"),
      ],
    );
  }

  Widget _buildMultipleBuySummary(List items) {
    num total = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("선택한 상품 목록", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...items.map((item) {
          final price = item["pprice"] * item["count"];
          total += price;
          return Text(
            "- ${item["pname"]} (${item["count"]}개) / 대리점: ${item["ename"]} / ${price}원",
          );
        }).toList(),
        const SizedBox(height: 10),
        Text("총 결제 금액: ${total}원",
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}