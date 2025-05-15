import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:flame_audio/flame_audio.dart';  // Import Flame Audio
import 'package:ta_tahsin/core/theme.dart';
import '../materi/model/model_data_materi.dart';
import 'model/model_data_latihan.dart';

class LatihanPage extends StatefulWidget {
  const LatihanPage({super.key});

  @override
  _LatihanPageState createState() => _LatihanPageState();
}

class _LatihanPageState extends State<LatihanPage> {
  int currentStep = 0; // Start with the first step

  @override
  Widget build(BuildContext context) {
    if (currentStep >= latihanList.length) {
      currentStep = latihanList.length - 1; // Stay at last step if out of bounds
    }

    final arabicText = latihanList[currentStep]['arabicText'];
    final latinText = latihanList[currentStep]['latinText'];
    final audioFile = latihanList[currentStep]['audioFile']; // Get the audio file from data

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.go('/materi', extra: {
              'title': 'Makharijul Huruf',
              'description': 'tempat keluarnya huruf',
              'subMateri': materiList[0]['subMateri'],
            });
          },
        ),
        actions: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: index <= currentStep
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      arabicText,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      latinText,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 30),
                    IconButton(
                      onPressed: () {
                        // Play the audio file when the icon is clicked
                        FlameAudio.play(audioFile); // Play the audio using flame_audio
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
                        setState(() {
                          if (currentStep < latihanList.length - 1) {
                            currentStep++;
                          }
                        });

                        context.go(
                          '/pelafalan',
                          extra: {
                            'currentStep': currentStep,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondPrimaryColor,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(
                        Icons.mic,
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
      ),
    );
  }
}
