import 'package:flutter/material.dart';

class DetailDataLatihanPage extends StatefulWidget {
  final int id;
  const DetailDataLatihanPage({super.key,required this.id});

  @override
  _DetailDataLatihanPageState createState() => _DetailDataLatihanPageState();
}

class _DetailDataLatihanPageState extends State<DetailDataLatihanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Data Latihan'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          'Halaman Detail Data Latihan',
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
