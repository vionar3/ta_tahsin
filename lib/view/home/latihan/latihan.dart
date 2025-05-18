import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'dart:async'; 
import 'package:audioplayers/audioplayers.dart';  

class LatihanPage extends StatefulWidget {
  final int id; 
  final int currentStep; 

  const LatihanPage({super.key, required this.id, required this.currentStep});

  @override
  _LatihanPageState createState() => _LatihanPageState();
}

class _LatihanPageState extends State<LatihanPage> {
  late Future<List<dynamic>> latihanData; 
  bool isRecording = false; 
  int timer = 10; 
  late Timer countdownTimer; 
  String timerText = "10"; 
  final AudioPlayer _audioPlayer = AudioPlayer(); 
  bool isAudioPlaying = false;

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
        setState(() {
          isRecording = false; 
        });
      }
    });
  }

  
  void stopTimer() {
    countdownTimer.cancel();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
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
                          latihan['potongan_ayat'], 
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.red,
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
    _audioPlayer.dispose();  
    super.dispose();
  }
}
