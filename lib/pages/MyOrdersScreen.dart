import 'package:flutter/material.dart';
import 'order_details_screen.dart';  // Import the new screen

class MyOrdersScreen extends StatelessWidget {
  // Sample data for orders with product image URLs
  final List<Map<String, dynamic>> orders = [
    {
      'orderId': '001',
      'totalAmount': 50.0,
      'status': 'Completed',
      'productImage': 'https://via.placeholder.com/100' // Placeholder image
    },
    {
      'orderId': '002',
      'totalAmount': 30.0,
      'status': 'Pending',
      'productImage': 'https://via.placeholder.com/100'
    },
    {
      'orderId': '003',
      'totalAmount': 75.0,
      'status': 'Shipped',
      'productImage': 'https://via.placeholder.com/100'
    },
    {
      'orderId': '004',
      'totalAmount': 120.0,
      'status': 'Delivered',
      'productImage': 'https://via.placeholder.com/100'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: const Color.fromARGB(255, 250, 248, 248),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 12.0), // Increased margin for more spacing
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // Increased padding
              tileColor: Colors.grey[900],
              textColor: Colors.white,
              leading: Container(
                width: 100, // Increased image width
                height: 100, // Increased image height
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(order['productImage']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12.0), // Larger border radius for a rounder look
                ),
              ),
              title: Text(
                'Order ID: ${order['orderId']}',
                style: TextStyle(fontSize: 18), // Increased title font size
              ),
              subtitle: Text(
                'Status: ${order['status']}',
                style: TextStyle(fontSize: 16), // Increased subtitle font size
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order['totalAmount'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20, // Increased text size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the OrderDetailsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(order: order, orderStatus: [],),
                        ),
                      );
                    },
                    child: Text(
                      'Details',
                      style: TextStyle(
                        color: Colors.blueAccent, // Text color
                        fontSize: 10, // Text size
                        decoration: TextDecoration.underline, // Underline to indicate a link
                      ),
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white24, width: 1),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }
}
