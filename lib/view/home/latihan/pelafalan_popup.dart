import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'model/model_data_pelafalan.dart';

class PelafalanPage extends StatelessWidget {
  final int currentStep;

  const PelafalanPage({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure that currentStep is within the bounds of pelafalanList
    if (currentStep >= pelafalanList.length) {
      return Center(child: Text("End of List"));
    }

    final arabicText = pelafalanList[currentStep]['arabicText'];
    final latinText = pelafalanList[currentStep]['latinText'];
    final materiDescription = pelafalanList[currentStep]['materiDescription'];
    final correctAudio = pelafalanList[currentStep]['correctAudio'];
    final recordedAudio = pelafalanList[currentStep]['recordedAudio'];

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
                    arabicText,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
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
                            'Pelafalan Kamu',
                            style: TextStyle(
                              color: secondPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Icon(
                            Icons.volume_up,
                            color: secondPrimaryColor,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                    Container(
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
                            'Pelafalan Ustadz',
                            style: TextStyle(
                              color: secondPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Icon(
                            Icons.volume_up,
                            color: secondPrimaryColor,
                            size: 30,
                          ),
                        ],
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
                        // Logic to view video
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
                  materiDescription,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Update the progress and navigate back to LatihanPage
                        context.go(
                          '/latihan',
                          extra: {'currentStep': currentStep + 1}, // Move to next step
                        );
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
                        'Lanjut',
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
                        context.pop();
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

