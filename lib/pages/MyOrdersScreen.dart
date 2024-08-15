import 'package:flutter/material.dart';

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
            margin: EdgeInsets.symmetric(vertical: 8.0), // Add margin to each item
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              tileColor: Colors.grey[900],
              textColor: Colors.white,
              leading: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(order['productImage']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              title: Text('Order ID: ${order['orderId']}'),
              subtitle: Text('Status: ${order['status']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order['totalAmount'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Handle view details action
                      _showOrderDetails(context, order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Smaller radius
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // Smaller padding
                      textStyle: TextStyle(
                        fontSize: 14, // Smaller text size
                      ),
                    ),
                    child: Text('View Details'),
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

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    // Display order details
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Order Details',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order ID: ${order['orderId']}', style: TextStyle(color: Colors.white)),
              Text('Total Amount: \$${order['totalAmount'].toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
              Text('Status: ${order['status']}', style: TextStyle(color: Colors.white)),
              SizedBox(height: 10),
              Image.network(
                order['productImage'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
