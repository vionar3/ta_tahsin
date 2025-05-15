import 'package:flutter/material.dart';

class KemajuanPage extends StatelessWidget {
  const KemajuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kemajuan'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Kemajuan Pembelajaran Anda',
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
