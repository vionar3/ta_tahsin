import 'dart:convert'; // Untuk JSON parsing
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Untuk HTTP request
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';  // Pastikan Anda mengimpor theme.dart
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class DetailQuizPage extends StatefulWidget {
  final int id; // Menambahkan materiId yang dipilih
  final String title; // Menambahkan materiId yang dipilih
  DetailQuizPage({super.key, required this.id, required this.title});

  @override
  _DetailQuizPageState createState() => _DetailQuizPageState();
}

class _DetailQuizPageState extends State<DetailQuizPage> {
  Map<int, int> selectedAnswers = {}; // Menyimpan jawaban per soal
  List<dynamic> quizList = []; // Menyimpan data soal yang diambil dari API
  bool isLoading = true; // Untuk menandakan status loading data
  String? authToken;  // Variabel authToken yang akan diambil dari shared_preferences

  @override
  void initState() {
    super.initState();
    _getAuthToken(); // Ambil authToken ketika halaman pertama kali dibuka
    fetchQuizData(); // Mengambil data soal ketika halaman pertama kali dibuka
  }

  Future<void> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Mengambil token yang disimpan
    String? authToken = prefs.getString('token');

    if (authToken != null) {
      setState(() {
        this.authToken = authToken;  // Menyimpan token ke variabel authToken
      });
    } else {
      print("No auth token found");
    }
  }

  // Fungsi untuk mengambil data soal dari API
  Future<void> fetchQuizData() async {
    final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/quiz/${widget.id}'));

    if (response.statusCode == 200) {
      setState(() {
        quizList = json.decode(response.body)['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error jika API gagal
      print('Failed to load quiz data');
    }
  }

 Future<void> submitQuizAnswers() async {
  if (authToken == null) {
    print("No auth token found");
    return;
  }

  List<Map<String, dynamic>> answers = [];

  selectedAnswers.forEach((questionIndex, optionIndex) {
    var questionData = quizList[questionIndex];
    var selectedOption = ['a', 'b', 'c', 'd'][optionIndex]; // Menyusun option berdasarkan index
    answers.add({
      'question_id': questionData['id'],
      'selected_option': selectedOption,
    });
  });

  final response = await http.post(
    Uri.parse('${BaseUrl.baseUrl}/quiz/${widget.id}/check'),
    headers: {
      'Authorization': 'Bearer $authToken', 
      'Content-Type': 'application/json',
    },
    body: json.encode({'answers': answers}),
  );

  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    int totalScore = data['data']['total_score'];
    int correctAnswers = data['data']['correct_answers'];

    // Tampilkan dialog hasil quiz
    showResultDialog(totalScore, correctAnswers);
  } else {
    print('Failed to submit answers');
    // Tampilkan pesan error jika gagal
  }
}


 void showResultDialog(int totalScore, int correctAnswers) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Membuat sudut lebih melengkung
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              "Konfirmasi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Apakah Anda yakin dengan jawaban Anda?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        actions: <Widget>[
          // Tombol Batal
          TextButton(
            child: Text(
              "Batal",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog dan kembali
            },
          ),
          // Tombol OK
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondPrimaryColor, // Warna tombol OK
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              "OK",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            onPressed: () {
              // Navigasi ke halaman hasil_quiz dengan data tambahan
              Navigator.of(context).pop(); // Tutup dialog terlebih dahulu
              context.go('/hasil_quiz', extra: {
                'totalScore': totalScore,
                'title': widget.title,
              });
            },
          ),
        ],
      );
    },
  );
}



  // Fungsi untuk mengecek apakah semua soal sudah dijawab
  bool canFinishQuiz() {
    return selectedAnswers.length == quizList.length;
  }

  // Membuat tampilan tombol pilihan jawaban
  Widget _buildOption(String optionText, int questionIndex, int optionIndex) {
    bool isSelected = selectedAnswers[questionIndex] == optionIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedAnswers[questionIndex] = optionIndex; // Menyimpan pilihan yang dipilih untuk soal tertentu
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? secondPrimaryColor : Colors.grey[300], // Mengubah warna tombol saat dipilih
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: isSelected ? 5 : 2, // Efek bayangan yang lebih halus
          shadowColor: isSelected ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
          minimumSize: Size(double.infinity, 50), // Tombol mengisi lebar layar
        ),
        child: Text(
          optionText,
          style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              "Detail Quiz",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Loading indicator
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: quizList.length,
                      itemBuilder: (context, index) {
                        var questionData = quizList[index];
                        var question = questionData['question'];
                        var options = [
                          questionData['option_a'],
                          questionData['option_b'],
                          questionData['option_c'],
                          questionData['option_d']
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            color: Colors.white,
                            shadowColor: Colors.black.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}. $question",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: blackColor,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  ...options.map((option) {
                                    int optionIndex = options.indexOf(option);
                                    return _buildOption(option, index, optionIndex);
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Tombol Selesai
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canFinishQuiz() ? submitQuizAnswers : null, // Tombol selesai hanya aktif jika semua soal dijawab
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canFinishQuiz()
                              ? secondPrimaryColor
                              : Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          elevation: 5,
                        ),
                        child: Text(
                          "Selesai",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
