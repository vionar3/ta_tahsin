import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';

class PelafalanPage extends StatefulWidget {
  final int id;
  final int currentStep;
  final List<dynamic> latihanData;
  final String recordedFilePath;

  const PelafalanPage({
    super.key,
    required this.id,
    required this.currentStep,
    required this.latihanData,
    required this.recordedFilePath,
  });

  @override
  _PelafalanPageState createState() => _PelafalanPageState();
}

class _PelafalanPageState extends State<PelafalanPage> {
  late String recordedFilePath;
  late int currentStep;
  late List<dynamic> latihanData;
  late dynamic latihan;
  final AudioPlayer _audioPlayer = AudioPlayer(); 
  bool isAudioPlaying = false;
  bool isAudioRecordPlaying = false;

  @override
  void initState() {
    super.initState();
    recordedFilePath = widget.recordedFilePath;
    
    currentStep = widget.currentStep;
    latihanData = widget.latihanData;
    latihan = latihanData[currentStep];
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        setState(() {
          isAudioPlaying = false; 
          isAudioRecordPlaying = false; 
        });
      }
    });
  }

  void playAudio(String audioUrl) async {
    
    await _audioPlayer.play(AssetSource(audioUrl));  
    setState(() {
      isAudioPlaying = true; 
    });
    print("Audio playing...");
  }

  void playRecordedAudio() async {
    await _audioPlayer.play(DeviceFileSource(recordedFilePath));  
    setState(() {
      isAudioRecordPlaying = true; 
    });
    print("Audio playing...");
  }

  // Future<void> updateProgress(int subMateriId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? authToken = prefs.getString('token');
  //   debugPrint("Token yang diambil: $authToken");
  //   final String apiUrl = '${BaseUrl.baseUrl}/progress/$subMateriId/update'; // Ganti dengan URL API yang sesuai

  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     headers: {
  //       'Authorization': 'Bearer $authToken',
  //     },
  //     body: jsonEncode({
  //       'sub_materi_id': subMateriId, // ID submateri yang sedang dikerjakan
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     // Progres berhasil diupdate
  //     print('Progress updated successfully');
  //     // ignore: use_build_context_synchronously
  //     _showCompletionDialog(context);
  //   } else {
  //     // Handle error
  //     print('Failed to update progress');
  //   }
  // }

  Future<void> updateStatusProgress() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');
  final String apiUrl = '${BaseUrl.baseUrl}/update_progress_status';

  // Ambil list ID progress yang tersimpan
  List<int> progressIds = prefs.getStringList('progressIds')?.map((e) => int.parse(e)).toList() ?? [];

  if (progressIds.isEmpty) {
    debugPrint('No progress IDs found to update.');
    return;
  }

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'progress_ids': progressIds,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Progress status updated successfully.');
      _showCompletionDialog(context);

      // Hapus setelah update
    } else {
      debugPrint('Failed to update progress status. Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error updating progress status: $e');
  }
}


// Function to remove latihan ids from SharedPreferences after the action
Future<void> clearLatihanIds() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('progressIds');
  debugPrint("progressIds cleared from SharedPreferences.");
}



  void _showCompletionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Selamat!'),
        content: Text('Kamu telah menyelesaikan latihan ini.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog
              context.go('/navigasi');
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: secondPrimaryColor,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Simak Pelafalanmu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: secondPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    latihan['potongan_ayat'],
                    style: TextStyle(
                      fontSize: 30,
                      color: blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        playRecordedAudio();
                        print("Pelafalan Kamu tapped!");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:  Colors.grey,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Pelafalan Kamu',
                              style: TextStyle(
                                color: secondPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Icon(
                              isAudioRecordPlaying ? Icons.volume_up : Icons.volume_down,
                              color: secondPrimaryColor,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("Pelafalan Ustadz tapped!");
                        playAudio('audio/${latihan['correct_audio']}');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Pelafalan Benar',
                              style: TextStyle(
                                color: secondPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Icon(
                              isAudioPlaying ? Icons.volume_up : Icons.volume_down,
                              color: secondPrimaryColor,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Materi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Logic untuk melihat video
                      },
                      child: Text(
                        'Lihat Video',
                        style: TextStyle(
                          fontSize: 16,
                          color: secondPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  latihan['materi_description'],
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (currentStep < latihanData.length - 1) {
                          setState(() {
                            currentStep++; // Update step saat lanjut
                          });
                          context.go(
                            '/latihan',
                            extra: {
                              'id': widget.id,
                              'currentStep': currentStep,
                            },
                          );
                        } else {
                          //  updateProgress(widget.id);
                          
                          
      updateStatusProgress();  // Pass submateri_id (widget.id) and latihan_ids
      await clearLatihanIds();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        currentStep == latihanData.length - 1 ? 'Selesai' : 'Lanjut',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.go(
                          '/latihan',
                          extra: {
                            'id': widget.id,
                            'currentStep': currentStep,
                            'latihanData': latihanData,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Coba Lagi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: secondPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
