import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/theme.dart';

class HasilQuizPage extends StatelessWidget {
  final int totalScore;
  final String title;

  // Konstruktor untuk menerima nilai dari halaman sebelumnya
  HasilQuizPage({super.key, required this.totalScore, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50), 
        child: Card(
          elevation: 4, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, 
          ),
          margin: EdgeInsets.zero, 
          child: AppBar(
            backgroundColor: secondPrimaryColor, 
            title: Text(
              "Hasil Quiz",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header pesan selamat
            Text(
              'Selamat anda berhasil menyelesaikan latihan soal\n$title!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),

            // Menampilkan skor
            Text(
              'Point kamu:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '$totalScore',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: secondPrimaryColor,
              ),
            ),
            SizedBox(height: 30),

            // Tombol kembali
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondPrimaryColor, // Warna tombol
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.go('/navigasi');
              },
              child: Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
