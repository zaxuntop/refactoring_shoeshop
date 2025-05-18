import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'shoeslistpage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final box = GetStorage();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cardNumController = TextEditingController();
  final cardCvcController = TextEditingController();
  final cardDateController = TextEditingController();

  String userId = "";

  @override
  void initState() {
    super.initState();
    userId = box.read('p_userId') ?? '';
    if (userId.isNotEmpty) {
      fetchCustomerInfo();
    }
  }

  Future<void> fetchCustomerInfo() async {
    final url = Uri.parse("http://127.0.0.1:8000/customer_info?cid=$userId");
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));

    if (data["result"] == "OK") {
      setState(() {
        nameController.text = data["cname"] ?? '';
        phoneController.text = data["cphone"] ?? '';
        emailController.text = data["cemail"] ?? '';
        addressController.text = data["caddress"] ?? '';
        cardNumController.text = (data["ccardnum"] ?? '').toString();
        cardCvcController.text = (data["ccardcvc"] ?? '').toString();
        cardDateController.text = (data["ccarddate"] ?? '').toString();
      });
    } else {
      Get.snackbar("오류", "회원 정보를 불러오지 못했습니다.");
    }
  }

  Future<void> updateProfile() async {
    final url = Uri.parse("http://127.0.0.1:8000/update_customer");
    final request = http.MultipartRequest('POST', url);

    request.fields['cid'] = userId;
    request.fields['cname'] = nameController.text.trim();
    request.fields['cphone'] = phoneController.text.trim();
    request.fields['cemail'] = emailController.text.trim();
    request.fields['caddress'] = addressController.text.trim();
    request.fields['ccardnum'] = cardNumController.text.trim().isEmpty ? "0" : cardNumController.text.trim();
    request.fields['ccardcvc'] = cardCvcController.text.trim().isEmpty ? "0" : cardCvcController.text.trim();
    request.fields['ccarddate'] = cardDateController.text.trim().isEmpty ? "0" : cardDateController.text.trim();

    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);

      if (data["result"] == "OK") {
        Get.snackbar("완료", "회원 정보가 수정되었습니다.");
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAll(() => const Shoeslistpage());
        });
      } else {
        Get.snackbar("오류", "회원 정보 수정에 실패했습니다.");
      }
    } catch (e) {
      Get.snackbar("에러", "서버 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원정보 수정")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "이름")),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "전화번호")),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "이메일")),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: "주소")),
              const SizedBox(height: 12),
              const Divider(),
              TextField(controller: cardNumController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "카드번호")),
              TextField(controller: cardCvcController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "CVC")),
              TextField(controller: cardDateController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "유효기간(예: 202512)")),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProfile,
                child: const Text("수정 완료"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}