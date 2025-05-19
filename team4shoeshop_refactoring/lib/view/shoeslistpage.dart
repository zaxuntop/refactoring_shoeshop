import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'edit_profile_page.dart';
import 'location_search.dart';
import 'returns.dart';
import 'shoes_detail_page.dart';
import 'orderviewpage.dart';
import 'cart.dart';

class Shoeslistpage extends StatefulWidget {
  const Shoeslistpage({super.key});

  @override
  State<Shoeslistpage> createState() => _ShoeslistpageState();
}

class _ShoeslistpageState extends State<Shoeslistpage> {
  final box = GetStorage();
  String userId = "";

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    userId = box.read('p_userId') ?? '';
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse("http://127.0.0.1:8000/product_list");
    final response = await http.get(url);
    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (data["result"] is List) {
      setState(() {
        _products = List<Map<String, dynamic>>.from(data["result"]);
        _filteredProducts = _products;
      });
    }
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final selectedSize = product['psize'] ?? 250;
    final isSoldOut = (product['pstock'] ?? 0) <= 0;

    return Opacity(
      opacity: isSoldOut ? 0.5 : 1.0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        child: InkWell(
          onTap: isSoldOut
              ? null
              : () {
                  Get.to(() => ShoesDetailPage(product: product, selectedSize: selectedSize));
                },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'http://127.0.0.1:8000/view/${product['pid']}?t=${DateTime.now().millisecondsSinceEpoch}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: Text("이미지 없음")),
                          ),
                        ),
                      ),
                      if (isSoldOut)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.black.withOpacity(0.7),
                            child: const Text(
                              '품절',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product["pname"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${product["pprice"]}원',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('브랜드: ${product["pbrand"] ?? ""}', style: const TextStyle(fontSize: 12)),
                      Text('색상: ${product["pcolor"]}', style: const TextStyle(fontSize: 12)),
                      Text('사이즈: ${product["psize"]}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: '제품명 검색',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.purple[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (query) {
          _searchText = query;
          _filteredProducts = _products
              .where((p) => p["pname"]
                  .toString()
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
              .toList();
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('상품 구매 화면'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: '주문내역',
            onPressed: () => Get.to(() => const OrderViewPage()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('상품이 없습니다.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  
}


class MainDrawer extends StatelessWidget {
  final box = GetStorage();

  MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    String userId = box.read('p_userId') ?? '';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userId.isNotEmpty ? userId : '로그인 필요',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: null,
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildTile(context, Icons.shopping_bag, '상품 구매', () {
                  Get.back();
                }),
                _buildTile(context, Icons.person_outline, '회원정보 수정', () {
                  Get.to(() => const EditProfilePage());
                }),
                _buildTile(context, Icons.receipt_long, '내 주문 내역', () {
                  Get.to(() => const OrderViewPage());
                }),
                _buildTile(context, Icons.shopping_cart, '장바구니', () {
                  Get.to(() => const CartPage());
                }),
                _buildTile(context, Icons.location_on, '위치 검색', () {
                  Get.to(() => const LocationSearch());
                }),
                _buildTile(context, Icons.assignment_return, '반품 내역 확인', () {
                  Get.to(() => const Returns());
                }),
                const Divider(height: 30),
                _buildTile(context, Icons.logout, '로그아웃', () {
                  box.erase();
                  Get.offAllNamed('/');
                }, iconColor: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
      horizontalTitleGap: 8.0,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.grey[200],
    );
  }
}