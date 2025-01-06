import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Format untuk harga
import 'edit_makanan.dart';

class Deskripsi extends StatelessWidget {
  final Map<String, dynamic> menu;
  final List<Map<String, dynamic>> checkoutItems;

  const Deskripsi({Key? key, required this.menu, required this.checkoutItems})
      : super(key: key);

  String formatCurrency(int value) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Makanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.teal.withOpacity(0.2),
                    child: Icon(
                      Icons.fastfood,
                      size: 60,
                      color: Colors.teal,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  menu['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Divider(height: 30, thickness: 1),
                _buildDetailRow('Harga:', formatCurrency(menu['price'])),
                SizedBox(height: 15),
                _buildDetailRow(
                  'Deskripsi:',
                  menu['description'] ?? 'Tidak ada deskripsi',
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMakanan(
                          menu: menu,
                          checkoutItems: checkoutItems,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Edit Makanan'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
