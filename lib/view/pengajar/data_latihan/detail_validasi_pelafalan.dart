import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:audioplayers/audioplayers.dart';

class DetailValidasiPelafalan extends StatefulWidget {
  final int user_id;
  final int sub_materi_id;

  const DetailValidasiPelafalan({
    super.key,
    required this.user_id,
    required this.sub_materi_id,
  });

  @override
  _DetailValidasiPelafalanState createState() =>
      _DetailValidasiPelafalanState();
}

class _DetailValidasiPelafalanState extends State<DetailValidasiPelafalan> {
  List<dynamic> latihanList = [];
  List<int> nilaiList = [];
  List<String?> statusList = [];
  List<String?> feedbackList = [];
  List<TextEditingController> feedbackControllers = []; // List untuk TextEditingController
  bool isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchProgressLatihanData();
  }

  Future<void> fetchProgressLatihanData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
        '${BaseUrl.baseUrl}/progress/latihan/${widget.user_id}/${widget.sub_materi_id}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> fetchedList = data['data'] ?? [];

      setState(() {
        latihanList = fetchedList;
        nilaiList = List<int>.filled(fetchedList.length, 0);
        statusList = List<String?>.filled(fetchedList.length, null);
        feedbackList = List<String?>.filled(fetchedList.length, null); 
        feedbackControllers = List.generate(
          fetchedList.length,
          (index) => TextEditingController(text: feedbackList[index] ?? ''),
        );
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      debugPrint('Failed to load latihan data');
    }
  }

  void playRecordedAudio(String audioUrl) async {
    try {
      await _audioPlayer.play(UrlSource(audioUrl));
      debugPrint("Audio is playing: $audioUrl");
    } catch (e) {
      debugPrint("Failed to play audio: $e");
    }
  }

  // Function to call the API to save penilaian
  Future<void> savePenilaian() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  // Prepare the data to send in the POST request
  List<int> idProgressList = [];
  List<String?> statusValidasiList = [];
  List<String?> feedbackPengajarList = [];
  List<int> nilaiListToSend = [];

  for (int i = 0; i < latihanList.length; i++) {
    if (statusList[i] != null) { // Only send records that are updated
      // Ensure 'id' is not null and provide a default value if null
      var latihanId = latihanList[i]['id_progress'];
      if (latihanId == null) {
        debugPrint('Warning: latihanList[$i]["id"] is null. Using default value 0.');
        latihanId = 0; // Assign default value if null
      }

      idProgressList.add(latihanId); // Add the ID
      statusValidasiList.add(statusList[i]);
      feedbackPengajarList.add(feedbackList[i]);

      // Ensure `nilai` is not null and default to 0 if null
      int nilai = nilaiList[i] ?? 0; // Use 0 if nilaiList[i] is null
      nilaiListToSend.add(nilai);
    }
  }

  final response = await http.post(
    Uri.parse('${BaseUrl.baseUrl}/save_penilaian'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'id_progress': idProgressList,
      'status_validasi': statusValidasiList,
      'feedback_pengajar': feedbackPengajarList,
      'nilai': nilaiListToSend,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == true) {
      // Successfully saved penilaian
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message']),
      ));
    } else {
      // Error saving penilaian
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message']),
      ));
    }
  } else {
    // Handle API error
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Failed to save penilaian'),
    ));
  }
}




  @override
  void dispose() {
    // Dispose semua controller untuk feedback
    for (var controller in feedbackControllers) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = latihanList.isNotEmpty ? latihanList[0]['title'] ?? '' : '';
    final subtitle =
        latihanList.isNotEmpty ? latihanList[0]['subtitle'] ?? '' : '';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Card(
          elevation: 4,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: EdgeInsets.zero,
          child: AppBar(
            backgroundColor: secondPrimaryColor,
            title: const Text(
              'Validasi Pelafalan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : latihanList.isEmpty
              ? const Center(child: Text('Tidak ada data latihan'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: latihanList.length,
                          itemBuilder: (context, index) {
                            var item = latihanList[index];
                            final recorderPath = item['recorder_audio'];
                            final audioUrl =
                                '${BaseUrl.audioUrl}/storage/${recorderPath ?? ''}';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Card Ayat & Audio
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        spreadRadius: 2,
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.menu_book_rounded,
                                              color: Colors.teal,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                item['potongan_ayat'] ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
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
                                                item['latin_text'] ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.volume_up_rounded,
                                              color: secondPrimaryColor,
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    secondPrimaryColor,
                                                foregroundColor: whiteColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              icon: const Icon(Icons.play_arrow),
                                              label: const Text("Putar Audio"),
                                              onPressed: () {
                                                if (recorderPath != null &&
                                                    recorderPath.isNotEmpty) {
                                                  playRecordedAudio(audioUrl);
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Audio tidak tersedia",
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Tombol Benar / Salah
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 12.0,
                                    left: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            statusList[index] = 'benar';
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: statusList.length > index &&
                                                  statusList[index] == 'salah'
                                              ? Colors.grey
                                              : Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text("Benar"),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            statusList[index] = 'salah';
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: statusList.length > index &&
                                                  statusList[index] == 'benar'
                                              ? Colors.grey
                                              : Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text("Salah"),
                                      ),
                                    ],
                                  ),
                                ),
                                // Container for Penilaian -> only shows when status is selected
                                if (statusList.length > index && statusList[index] != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 24.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.feedback_outlined,
                                                color: Colors.blueAccent,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Penilaian Pengajar",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            height: 24,
                                            color: Colors.grey,
                                          ),
                                          const Text(
                                            "📝 Keterangan / Feedback",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            controller: feedbackControllers[index], // Menggunakan controller per index
                                            decoration: InputDecoration(
                                              hintText: "Tulis feedback...",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                feedbackList[index] = value;
                                              });
                                            },
                                            maxLines: 3,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "📊 Nilai (0-100)",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.redAccent,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    // Only decrease nilai if status is "benar"
                                                    if (statusList[index] == 'benar' &&
                                                        nilaiList[index] >= 10) {
                                                      nilaiList[index] -= 10;
                                                    }
                                                  });
                                                },
                                              ),
                                              Container(
                                                width: 60,
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Colors.grey.shade100,
                                                ),
                                                child: Text(
                                                  nilaiList.length > index
                                                      ? nilaiList[index].toString()
                                                      : '0',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add_circle,
                                                  color: Colors.green,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    // Only increase nilai if status is "benar"
                                                    if (statusList[index] == 'benar' &&
                                                        nilaiList[index] <= 90) {
                                                      nilaiList[index] += 10;
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Save Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              savePenilaian();
                              // Navigasi ke halaman hasil_validasi.dart dengan data
context.push(
  '/hasil_validasi',
  extra: {
    'user_id': widget.user_id,
    'sub_materi_id': widget.sub_materi_id,
  },
);

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
                                Icon(
                                  Icons.save_alt,
                                  color: whiteColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Simpan",
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
    );
  }
}
