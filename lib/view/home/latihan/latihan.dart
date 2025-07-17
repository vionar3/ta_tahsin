import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'dart:async'; 
import 'package:audioplayers/audioplayers.dart';  
import 'package:http_parser/http_parser.dart';

class LatihanPage extends StatefulWidget {
  final int id; 
  final int currentStep; 

  const LatihanPage({super.key, required this.id, required this.currentStep});

  @override
  _LatihanPageState createState() => _LatihanPageState();
}

class _LatihanPageState extends State<LatihanPage> {
  final  _record = AudioRecorder();
  late Future<List<dynamic>> latihanData; 
  bool isRecording = false; 
  int timer = 10; 
  late Timer countdownTimer; 
  String timerText = "10"; 
  final AudioPlayer _audioPlayer = AudioPlayer(); 
  bool isAudioPlaying = false;
  String? recordedFilePath;

  @override
  void initState() {
    super.initState();
    latihanData = fetchLatihanData(widget.id); 
    
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        setState(() {
          isAudioPlaying = false; 
        });
      }
    });
  }

  
  Future<List<dynamic>> fetchLatihanData(int id_submateri) async {
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/latihan/$id_submateri'), 
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data']; 
    } else {
      throw Exception('Failed to load latihan');
    }
  }

  
  // Fungsi untuk memulai timer dan mulai merekam
  void startTimer() {
    setState(() {
      isRecording = true;
      timer = 10;
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
        stopRecording();
      }
    });

    // Mulai merekam
    _startRecording();
  }

  
  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final directory = Directory.systemTemp;
final fileName = DateTime.now().millisecondsSinceEpoch.toString();
final path = '${directory.path}/record_voice_$fileName.m4a';  // Pastikan file disimpan dengan ekstensi .m4a
await _record.start(
  const RecordConfig(),
  path: path,
);
      setState(() {
        recordedFilePath = path;
      });
    }
  }

// Future<void> uploadRecording(String filePath, int subMateriId, int idLatihan) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? authToken = prefs.getString('token');
//   var uri = Uri.parse('${BaseUrl.baseUrl}/upload_audio');
//   var request = http.MultipartRequest('POST', uri);

//   final extension = filePath.split('.').last.toLowerCase();
//   if (!['m4a', 'mp3', 'wav'].contains(extension)) {
//     print("File format is not supported. Please use m4a, mp3, or wav.");
//     return;
//   }


//   var file = await http.MultipartFile.fromPath(
//     'recorded_audio',
//     filePath,
//     contentType: MediaType('audio', 'm4a'),
//   );
//   request.files.add(file);

//   // Tambahkan sub_materi_id dan id_latihan
//   request.fields['sub_materi_id'] = subMateriId.toString();
//   request.fields['id_latihan'] = idLatihan.toString();

//   request.headers.addAll({
//     'Authorization': 'Bearer $authToken',
//     'Accept': 'application/json',
//   });

//   try {
//     var response = await request.send();
//     var responseBody = await response.stream.bytesToString();

//     if (response.statusCode == 200) {
//       print('Upload berhasil!');
//       print('Response body: $responseBody');
//     } else {
//       print('Gagal mengupload file: ${response.statusCode}');
//       print('Response body: $responseBody');
//     }
//   } catch (e) {
//     print('Terjadi kesalahan saat mengupload: $e');
//   }
// }


Future<void> uploadRecording(String filePath, int subMateriId, int idLatihan) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');
  var uri = Uri.parse('${BaseUrl.baseUrl}/upload_audio');
  var request = http.MultipartRequest('POST', uri);

  final extension = filePath.split('.').last.toLowerCase();
  if (!['m4a', 'mp3', 'wav'].contains(extension)) {
    print("File format is not supported. Please use m4a, mp3, or wav.");
    return;
  }

  var file = await http.MultipartFile.fromPath(
    'recorded_audio',
    filePath,
    contentType: MediaType('audio', 'm4a'),
  );
  request.files.add(file);

  request.fields['sub_materi_id'] = subMateriId.toString();
  request.fields['id_latihan'] = idLatihan.toString();

  request.headers.addAll({
    'Authorization': 'Bearer $authToken',
    'Accept': 'application/json',
  });

  try {
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('Upload berhasil!');
      print('Response body: $responseBody');

      // Parse response body
      final decoded = json.decode(responseBody);

      // Ambil id dari progress
      final int progressId = decoded['progress']['id'];

      // Simpan id ke SharedPreferences
      await storeProgressId(progressId);
    } else {
      print('Gagal mengupload file: ${response.statusCode}');
      print('Response body: $responseBody');
    }
  } catch (e) {
    print('Terjadi kesalahan saat mengupload: $e');
  }
}



Future<void> stopRecording() async {
  await _record.stop();
  // await uploadRecording(recordedFilePath!);

  // Check if the widget is still mounted before calling setState
  if (mounted) {
    setState(() {
      isRecording = false;
    });
  }

  // Get the latihan id from the latihanData list using the current step
  final latihanList = await latihanData; // Fetch the data again if not already fetched
  final latihan = latihanList[widget.currentStep];  // Get the latihan at current step
  final idLatihan = latihan['id'];  // Use the 'id' from latihan data


  // Debug print to show the file path and latihan ID
  debugPrint('ID Latihan: $idLatihan');
  debugPrint('File Path: $recordedFilePath');

  // After stopping the recording, save the audio file name/path to the backend
  if (recordedFilePath != null) {
    // saveRecordedAudioName(idLatihan, recordedFilePath!); // Pass the latihan ID to the save function
    await uploadRecording(recordedFilePath!, widget.id, idLatihan);
  }
}

Future<void> storeProgressId(int idProgress) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<int> progressIds = prefs.getStringList('progressIds')?.map((e) => int.parse(e)).toList() ?? [];
  progressIds.add(idProgress);  // Add the new id to the list

  // Store the list as a string (in SharedPreferences)
  await prefs.setStringList('progressIds', progressIds.map((e) => e.toString()).toList());
  debugPrint("Stored progress IDs: $progressIds");
}
  
  void stopTimer() {
    countdownTimer.cancel();
    stopRecording();
    setState(() {
      isRecording = false; 
      timer = 10; 
      timerText = timer.toString();
    });
  }

   
  void playAudio(String audioUrl) async {
    
    await _audioPlayer.play(AssetSource(audioUrl));  
    setState(() {
      isAudioPlaying = true; 
    });
    print("Audio playing...");
  }

  Future<void> clearProgressIds() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('progressIds');
  debugPrint("progressIds cleared from SharedPreferences.");
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await clearProgressIds(); // Hapus data sebelum navigasi
            context.go('/navigasi'); 
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
            return Center(child: CircularProgressIndicator()); 
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); 
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada latihan tersedia')); 
          }

          
          final latihanList = snapshot.data!;
          final latihan = latihanList[widget.currentStep]; 

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
                         Padding(
                          padding: EdgeInsets.only(bottom: 40.0),
                          child: Text(
                            "Ucapkan potongan kata ini",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: secondPrimaryColor,
                            ),
                          ),
                        ),
                        Text(
                          latihan['potongan_ayat'], 
                          style: TextStyle(
                            fontSize: 19,
                            color: blackColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          latihan['latin_text'], 
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 30),
                        IconButton(
                          onPressed: isRecording ? null : () {
                            
                            playAudio('audio/${latihan['correct_audio']}');
                          },
                          icon: Icon(
                            isAudioPlaying ? Icons.volume_up : Icons.volume_down,
                            size: 50,
                            color: isRecording ? greysColor : secondPrimaryColor,
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
                          onPressed: isAudioPlaying ? null : () {
                            if (!isRecording) {
                              startTimer(); 
                            } else {
                              stopTimer(); 
                              
                              context.go(
                                '/pelafalan',
                                extra: {
                                  'id': widget.id,
                                  'currentStep': widget.currentStep,
                                  'latihanData': snapshot.data, 
                                  'recordedFilePath': recordedFilePath,
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAudioPlaying ? greysColor : secondPrimaryColor,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic, 
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
    _record.dispose();
    _audioPlayer.dispose();
    if (countdownTimer.isActive) {
    countdownTimer.cancel();  // Cancel the timer
  }  
    super.dispose();
  }
}
