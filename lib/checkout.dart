import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_kasir/database_helper.dart';
import 'package:pos_kasir/login_screen.dart';
import 'package:pos_kasir/tambahmenu.dart';
import 'package:pos_kasir/laporan.dart';
import 'home.dart';
import 'navbar.dart';

class Checkout extends StatefulWidget {
  final List<Map<String, dynamic>> checkoutItems;

  const Checkout({Key? key, required this.checkoutItems}) : super(key: key);

  @override
  CheckoutState createState() => CheckoutState();
}

class CheckoutState extends State<Checkout> {
  final _currencyFormatter = NumberFormat.decimalPattern('id');
  final TextEditingController _priceController = TextEditingController();

  String? _selectedPaymentMethod;
  int? _customerCash;
  int? _changeAmount;

  void _removeItem(int id) {
    setState(() {
      widget.checkoutItems.removeWhere((item) => item['id'] == id);
    });
  }

  num _calculateTotal() {
    return widget.checkoutItems.fold(
      0,
      (total, item) => total + (item['price'] * item['quantity']),
    );
  }

  String formatCurrency(String value) {
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return _currencyFormatter.format(number);
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Center(
                child: Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.attach_money, color: Colors.teal),
                    title: Text('Cash'),
                    trailing: Radio<String>(
                      value: 'Cash',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() => _selectedPaymentMethod = value);
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.qr_code_scanner, color: Colors.teal),
                    title: Text('QRIS'),
                    trailing: Radio<String>(
                      value: 'QRIS',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() => _selectedPaymentMethod = value);
                      },
                    ),
                  ),
                  if (_selectedPaymentMethod == 'Cash') ...[
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Uang dari pelanggan',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _priceController.value =
                              _priceController.value.copyWith(
                            text: formatCurrency(value),
                            selection: TextSelection.collapsed(
                              offset: formatCurrency(value).length,
                            ),
                          );
                          _customerCash = int.tryParse(
                                  value.replaceAll(RegExp(r'[^0-9]'), '')) ??
                              0;
                          _changeAmount =
                              _customerCash! - _calculateTotal().toInt();
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    if (_changeAmount != null)
                      Text(
                        _changeAmount! >= 0
                            ? 'Total: Rp ${_currencyFormatter.format(_calculateTotal())}\nKembalian: Rp ${_currencyFormatter.format(_changeAmount)}'
                            : 'Total: Rp ${_currencyFormatter.format(_calculateTotal())}\nUang tidak mencukupi!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              _changeAmount! >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: _selectedPaymentMethod != null &&
                          (_selectedPaymentMethod == 'QRIS' ||
                              (_selectedPaymentMethod == 'Cash' &&
                                  _customerCash != null &&
                                  _changeAmount! >= 0))
                      ? () async {
                          final totalAmount = _calculateTotal().toInt();
                          final transaction = {
                            'date': DateTime.now().toIso8601String(),
                            'total': totalAmount,
                            'payment_method': _selectedPaymentMethod ??
                                'Unknown', // Save payment method
                            'change': _changeAmount ?? 0, // Save change amount
                          };

                          // Save the transaction in the database
                          await DatabaseHelper.instance
                              .insertTransaction(transaction);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pembayaran berhasil!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          setState(() {
                            widget.checkoutItems.clear();
                            _selectedPaymentMethod = null;
                            _customerCash = null;
                            _changeAmount = null;
                          });

                          // Redirect to the laporan page after payment success
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Laporan(
                                    checkoutItems: widget.checkoutItems)),
                          );
                        }
                      : null,
                  child: Text('Bayar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Checkout',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.checkoutItems.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada item di keranjang',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.checkoutItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.checkoutItems[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        shadowColor: Colors.black45,
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: Icon(Icons.fastfood, color: Colors.teal),
                          ),
                          title: Text(item['name'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Rp ${_currencyFormatter.format(item['price'])} x ${item['quantity']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    if (item['quantity'] > 1) {
                                      item['quantity']--;
                                    } else {
                                      _removeItem(item['id']);
                                    }
                                  });
                                },
                              ),
                              Text('${item['quantity']}',
                                  style: TextStyle(fontSize: 18)),
                              IconButton(
                                icon:
                                    Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () {
                                  setState(() {
                                    item['quantity']++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rp ${_currencyFormatter.format(_calculateTotal())}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: Icon(Icons.payment, color: Colors.white),
                  label: Text('Bayar',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  onPressed: _showPaymentDialog,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 2,
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
