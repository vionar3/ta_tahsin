import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    kategoriData = fetchKategoriData(widget.id);
  }

  Future<List<dynamic>> fetchKategoriData(int id_materi) async {
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/kategori/$id_materi'),
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load kategori');
    }
  }

  Future<List<dynamic>> fetchSubMateriData(int id_kategori) async {
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/sub_materi/$id_kategori'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data']['sub_materi'];
    } else {
      throw Exception('Failed to load sub-materi');
    }
  }

  Future<String> fetchProgressBySubMateri(int id_submateri) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    debugPrint("Token yang diambil: $authToken");

    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/progress/$id_submateri/status'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status']; // Pastikan status yang diterima adalah string
    } else {
      throw Exception('Failed to load progress');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: EdgeInsets.zero,
          child: AppBar(
            backgroundColor: secondPrimaryColor,
            title: Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                context.go('/navigasi');
              },
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : FutureBuilder<List<dynamic>>(
                future: kategoriData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('Tidak ada data tersedia'));
                  }

                  final kategoriList = snapshot.data!;

                  return CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate([
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
                        ]),
                      ),

                      for (var kategori in kategoriList)
                        FutureBuilder<List<dynamic>>(
                          future: fetchSubMateriData(kategori['id']),
                          builder: (context, subMateriSnapshot) {
                            if (subMateriSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SliverToBoxAdapter(child: SizedBox());
                            } else if (subMateriSnapshot.hasError) {
                              return SliverToBoxAdapter(
                                child: Center(
                                  child: Text(
                                    'Error: ${subMateriSnapshot.error}',
                                  ),
                                ),
                              );
                            } else if (!subMateriSnapshot.hasData ||
                                subMateriSnapshot.data == null) {
                              return SliverToBoxAdapter(
                                child: Center(
                                  child: Text('No sub-materi available'),
                                ),
                              );
                            }

                            final subMateriList = subMateriSnapshot.data!;

                            return SliverList(
                              delegate: SliverChildListDelegate([
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 5.0,
                                  ),
                                  child: Text(
                                    kategori['nama_kategori'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                for (var submateri in subMateriList)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 12.0,
                                              ),
                                          leading: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: secondPrimaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                              FutureBuilder<String>(
                                                future:
                                                    fetchProgressBySubMateri(
                                                      submateri['id'],
                                                    ),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator();
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Icon(
                                                      Icons.error,
                                                      color: Colors.red,
                                                    );
                                                  } else if (snapshot.hasData) {
                                                    final status =
                                                        snapshot.data;
                                                    debugPrint(
                                                      "Status: $status",
                                                    );

                                                    // return Row(
                                                    //   mainAxisSize:
                                                    //       MainAxisSize.min,
                                                    //   children: [
                                                    //     if (status == 'selesai')
                                                    //       Icon(
                                                    //         Icons
                                                    //             .check_circle_outline,
                                                    //         color: Colors.green,
                                                    //         size: 29,
                                                    //       ),
                                                    //     if (status ==
                                                    //         'menunggu')
                                                    //       Icon(
                                                    //         Icons.pending,
                                                    //         color:
                                                    //             Colors.orange,
                                                    //         size: 29,
                                                    //       ),
                                                    //     if (status == 'gagal')
                                                    //       Icon(
                                                    //         Icons
                                                    //             .cancel_outlined,
                                                    //         color: Colors.red,
                                                    //         size: 29,
                                                    //       ),
                                                    //   ],
                                                    // );
                                                    return Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        if (status == 'selesai')
                                                          Icon(
                                                            Icons
                                                                .check_circle_outline,
                                                            color: Colors.green,
                                                            size: 29,
                                                          ),
                                                        if (status ==
                                                            'menunggu')
                                                          Icon(
                                                            Icons.pending,
                                                            color:
                                                                Colors.orange,
                                                            size: 29,
                                                          ),
                                                        if (status == 'gagal')
                                                          Icon(
                                                            Icons
                                                                .cancel_outlined,
                                                            color: Colors.red,
                                                            size: 29,
                                                          ),
                                                        // Add "Detail" button for selesai or gagal status
                                                        if (status ==
                                                                'selesai' ||
                                                            status == 'gagal')
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  left: 10,
                                                                ),
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                context.push(
                                              '/penilaian',
                                              extra: {
                                                'sub_materi_id': submateri['id'],
                                              },
                                            );
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                backgroundColor: secondPrimaryColor,
                                                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8), // Set text color to white
                                                              ),
                                                              child: Text(
                                                                'Hasil',
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  }

                                                  return SizedBox(); // No icon if status is not 'selesai', 'menunggu', or 'gagal'
                                                },
                                              ),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                submateri['subtitle'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              FutureBuilder<String>(
                                                future:
                                                    fetchProgressBySubMateri(
                                                      submateri['id'],
                                                    ),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return SizedBox();
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return SizedBox();
                                                  } else if (snapshot.hasData) {
                                                    final status =
                                                        snapshot.data;
                                                    String keterangan = '';
                                                    if (status == 'selesai') {
                                                      keterangan =
                                                          'Telah menyelesaikan latihan';
                                                    } else if (status ==
                                                        'menunggu') {
                                                      keterangan =
                                                          'Menunggu dikoreksi oleh guru';
                                                    } else if (status ==
                                                        'belum selesai') {
                                                      keterangan =
                                                          'Belum dikerjakan';
                                                    } else if (status ==
                                                        'gagal') {
                                                      keterangan =
                                                          'Silahkan diperbaiki';
                                                    }

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 8.0,
                                                          ),
                                                      child: Text(
                                                        keterangan,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              status ==
                                                                      'selesai'
                                                                  ? Colors.green
                                                                  : (status ==
                                                                          'menunggu'
                                                                      ? Colors
                                                                          .orange
                                                                      : (status ==
                                                                              'gagal'
                                                                          ? Colors
                                                                              .red
                                                                          : secondPrimaryColor)),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  return SizedBox(); // Default return if there's no data
                                                },
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            context.push(
                                              '/submateri',
                                              extra: {
                                                'id': submateri['id'],
                                                'title': submateri['title'],
                                                'description':
                                                    submateri['subtitle'],
                                                'videoLink':
                                                    submateri['video_url'],
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
                              ]),
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
