import 'package:flutter/material.dart';
import 'package:pos_kasir/checkout.dart';
import 'package:pos_kasir/home.dart';
import 'package:pos_kasir/login_screen.dart';
import 'package:pos_kasir/tambahmenu.dart';
import 'database_helper.dart';
import 'navbar.dart';

class EditMakanan extends StatefulWidget {
  final Map<String, dynamic> menu;
  final List<Map<String, dynamic>> checkoutItems;

  const EditMakanan({Key? key, required this.menu, required this.checkoutItems})
      : super(key: key);

  @override
  _EditMakananState createState() => _EditMakananState();
}

class _EditMakananState extends State<EditMakanan> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu['name']);
    _priceController =
        TextEditingController(text: widget.menu['price'].toString());
    _descriptionController =
        TextEditingController(text: widget.menu['description']);
    _category = widget.menu['category'];
  }

  Future<void> _updateMenu() async {
    if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      final updatedMenu = {
        'name': _nameController.text,
        'price': int.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        'description': _descriptionController.text,
        'category': _category,
      };

      await DatabaseHelper.instance.updateMenu(widget.menu['id'], updatedMenu);
      Navigator.pop(context, 'update');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon isi semua field'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteMenu() async {
    await DatabaseHelper.instance.deleteMenu(widget.menu['id']);
    Navigator.pop(context, 'delete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Makanan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Konfirmasi Hapus'),
                    content: Text('Apakah Anda yakin ingin menghapus menu ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteMenu();
                          Navigator.pop(context);
                        },
                        child: Text('Hapus', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Menu',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga (Rp)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['Makanan', 'Minuman', 'Snack']
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _updateMenu,
              icon: Icon(Icons.save , color: Colors.white),
              label: Text('Simpan Perubahan', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 1,
        onTabTapped: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    Home(checkoutItems: widget.checkoutItems),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    TambahMenu(checkoutItems: widget.checkoutItems),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    Checkout(checkoutItems: widget.checkoutItems),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LoginScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        },
      ),
    );
  }
}
