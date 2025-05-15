import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'model/model_data_materi.dart'; // Impor model data materi

class MateriPage extends StatelessWidget {
  final String title;
  final String description;
  final List<dynamic> subMateri;

  const MateriPage({
    super.key,
    required this.title,
    required this.description,
    required this.subMateri,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondPrimaryColor,
        title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: whiteColor,
                        ),
                      ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),color: whiteColor,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // Teks Title dan Description yang akan ikut scroll
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // SliverList untuk subMateri
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final kategori = subMateri[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Padding untuk subMateri
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header kategori
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          kategori['category'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      for (var sub in kategori['subMateri'])
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 0), // Mengurangi jarak antar subMateri
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal:
                                        12.0), // Mengatur padding agar lebih rapat
                                leading: Container(
                                  width: 60, // Lebar kotak
                                  height: 60, // Tinggi kotak
                                  decoration: BoxDecoration(
                                    color:
                                        secondPrimaryColor, // Latar belakang kotak
                                    borderRadius: BorderRadius.circular(
                                        12), // Memberikan radius pada sudut
                                  ),
                                  child: Icon(
                                    Icons.menu_book,
                                    color: whiteColor,
                                    size: 24, // Ukuran ikon
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        sub['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  sub['subtitle'],
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                onTap: () {
                                  context.push(
                                    '/submateri', // Gantilah dengan rute yang sesuai
                                    extra: {
                                      'title': sub['title'],
                                      'description': sub['subtitle'],
                                      'videoLink': sub[
                                          'videoLink'], // Link video untuk diputar
                                      'intro': sub['intro'], // Materi pengantar
                                    },
                                  );
                                },
                              ),
                              Divider(
                                color: Colors.grey.withOpacity(0.5),
                                thickness: 1,
                                indent: 80,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
              childCount: subMateri.length,
            ),
          ),
        ],
      ),
    );
  }
}
