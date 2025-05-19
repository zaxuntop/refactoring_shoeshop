import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/view/adminlogin.dart';
import 'package:team4shoeshop_refactoring/view/shoeslistpage.dart';
import 'joincustomer.dart'; // 회원가입 화면 import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  // 로그인 함수
  Future<void> login() async {
    final url = Uri.parse("http://127.0.0.1:8000/login");
    final request = http.MultipartRequest('POST', url);
    request.fields['cid'] = idController.text.trim();
    request.fields['cpassword'] = pwController.text.trim();

    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);

      if (data["result"] == "success") {
        // ✅ 로그인된 사용자 cid 저장
        final box = GetStorage();
        box.write('p_userId', idController.text.trim());

        Get.snackbar("환영합니다", "${data["cname"]}님");
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAll(() => const Shoeslistpage());
        });
      } else {
        Get.snackbar("실패", "아이디 또는 비밀번호가 틀렸습니다.");
      }
    } catch (e) {
      Get.snackbar("오류", "서버 오류: $e");
    }
  }

  // 회원가입 이동
  void goToJoin() {
    Get.to(() => const Joincustomer());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: "아이디"),
            ),
            TextField(
              controller: pwController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "비밀번호"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("로그인")),
            TextButton(onPressed: goToJoin, child: const Text("회원가입")),
            ElevatedButton(
              onPressed: () {
                Get.to(() => const Adminlogin());
              },
              child: const Text("관리자 로그인"),
            ),
          ],
        ),
      ),
    );
  }
}
