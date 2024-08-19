import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

// Define the ProductPage widget
class ProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String selectedSize = 'M';
  String selectedColor = 'Red';
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool addressSaved = false; // Simulates whether an address is saved

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Ensure availability is a boolean and not null
    final bool isAvailable = product['availability'] ?? true;

    Widget getProductImage() {
      if (product['image'] is List) {
        return Image.memory(
          Uint8List.fromList((product['image'] as List).cast<int>()),
          width: 400,
          height: 400,
        );
      } else if (product['image'] is String) {
        return Image.network(
          product['image'],
          width: 400,
          height: 400,
        );
      } else {
        return const Icon(
          Icons.image,
          size: 200,
          color: Colors.grey,
        );
      }
    }

    Widget buildColorBox(String color, Color displayColor) {
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedColor = color;
          });
        },
        child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: displayColor,
            border: Border.all(
              color: selectedColor == color ? Colors.black : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color.fromARGB(255, 8, 0, 0), // Metallic black background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: getProductImage(),
            ),
            const SizedBox(height: 16.0),
            Text(
              product['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8.0),
            Text('\$${product['price']}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16.0),
            Text(
              'Category: ${product['category']}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Description: ${product['description'] ?? 'No description available'}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Fabric: Cotton Biowash',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Fabric Weight: 240gsm',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Print Type: DTF Premium',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Availability: ${isAvailable ? 'In Stock' : 'Out of Stock'}',
              style: TextStyle(
                fontSize: 16,
                color: isAvailable ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Size:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            DropdownButton<String>(
              dropdownColor: Colors.grey[850],
              value: selectedSize,
              onChanged: (String? newSize) {
                setState(() {
                  selectedSize = newSize!;
                });
              },
              items: <String>['S', 'M', 'L', 'XL'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: pincodeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Enter Pincode',
                labelStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: isAvailable
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderSummaryPage(
                              product: widget.product,
                              selectedSize: selectedSize,
                              selectedColor: selectedColor,
                              pincode: pincodeController.text,
                              address: 'Sample Address', // Set a default or handle as needed
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Continue to Checkout', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSummaryPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final String selectedSize;
  final String selectedColor;
  final String pincode;
  final String address;

  const OrderSummaryPage({
    Key? key,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    required this.pincode,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color.fromARGB(255, 8, 0, 0), // Metallic black background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[700],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text('Product: ${product['name']}', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8.0),
                  Text('Price: \$${product['price']}', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(child: Text('Size: $selectedSize', style: const TextStyle(color: Colors.white))),
                      const SizedBox(width: 16.0),
                      Expanded(child: Text('Color: $selectedColor', style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[700],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text('Pincode: $pincode', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8.0),
                  Text('Address: $address', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[700],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price', style: TextStyle(color: Colors.white)),
                      Text('\$${product['price']}', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Charges', style: TextStyle(color: Colors.white)),
                      const Text('Free', style: TextStyle(color: Colors.greenAccent)),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('\$${product['price']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order Confirmed')),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Confirm Order', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}