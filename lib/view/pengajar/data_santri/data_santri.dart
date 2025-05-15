import 'package:flutter/material.dart';

class DataSantriPage extends StatelessWidget {
  const DataSantriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Santri'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'data santri',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
