import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';

class DataLatihanPage extends StatefulWidget {
  const DataLatihanPage({super.key});

  @override
  _DataLatihanPageState createState() => _DataLatihanPageState();
}

class _DataLatihanPageState extends State<DataLatihanPage> {
  int _selectedIndex = 0; // To track the selected tab
  late Future<List<dynamic>> kategoriData;
  bool isLoading = true; 
  List<dynamic> materiList = [];

  // Define the content for each "tab"
  final List<Widget> _contentWidgets = [
    Center(child: Text('Konten Materi 1')),
    Center(child: Text('Konten Materi 2')),
  ];

  // Function to fetch materi data when a tab is selected
  Future<void> _fetchMateri() async {
    final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/materi'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        materiList = data['data'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load materi');
    }
  }

  // Function to fetch kategori data based on the selected materi (id_materi)
  Future<List<dynamic>> fetchKategoriData(int id_materi) async {
    final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/kategori/$id_materi'));

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;  
      });
      return json.decode(response.body)['data']; // Fetch categories based on id_materi
    } else {
      throw Exception('Failed to load kategori');
    }
  }

  // Function to fetch sub-materi data based on selected kategori
  Future<List<dynamic>> fetchSubMateriData(int id_kategori) async {
    final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/sub_materi/$id_kategori'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['data']['sub_materi'];
    } else {
      throw Exception('Failed to load sub-materi');
    }
  }

  // Tab selection callback to update the selected index and fetch relevant kategori data
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
      int idMateri = index == 0 ? 1 : 2; // 1 for "Makhrijul Huruf" and 2 for "Materi 2"
      kategoriData = fetchKategoriData(idMateri); // Fetch kategori based on id_materi
    });
  }

  @override
  void initState() {
    super.initState();
    kategoriData = fetchKategoriData(1); // Default to "Makhrijul Huruf"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Latihan'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Button Bar with full width buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Materi 1 Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _onTabTapped(0);
                    },
                    label: const Text(
                      'Makhrijul Huruf',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: secondPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Materi 2 Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _onTabTapped(1);
                    },
                    label: const Text(
                      'Sifatul Huruf',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: secondPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            // FutureBuilder to fetch and display categories based on selected tab
            Expanded(
              child: FutureBuilder<List<dynamic>>(
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

                      // Iterate through categories and fetch corresponding sub-materi
                      for (var kategori in kategoriList)
                        FutureBuilder<List<dynamic>>(
                          future: fetchSubMateriData(kategori['id']),
                          builder: (context, subMateriSnapshot) {
                            if (subMateriSnapshot.connectionState == ConnectionState.waiting) {
                              return SliverToBoxAdapter(child: SizedBox());
                            } else if (subMateriSnapshot.hasError) {
                              return SliverToBoxAdapter(child: Center(child: Text('Error: ${subMateriSnapshot.error}')));
                            } else if (!subMateriSnapshot.hasData || subMateriSnapshot.data == null) {
                              return SliverToBoxAdapter(child: Center(child: Text('No sub-materi available')));
                            }

                            final subMateriList = subMateriSnapshot.data!;

                            return SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
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
                                              '/detail_data_latihan', 
                                              extra: {
                                                'id': submateri['id'],
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
            ),
          ],
        ),
      ),
    );
  }
}
