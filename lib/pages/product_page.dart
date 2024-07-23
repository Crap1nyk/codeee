import 'package:flutter/material.dart';
import 'dart:typed_data';

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

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Ensure availability is a boolean and not null
    final bool isAvailable = product['availability'] ?? false;

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
      backgroundColor: Color.fromARGB(255, 8, 0, 0), // Metallic black background
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
                  child: Text(value, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            // Text(
            //   'Color:',
            //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            // ),
            // Row(
            //   children: [
            //     buildColorBox('Red', Colors.red),
            //     buildColorBox('Black', Colors.black),
            //     buildColorBox('Blue', Colors.blue),
            //     buildColorBox('Yellow', Colors.yellow),
            //     buildColorBox('White', Colors.white),
            //   ],
            // ),
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
                        // Add to cart functionality here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}