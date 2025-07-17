import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';

class ProgressBar extends StatelessWidget {

  final double progress;

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 5),
        Stack(
          alignment: Alignment.center,
          children: [
            // Linear Progress Bar with rounded corners
            SizedBox(
              height: 20, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), 
                child: LinearProgressIndicator(
                  value: progress, 
                  backgroundColor: Colors.grey[300], 
                  color: secondPrimaryColor,  
                  minHeight: 5,  
                ),
              ),
            ),
            // Percentage text overlaying the progress bar
            Positioned(
              child: Text(
                '${(progress * 100).toStringAsFixed(1)}%',  
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class KemajuanPage extends StatefulWidget {
  const KemajuanPage({super.key});

  @override
  State<KemajuanPage> createState() => _KemajuanPageState();
}

class _KemajuanPageState extends State<KemajuanPage> {
  List<dynamic> kemajuanList = []; // Menyimpan list kemajuan
  List<dynamic> filteredKemajuanList = []; // Menyimpan list hasil filter
  bool isLoading = true; // Menandakan apakah data sedang dimuat
  String searchQuery = ""; // Menyimpan query pencarian

  // Menyimpan status progres yang sudah dimuat
  Set<int> loadedUserIds = Set();

  // Fungsi untuk mengambil data kemajuan
  Future<void> fetchKemajuanData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  try {
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/users/progres'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data['data'] == null || (data['data'] as List).isEmpty) {
        // If no data found, show a warning message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tidak ada santri yang menyelesaikan latihan.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange, // Set the background color for warning
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              ),
            ),
          ),
        );
      } else {
        setState(() {
          kemajuanList = data['data']; // Menyimpan data kemajuan
          filteredKemajuanList = kemajuanList;
          isLoading = false;
        });

        // Setelah data kemajuan berhasil dimuat, panggil fetchProgressData untuk setiap user yang belum dimuat
        for (var kemajuan in kemajuanList) {
          if (!loadedUserIds.contains(kemajuan['user_id'])) {
            fetchProgressData(kemajuan['user_id']);
            loadedUserIds.add(kemajuan['user_id']); // Tandai user_id yang sudah dimuat
          }
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gagal memuat data kemajuan: ${response.body}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red, // Set the background color for error
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
        ),
      );
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Error occurred: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Terjadi kesalahan saat mengambil data: $e',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red, // Set the background color for error
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
      ),
    );
  }
}



  // Fungsi untuk mengambil data progres berdasarkan userId
  Future<void> fetchProgressData(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    debugPrint("Token yang diambil: $authToken");

    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/progres/$userId'), // API URL yang sesuai
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Menyimpan progress untuk setiap user
        final index = kemajuanList.indexWhere((item) => item['user_id'] == userId);
        if (index != -1) {
          kemajuanList[index]['progress_percentage'] = data['progress_percentage']; // Menambahkan progres
        }
      });
    } else {
      print('Failed to load progress data');
    }
  }

  // Fungsi untuk memfilter data berdasarkan nama
  void filterKemajuan(String query) {
    final filtered = kemajuanList.where((kemajuan) {
      final nama = kemajuan['nama_lengkap'].toLowerCase();
      final search = query.toLowerCase();
      return nama.contains(search); // Pencarian berdasarkan nama lengkap
    }).toList();

    setState(() {
      filteredKemajuanList = filtered; // Update list yang ditampilkan
    });
  }

  @override
  void initState() {
    super.initState();
    fetchKemajuanData(); // Memanggil fungsi saat halaman pertama kali dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kemajuan'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  filterKemajuan(searchQuery);
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari Santri...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: secondPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Judul Pilih Santri
            Text(
              'Pilih Santri',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: secondPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),

            // Jika loading, tampilkan loading indicator
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (filteredKemajuanList.isEmpty)
              Center(child: Text('Tidak ada progres latihan yang ditemukan.'))
            else
              // Menggunakan SliverList dengan kemajuanList yang sudah difilter
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var kemajuan = filteredKemajuanList[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
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
                                                kemajuan['nama_lengkap'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              kemajuan['no_telp_wali'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            // Menggunakan widget ProgressBar
                                            ProgressBar(
                                              progress: kemajuan['progress_percentage'] != null
                                                  ? kemajuan['progress_percentage'] / 100
                                                  : 0.0,
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          context.go('/detail_kemajuan', extra: {
                                            'nama': kemajuan['nama_lengkap'],
                                            'user_id': kemajuan['user_id'],
                                          });
                                        },
                                      ),
                                      Divider(
                                        color: Colors.grey.withOpacity(0.5),
                                        thickness: 1,
                                        indent: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: filteredKemajuanList.length,
                      ),
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
