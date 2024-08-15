import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 100.0; // Example starting balance
  List<Map<String, String>> _cards = []; // List to store added cards and UPI details
  List<Map<String, String>> _transactions = [ // Example transactions
  {'date': 'Aug 16, 2024', 'amount': '-₹180.00', 'description': 'Juniors ne party maang li', 'location': 'Mehek Canteen'},
    {'date': 'Aug 13, 2024', 'amount': '-₹20.00', 'description': 'Chhoti Gold', 'location': 'Pahan Shop'},
    {'date': 'Aug 12, 2024', 'amount': '+₹2000.00', 'description': 'Thank you papa', 'location': 'Dad'},
    {'date': 'Aug 16, 2024', 'amount': '+₹70.00', 'description': 'Bhai ek roll le aana', 'location': 'Aditya'},
  ];

  // Function to handle adding money to the wallet
  void _addMoney() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController amountController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            'Add Money',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.white),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purpleAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                double? amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  setState(() {
                    _balance += amount; // Update balance
                    _transactions.insert(0, {
                      'date': DateTime.now().toLocal().toString().split(' ')[0],
                      'amount': '+\$${amount.toStringAsFixed(2)}',
                      'description': 'Money Added',
                    }); // Add transaction
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Function to handle sending money from the wallet
  void _sendMoney() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController amountController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            'Send Money',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.white),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purpleAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                double? amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0 && amount <= _balance) {
                  setState(() {
                    _balance -= amount; // Deduct from balance
                    _transactions.insert(0, {
                      'date': DateTime.now().toLocal().toString().split(' ')[0],
                      'amount': '-\$${amount.toStringAsFixed(2)}',
                      'description': 'Money Sent',
                    }); // Add transaction
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Send', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Function to add card or UPI details
  void _addCardDetails(String type) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController cardNumberController = TextEditingController();
        final TextEditingController nameController = TextEditingController();
        final TextEditingController expiryDateController = TextEditingController();
        final TextEditingController validThruController = TextEditingController();
        final TextEditingController upiController = TextEditingController();
        String? selectedBank;

        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            'Enter $type Details',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                if (type != 'UPI')
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.black87,
                    value: selectedBank,
                    items: ['Bank A', 'Bank B', 'Bank C'].map((String bank) {
                      return DropdownMenuItem<String>(
                        value: bank,
                        child: Text(bank, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBank = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Bank',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purpleAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                if (type != 'UPI')
                  SizedBox(height: 10),
                TextField(
                  controller: type == 'UPI' ? upiController : cardNumberController,
                  keyboardType: type == 'UPI' ? TextInputType.emailAddress : TextInputType.number,
                  decoration: InputDecoration(
                    labelText: type == 'UPI' ? 'UPI ID' : '$type Number',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purpleAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                if (type != 'UPI')
                  SizedBox(height: 10),
                if (type != 'UPI')
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name on Card',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purpleAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                if (type != 'UPI')
                  SizedBox(height: 10),
                if (type != 'UPI')
                  TextField(
                    controller: expiryDateController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date (MM/YY)',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purpleAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                if (type != 'UPI')
                  SizedBox(height: 10),
                if (type != 'UPI')
                  TextField(
                    controller: validThruController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Valid Thru (MM/YY)',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purpleAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (type == 'UPI') {
                    _cards.add({'type': type, 'upi': upiController.text});
                  } else {
                    _cards.add({
                      'type': type,
                      'bank': selectedBank ?? '',
                      'number': cardNumberController.text,
                      'name': nameController.text,
                      'expiry': expiryDateController.text,
                      'validThru': validThruController.text,
                    });
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Add $type', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Function to display recent transactions
  Widget _recentTransactions() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Container(
            color: Colors.black,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.black54,
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  child: ListTile(
                    title: Text(
                      _transactions[index]['description']!,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _transactions[index]['date']!,
                      style: TextStyle(color: Colors.white54),
                    ),
                    trailing: Text(
                      _transactions[index]['amount']!,
                      style: TextStyle(
                        color: _transactions[index]['amount']!.startsWith('-')
                            ? Colors.redAccent
                            : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey[900]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      '\$${_balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addMoney,
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text('Add Money', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _sendMoney,
                    icon: Icon(Icons.send, color: Colors.white),
                    label: Text('Send Money', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'Cards and UPI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Column(
                children: _cards.map((card) {
                  return Card(
                    color: Colors.black54,
                    child: ListTile(
                      title: Text(
                        card['type'] == 'UPI' ? card['upi']! : card['number']!,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: card['type'] == 'UPI'
                          ? null
                          : Text(
                              '${card['bank']} - ${card['name']}',
                              style: TextStyle(color: Colors.white54),
                            ),
                      trailing: Icon(
                        card['type'] == 'UPI' ? Icons.qr_code : Icons.credit_card,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _addCardDetails('Credit Card'),
                      icon: Icon(Icons.credit_card, color: Colors.white),
                      label: Text('Add Credit Card', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _addCardDetails('Debit Card'),
                      icon: Icon(Icons.credit_card_outlined, color: Colors.white),
                      label: Text('Add Debit Card', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              ElevatedButton.icon(
                onPressed: () => _addCardDetails('UPI'),
                icon: Icon(Icons.qr_code, color: Colors.white),
                label: Text('Add UPI', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              _recentTransactions(),
            ],
          ),
        ),
      ),
    );
  }
}

