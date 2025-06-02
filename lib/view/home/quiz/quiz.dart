import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> materiList = [];
  bool isLoading = true;
  String? authToken;

  // Variabel untuk menyimpan hasil score dan status per materi
  Map<int, Map<String, dynamic>> quizResults = {};

  @override
  void initState() {
    super.initState();
    _getAuthToken();
    _fetchMateri(); // Fetch materi saat halaman dimuat
  }

  // Mengambil token auth dari shared_preferences
  Future<void> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    if (authToken != null) {
      setState(() {
        this.authToken = authToken; // Menyimpan token
      });
    } else {
      print("No auth token found");
    }
  }

  // Fungsi untuk mengambil data materi
  Future<void> _fetchMateri() async {
    final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/materi'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        materiList = data['data'];
        isLoading = false;
      });

      // Ambil hasil quiz untuk setiap materi yang ada
      for (var materi in materiList) {
        _fetchQuizResult(materi['id']);
      }
    } else {
      throw Exception('Failed to load materi');
    }
  }

  // Fungsi untuk mengambil hasil quiz dari API
  Future<void> _fetchQuizResult(int id_materi) async {
    if (authToken == null) {
      print("No auth token found");
      return;
    }

    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/quizresult/$id_materi'),
      headers: {
        'Authorization': 'Bearer $authToken', // Gunakan token autentikasi yang valid
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        quizResults[id_materi] = {
          'total_score': data['data']['total_score'] ?? 0,
          'status': data['data']['status'] ?? 'Belum Selesai',
        };
      });
    } else {
      print('Failed to fetch quiz result');
      // Menampilkan nilai default jika gagal
      setState(() {
        quizResults[id_materi] = {
          'total_score': 0,
          'status': 'Belum Selesai',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Display the materi list with score and status
                      for (var materi in materiList)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: () {
                              // Ambil hasil quiz untuk materi yang dipilih

                              context.go('/detail_quiz', extra: {
                                'id': materi['id'],
                                'title': materi['title'],
                              });
                            },
                          child: Center(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5, // Add shadow for depth
                              child: Container(
                                width: 350,  // Slightly narrower for a more compact feel
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [secondPrimaryColor, Colors.blue],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        materi['title'],
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: whiteColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        materi['subtitle'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: whiteColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 16),
                                      // Add score and quiz status inside each card
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Skor:",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: whiteColor,
                                                ),
                                              ),
                                              Text(
                                                "${quizResults[materi['id']]?['total_score'] ?? 0}",  // Menampilkan score sesuai materi
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.greenAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Status:",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: whiteColor,
                                                ),
                                              ),
                                              Text(
                                                "${quizResults[materi['id']]?['status'] ?? 'Belum Selesai'}",  // Menampilkan status sesuai materi
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: (quizResults[materi['id']]?['status'] == "Selesai")
                                                      ? Colors.greenAccent
                                                      : Colors.orangeAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
