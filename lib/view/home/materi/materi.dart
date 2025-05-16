import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';

class MateriPage extends StatefulWidget {
  final int id;
  final String title;
  final String description;

  const MateriPage({
    super.key,
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  _MateriPageState createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  late Future<List<dynamic>> kategoriData;
  bool isLoading = true; // Variabel untuk mengatur status loading

  @override
  void initState() {
    super.initState();
    kategoriData = fetchKategoriData(widget.id); // Ambil kategori berdasarkan id materi
  }

  // Fungsi untuk mengambil kategori berdasarkan id_materi
  Future<List<dynamic>> fetchKategoriData(int id_materi) async {
    final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/kategori/$id_materi'));

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;  // Set isLoading ke false setelah data kategori berhasil diambil
      });
      return json.decode(response.body)['data']; // Parse JSON response ke List kategori
    } else {
      throw Exception('Failed to load kategori');
    }
  }

  // Fungsi untuk mengambil sub-materi berdasarkan id_kategori
  Future<List<dynamic>> fetchSubMateriData(int id_kategori) async {
    final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/sub_materi/$id_kategori'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['data']['sub_materi']; // Parse JSON response ke List sub-materi
    } else {
      throw Exception('Failed to load sub-materi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondPrimaryColor,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), color: whiteColor,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/navigasi');
            }
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Tampilkan loading spinner selama proses loading
          : FutureBuilder<List<dynamic>>(
              future: kategoriData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Tampilkan loading saat menunggu
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}')); // Tampilkan error jika ada masalah
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('Tidak ada data tersedia')); // Tampilkan jika data kosong
                }

                final kategoriList = snapshot.data!;

                return CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.description,
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
                    // SliverList untuk kategori dan sub-materi
                    for (var kategori in kategoriList)
                      FutureBuilder<List<dynamic>>(
                        future: fetchSubMateriData(kategori['id']), // Ambil submateri untuk kategori ini
                        builder: (context, subMateriSnapshot) {
                          if (subMateriSnapshot.connectionState == ConnectionState.waiting) {
                            return SliverToBoxAdapter(child: SizedBox()); // Tidak ada loading spinner lagi
                          } else if (subMateriSnapshot.hasError) {
                            return SliverToBoxAdapter(child: Center(child: Text('Error: ${subMateriSnapshot.error}')));
                          } else if (!subMateriSnapshot.hasData || subMateriSnapshot.data == null) {
                            return SliverToBoxAdapter(child: Center(child: Text('No sub-materi available')));
                          }

                          final subMateriList = subMateriSnapshot.data!;

                          return SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                // Menampilkan nama kategori sekali
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                                  child: Text(
                                    kategori['nama_kategori'], // Menampilkan nama kategori
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                // Menampilkan sub-materi yang terkait dengan kategori ini
                                for (var submateri in subMateriList)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                          leading: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: secondPrimaryColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.menu_book,
                                              color: whiteColor,
                                              size: 24,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  submateri['title'],
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
                                            submateri['subtitle'],
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                          onTap: () {
                                            context.push(
                                              '/submateri', // Gantilah dengan rute yang sesuai
                                              extra: {
                                                'title': submateri['title'],
                                                'description': submateri['subtitle'],
                                                'videoLink': submateri['video_url'],
                                                'intro': submateri['intro'],
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
                      ),
                  ],
                );
              },
            ),
    );
  }
}
