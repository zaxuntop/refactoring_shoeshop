import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';

class AdminProductInsertPage extends StatefulWidget {
  const AdminProductInsertPage({super.key});

  @override
  State<AdminProductInsertPage> createState() => _AdminProductInsertPageState();
}

class _AdminProductInsertPageState extends State<AdminProductInsertPage> {
  final _formKey = GlobalKey<FormState>();
  final box = GetStorage();

  final TextEditingController _pid = TextEditingController();
  final TextEditingController _pname = TextEditingController();
  final TextEditingController _pstock = TextEditingController();
  final TextEditingController _pprice = TextEditingController();

  String? _selectedBrand;
  String? _selectedSize;
  String? _selectedColor;

  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  final List<String> _brands = ['나이키', '아디다스', '뉴발란스', '컨버스', '리복'];
  final List<String> _sizes = ['230', '240', '250', '260', '270', 'Free'];
  final List<String> _colors = ['블랙', '화이트', '레드', '블루', '그린', '옐로우'];

  bool isHQUser() {
    final eid = box.read('adminId') ?? '';
    return ['h001', 'h002', 'h003'].contains(eid);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = pickedFile);
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      Get.snackbar('오류', '이미지를 선택하세요.');
      return;
    }

    final uri = Uri.parse('http://127.0.0.1:8000/a_product_insert');
    final request = http.MultipartRequest('POST', uri);

    request.fields['pid'] = _pid.text.trim();
    request.fields['pbrand'] = _selectedBrand!;
    request.fields['pname'] = _pname.text.trim();
    request.fields['psize'] = _selectedSize!;
    request.fields['pcolor'] = _selectedColor!;
    request.fields['pstock'] = _pstock.text.trim();
    request.fields['pprice'] = _pprice.text.trim();
    request.files.add(await http.MultipartFile.fromPath('pimage', _image!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      Get.snackbar('성공', '상품이 등록되었습니다.');
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } else {
      final respStr = await response.stream.bytesToString();
      Get.snackbar('실패', '에러 발생: $respStr');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isHQUser()) {
      return Scaffold(
        appBar: AppBar(title: const Text('상품 등록')),
        body: const Center(child: Text('접근 권한이 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('신규 상품 등록')),
      drawer: AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(_pid, '상품 코드'),
              buildTextField(_pname, '상품명'),
              buildTextField(_pprice, '가격', isNumber: true),
              buildTextField(_pstock, '재고 수량', isNumber: true),
              const SizedBox(height: 12),

              buildDropdown('브랜드', _brands, _selectedBrand, (val) {
                setState(() => _selectedBrand = val);
              }),
              const SizedBox(height: 12),

              buildDropdown('사이즈', _sizes, _selectedSize, (val) {
                setState(() => _selectedSize = val);
              }),
              const SizedBox(height: 12),

              buildDropdown('색상', _colors, _selectedColor, (val) {
                setState(() => _selectedColor = val);
              }),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey[100],
                  ),
                  alignment: Alignment.center,
                  child: _image != null
                      ? Image.file(File(_image!.path), fit: BoxFit.cover)
                      : const Text('이미지를 선택하려면 탭하세요'),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitProduct,
                child: const Text('상품 등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label을(를) 입력하세요';
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? '$label을 선택하세요' : null,
    );
  }
}