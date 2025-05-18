import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Untuk parsing JSON
import 'dart:async'; // Untuk timer
import 'package:audioplayers/audioplayers.dart';  // Tambahkan audioplayers

class LatihanPage extends StatefulWidget {
  final int id; // ID yang diteruskan dari halaman sebelumnya
  final int currentStep; // Menambahkan parameter currentStep

  const LatihanPage({super.key, required this.id, required this.currentStep});

  @override
  _LatihanPageState createState() => _LatihanPageState();
}

class _LatihanPageState extends State<LatihanPage> {
  late Future<List<dynamic>> latihanData; // Data latihan berdasarkan id_submateri
  bool isRecording = false; // Menandakan apakah sedang merekam
  int timer = 10; // Timer dimulai dari 10 detik
  late Timer countdownTimer; // Timer untuk countdown
  String timerText = "10"; // Menampilkan countdown timer dalam teks
  final AudioPlayer _audioPlayer = AudioPlayer(); // Inisialisasi Audioplayer

  @override
  void initState() {
    super.initState();
    latihanData = fetchLatihanData(widget.id); // Ambil data latihan berdasarkan id_submateri yang diteruskan
  }

  // Fungsi untuk mengambil data latihan dari API
  Future<List<dynamic>> fetchLatihanData(int id_submateri) async {
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/latihan/$id_submateri'), // Gantilah dengan URL API yang sesuai
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data']; // Parse data latihan dari API
    } else {
      throw Exception('Failed to load latihan');
    }
  }

  // Fungsi untuk mulai countdown timer
  void startTimer() {
    setState(() {
      isRecording = true; // Set to true when starting to record
      timer = 10; // Reset timer to 10 seconds
      timerText = timer.toString();
    });

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (this.timer > 0) {
        setState(() {
          this.timer--;
          timerText = this.timer.toString();
        });
      } else {
        countdownTimer.cancel();
        setState(() {
          isRecording = false; // Stop recording after timer ends
        });
      }
    });
  }

  // Fungsi untuk menghentikan timer dan reset ke kondisi semula
  void stopTimer() {
    countdownTimer.cancel();
    setState(() {
      isRecording = false; // Stop recording
      timer = 10; // Reset timer
      timerText = timer.toString();
    });
  }

  // Fungsi untuk memutar audio dari asset berdasarkan URL yang diterima
void playAudio(String audioUrl) async {
  // Menggunakan AssetSource untuk memutar audio dari asset
  await _audioPlayer.play(AssetSource(audioUrl));  // Gunakan AssetSource untuk audio lokal
  print("Audio playing...");
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.go('/navigasi'); // Navigasi kembali ke halaman utama
          },
        ),
        actions: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: index <= widget.currentStep
                          ? secondPrimaryColor
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: latihanData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Tampilkan loading selama data dimuat
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Menampilkan pesan error
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada latihan tersedia')); // Menampilkan pesan jika tidak ada data latihan
          }

          // Ambil data latihan berdasarkan currentStep
          final latihanList = snapshot.data!;
          final latihan = latihanList[widget.currentStep]; // Ambil data latihan untuk currentStep

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: secondPrimaryColor,
                        size: 40,
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dengarkan, ikuti dan rekam',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: blackColor,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              'pelafalanmu terhadap lafadz ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: blackColor,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 40.0),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 10,
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 40.0),
                          child: Text(
                            "Ucapkan potongan kata ini",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          latihan['potongan_ayat'], // Menampilkan potongan ayat dari data latihan
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          latihan['latin_text'], // Menampilkan teks latin dari data latihan
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 30),
                        IconButton(
                          onPressed: () {
                            // Memutar audio dari asset sesuai dengan URL yang ada pada `correct_audio`
                            playAudio('audio/${latihan['correct_audio']}');
                          },
                          icon: Icon(
                            Icons.volume_up,
                            size: 50,
                            color: secondPrimaryColor,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!isRecording) {
                              startTimer(); // Start timer and change to stop icon
                            } else {
                              stopTimer(); // Stop timer and reset the button
                              // Pass data to PelafalanPage after recording
                              context.go(
                                '/pelafalan',
                                extra: {
                                  'id': widget.id,
                                  'currentStep': widget.currentStep,
                                  'latihanData': snapshot.data, // Mengirimkan data latihan yang sudah di-fetch
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondPrimaryColor,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic, // Toggle between mic and stop icon
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();  // Jangan lupa untuk melepaskan player
    super.dispose();
  }
}
