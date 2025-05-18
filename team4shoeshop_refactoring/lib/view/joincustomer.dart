import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class Joincustomer extends StatefulWidget {
  const Joincustomer({super.key});

  @override
  State<Joincustomer> createState() => _JoincustomerState();
}

class _JoincustomerState extends State<Joincustomer> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // 아이디 중복 체크
  Future<void> checkDuplicateId() async {
    final cid = idController.text.trim();
    if (cid.isEmpty) {
      Get.snackbar("오류", "아이디를 입력하세요");
      return;
    }

    try {
      final url = Uri.parse("http://127.0.0.1:8000/check_customer_id?cid=$cid");
      final response = await http.get(url);
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data["result"] == "exists") {
        Get.snackbar("중복", "이미 존재하는 아이디입니다.");
      } else if (data["result"] == "available") {
        Get.snackbar("확인", "사용 가능한 아이디입니다.");
      } else {
        Get.snackbar("오류", "서버 오류 발생");
      }
    } catch (e) {
      Get.snackbar("오류", "서버 통신 오류: $e");
    }
  }

  // 회원가입 요청
  Future<void> registerCustomer() async {
    final url = Uri.parse("http://127.0.0.1:8000/insert_customer");
    final request = http.MultipartRequest('POST', url);

    request.fields['cid'] = idController.text.trim();
    request.fields['cname'] = nameController.text.trim();
    request.fields['cpassword'] = pwController.text.trim();
    request.fields['cphone'] = phoneController.text.trim();
    request.fields['cemail'] = emailController.text.trim();
    request.fields['caddress'] = addressController.text.trim();

    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);

      if (data["result"] == "OK") {
        Get.snackbar("성공", "회원가입이 완료되었습니다.");
        Get.back();
      } else {
        Get.snackbar("실패", "회원가입에 실패했습니다.");
      }
    } catch (e) {
      Get.snackbar("오류", "서버 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입 (FastAPI)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: "아이디")),
            ElevatedButton(onPressed: checkDuplicateId, child: const Text("중복체크")),
            TextField(controller: pwController, decoration: const InputDecoration(labelText: "비밀번호")),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "이름")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "전화번호")),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "이메일")),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "주소")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: registerCustomer, child: const Text("회원가입")),
          ]),
        ),
      ),
    );
  }
}