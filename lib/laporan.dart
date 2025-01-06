import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_kasir/checkout.dart';
import 'package:pos_kasir/database_helper.dart';
import 'package:pos_kasir/home.dart';
import 'package:pos_kasir/login_screen.dart';
import 'package:pos_kasir/tambahmenu.dart';
import 'navbar.dart';

class Laporan extends StatefulWidget {
  final List<Map<String, dynamic>> checkoutItems;

  const Laporan({Key? key, required this.checkoutItems}) : super(key: key);

  @override
  _LaporanState createState() => _LaporanState();
}

class _LaporanState extends State<Laporan> {
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await DatabaseHelper.instance.getAllTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  Future<List<Map<String, dynamic>>> _getTransactionItems(int transactionId) async {
    final items = await DatabaseHelper.instance.getTransactionItems(transactionId);
    final itemDetails = await Future.wait(items.map((item) async {
      final menu = await DatabaseHelper.instance.getMenus();
      final menuItem = menu.firstWhere(
        (menu) => menu['id'] == item['menu_id'],
        orElse: () => {'name': 'Unknown'},
      );
      return {
        'name': menuItem['name'],
        'quantity': item['quantity'],
      };
    }));
    return itemDetails;
  }

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Transaksi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: _transactions.isEmpty
          ? Center(
              child: Text(
                'Tidak ada transaksi.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final transactionId = transaction['id'];
                final totalAmount = transaction['total'] ?? 0;
                final paymentMethod = transaction['payment_method'] ?? 'Unknown';
                final customerCash = transaction['customer_cash'] ?? 0;
                final change = transaction['change'] ?? 0;
                final date = _formatDate(transaction['date']);

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getTransactionItems(transactionId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final items = snapshot.data ?? [];
                    final totalItems = items.fold<int>(
                        0, (sum, item) => sum + (item['quantity'] as int));

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 6,
                      child: ExpansionTile(
                        leading: Icon(Icons.receipt_long, color: Colors.teal),
                        title: Text(
                          'Rp ${NumberFormat.decimalPattern('id').format(totalAmount)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('Tanggal: $date'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(),
                                Text(
                                  'Metode Pembayaran: $paymentMethod',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Jumlah Item Terjual: $totalItems',
                                  style: TextStyle(fontSize: 14),
                                ),
                                ...items.map(
                                  (item) => Text(
                                    '${item['name']} x ${item['quantity']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                if (paymentMethod == 'Cash') ...[
                                  SizedBox(height: 8),
                                  Text(
                                    'Uang Pembeli: Rp ${NumberFormat.decimalPattern('id').format(customerCash)}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Kembalian: Rp ${NumberFormat.decimalPattern('id').format(change)}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: Navbar(
        currentIndex: 3, // Sesuaikan dengan index Laporan
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
                    Laporan(checkoutItems: widget.checkoutItems),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 4) {
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
