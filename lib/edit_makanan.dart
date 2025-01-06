import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_kasir/checkout.dart';
import 'package:pos_kasir/home.dart';
import 'package:pos_kasir/login_screen.dart';
import 'package:pos_kasir/tambahmenu.dart';
import 'package:pos_kasir/navbar.dart';
import 'database_helper.dart';

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
        TextEditingController(text: _formatCurrency(widget.menu['price']));
    _descriptionController =
        TextEditingController(text: widget.menu['description']);
    _category = widget.menu['category'];
  }

  String _formatCurrency(int value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(value);
  }

  String _unformatCurrency(String formatted) {
    return formatted.replaceAll(RegExp(r'[^0-9]'), '');
  }

  void _onPriceChanged(String value) {
    final unformattedValue = int.tryParse(_unformatCurrency(value)) ?? 0;
    _priceController.value = TextEditingValue(
      text: _formatCurrency(unformattedValue),
      selection: TextSelection.collapsed(
          offset: _formatCurrency(unformattedValue).length),
    );
  }

  Future<void> _updateMenu() async {
    if (_nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      final updatedMenu = {
        'name': _nameController.text,
        'price': int.parse(_unformatCurrency(_priceController.text)),
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
        title: Text('Edit Menu',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Konfirmasi Hapus'),
                    content:
                        Text('Apakah Anda yakin ingin menghapus menu ini?'),
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
                        child:
                            Text('Hapus', style: TextStyle(color: Colors.red)),
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
            _buildTextField(
              controller: _nameController,
              label: 'Nama Menu',
              icon: Icons.fastfood,
            ),
            SizedBox(height: 15),
            _buildTextField(
              controller: _priceController,
              label: 'Harga (Rp)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              onChanged: _onPriceChanged,
            ),
            SizedBox(height: 15),
            _buildTextField(
              controller: _descriptionController,
              label: 'Deskripsi',
              icon: Icons.description,
              maxLines: 3,
            ),
            SizedBox(height: 15),
            _buildCategoryDropdown(),
            SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _updateMenu,
              icon: Icon(Icons.save),
              label: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 1,
        onTabTapped: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Home(checkoutItems: widget.checkoutItems),
            ));
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) =>
                  TambahMenu(checkoutItems: widget.checkoutItems),
            ));
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) =>
                  Checkout(checkoutItems: widget.checkoutItems),
            ));
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ));
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.teal.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: InputDecoration(
        labelText: 'Kategori',
        prefixIcon: Icon(Icons.category, color: Colors.teal),
        filled: true,
        fillColor: Colors.teal.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: ['Makanan', 'Minuman', 'Snack']
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _category = value!;
        });
      },
    );
  }
}
