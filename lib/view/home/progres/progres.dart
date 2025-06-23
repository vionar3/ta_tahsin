import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;  // Import the http package
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'dart:convert';  // To parse the JSON data
import 'package:ta_tahsin/core/theme.dart';

class ProgresBelajarPage extends StatefulWidget {
  const ProgresBelajarPage({super.key});

  @override
  _ProgresBelajarPageState createState() => _ProgresBelajarPageState();
}

class _ProgresBelajarPageState extends State<ProgresBelajarPage> {
  bool isLoading = true;
  double progress = 0.0;
  String userName = 'Nama Pengguna'; // Default user name
  String userProfileImage = 'assets/icon/defaultprofile.jpeg'; // Default profile image

  // Fetch the progress percentage from the API
  Future<void> fetchProgressData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('token');
      debugPrint("Token yang diambil: $authToken");
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/progres/presentase'), // Update with actual API URL
      headers: {
        'Authorization': 'Bearer $authToken', // If you need to add authentication token
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        progress = data['progress_percentage'] / 100;  // Update progress as a fraction
        userName = data['nama_lengkap'];  // Set user name from API response
        isLoading = false;  // Set loading to false once data is fetched
      });
    } else {
      // Handle error if the API call fails
      setState(() {
        isLoading = false;
      });
      print('Failed to load progress data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProgressData();  // Call the function to fetch data when the page is loaded
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
              "Progres Belajar",
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loading Spinner while fetching data
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else ...[
                // Foto Profil Pengguna
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/icon/defaultprofile.jpeg'), // Use dynamic profile image
                    backgroundColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 16),
                // Nama Pengguna
                Center(
                  child: Text(
                    userName, // Use dynamic user name
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Judul Progres Belajar
                Text(
                  'Progres Belajar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 10),
                // Progress Bar untuk materi
                ProgressBar(title: 'Jumlah Latihan Selesai', progress: progress), 
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final String title;
  final double progress;

  const ProgressBar({super.key, required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: blackColor,
          ),
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            // Linear Progress Bar dengan sudut membulat
            SizedBox(
              height: 30, // Set height of the progress bar
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), // Membuat sudut membulat
                child: LinearProgressIndicator(
                  value: progress, // The current progress value
                  backgroundColor: Colors.grey[300], // Background color
                  color: secondPrimaryColor,  // Progress color
                  minHeight: 10,  // Height of the progress indicator
                ),
              ),
            ),
            // Percentage text on top of progress bar
            Positioned(
              child: Text(
                '${(progress * 100).toStringAsFixed(1)}%',  // Display percentage
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
