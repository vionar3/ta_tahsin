import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/theme.dart';

class DetailKemajuanPage extends StatelessWidget {
  const DetailKemajuanPage({super.key, required this.nama});

final String nama;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kemajuan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),color: blackColor,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/navigasiPengajar');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Profil Pengguna
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/icon/defaultprofile.jpeg'), // Ganti dengan gambar profil
              ),
            ),
            const SizedBox(height: 16),
            // Nama Pengguna
            Center(
              child: Text(
                nama,  // Ganti dengan nama pengguna
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Judul Progres Belajar
            Text(
              'Progres Belajar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 20),
            // Progress Bar untuk materi
            ProgressBar(title: 'Jumlah Materi 1 Selesai', progress: 0.6), // Progress 60%
            const SizedBox(height: 20),
            ProgressBar(title: 'Jumlah Materi 2 Selesai', progress: 0.4), // Progress 40%
          ],
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final String title;
  final double progress;

  const ProgressBar({super.key, required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: blackColor,
          ),
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: secondPrimaryColor, // Ganti dengan warna yang sesuai
          minHeight: 20,
        ),
      ],
    );
  }
}
