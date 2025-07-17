import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';

class ValidasiPelafalan extends StatefulWidget {
  const ValidasiPelafalan({super.key});

  @override
  _ValidasiPelafalanState createState() => _ValidasiPelafalanState();
}

class _ValidasiPelafalanState extends State<ValidasiPelafalan> {
  List<dynamic> santriList = [];
  List<dynamic> filteredSantriList = [];
  String searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProgressMenunggu();
  }

  Future<void> fetchProgressMenunggu() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/progress/menunggu'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        santriList = data['data'];
        filteredSantriList = santriList;
        isLoading = false;
      });
    } else {
      print("Gagal memuat data: ${response.statusCode}");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSantri(String query) {
    setState(() {
      filteredSantriList =
          santriList
              .where(
                (santri) => santri['nama_lengkap'].toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penilaian'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  filterSantri(query);
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari Santri...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: secondPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pilih Santri',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: secondPrimaryColor,
                ),
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredSantriList.isEmpty
                      ? const Center(child: Text('Data tidak ditemukan'))
                      : CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              var santri = filteredSantriList[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 5.0,
                                                ),
                                            leading: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                    'assets/icon/defaultprofile.jpeg',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            title: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    santri['nama_lengkap'] ??
                                                        '',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  santri['title'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  santri['subtitle'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              final idUser = santri['user_id'];
                                              final subMateriId =
                                                  santri['sub_materi_id'];
                                              print(
                                                "user_id: ${santri['user_id']}",
                                              );
                                              print(
                                                "sub_materi_id: ${santri['sub_materi_id']}",
                                              );

                                              if (idUser != null &&
                                                  subMateriId != null) {
                                                context.push(
                                                  '/detail_validasi',
                                                  extra: {
                                                    'user_id': idUser,
                                                    'sub_materi_id':
                                                        subMateriId,
                                                  },
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Data tidak lengkap untuk validasi",
                                                    ),
                                                  ),
                                                );
                                              }
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
                            }, childCount: filteredSantriList.length),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
