import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';

class HasilValidasiPage extends StatefulWidget {
  final int user_id;
  final int sub_materi_id;

  const HasilValidasiPage({
    super.key,
    required this.user_id,
    required this.sub_materi_id,
  });

  @override
  _HasilValidasiPageState createState() => _HasilValidasiPageState();
}

class _HasilValidasiPageState extends State<HasilValidasiPage> {
  bool isLoading = true;
  List<dynamic> progressData = [];
  int totalNilai = 0;
  String status = "";

  @override
  void initState() {
    super.initState();
    fetchProgressData();
  }

  Future<void> fetchProgressData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('${BaseUrl.baseUrl}/progress/latihan/${widget.user_id}/${widget.sub_materi_id}'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    setState(() {
      progressData = data['data'];  // Ambil data progress list dari respons
      totalNilai = (data['data'][0]['total_nilai'] ?? 0.0).toInt();  // Ensure it's an int
      status = totalNilai >= 70 ? "Selesai" : "Gagal";
      isLoading = false;
    });
  } else {
    setState(() {
      isLoading = false;
    });
    // Handle error here
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Gagal memuat data validasi'),
    ));
  }
}

  @override
  Widget build(BuildContext context) {
    // Determine the status icon based on total_nilai
    Icon statusIcon = totalNilai >= 70
        ? const Icon(Icons.check_circle, color: Colors.green, size: 40)
        : const Icon(Icons.cancel, color: Colors.red, size: 40);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Card(
          elevation: 4,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: EdgeInsets.zero,
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: secondPrimaryColor,
            title: const Text(
              'Hasil Validasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Icon and Total Nilai
                    Row(
                      children: [
                        statusIcon,
                        const SizedBox(width: 10),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: totalNilai >= 70 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Total Nilai: ${totalNilai.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    // Displaying progress data
                    ...progressData.map((progress) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card displaying Potongan Ayat and Latin Text
                              Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      progress['potongan_ayat'] ?? 'Tidak ada data',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.translate,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      progress['latin_text'] ?? 'Tidak ada data',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 10),
                              Text(
                                'pelafalan: ${progress['status_validasi'] ?? 'Tidak ada data'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'nilai: ${progress['nilai'] ?? 'Tidak ada data'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 10),
                              Text(
                                'keterangan: ${progress['feedback_pengajar'] ?? 'Tidak ada data'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    // Adding "Selesai" button at the bottom
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              context.go('/navigasiPengajar'); 

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondPrimaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0), // Rounded corners
                              ),
                            ).copyWith(
                              splashFactory: InkRipple.splashFactory,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "selesai",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
    );
  }
}
