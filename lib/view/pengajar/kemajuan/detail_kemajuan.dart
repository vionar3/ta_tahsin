import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'dart:convert';
import 'package:ta_tahsin/core/theme.dart';

class DetailKemajuanPage extends StatefulWidget {
  final String nama;
  final int userId;
  const DetailKemajuanPage({super.key, required this.nama, required this.userId});

  @override
  _DetailKemajuanPageState createState() => _DetailKemajuanPageState();
}

class _DetailKemajuanPageState extends State<DetailKemajuanPage> {
  bool isLoading = true;
  double progress = 0.0;
  String userProfileImage = 'assets/icon/defaultprofile.jpeg'; // Default profile image

  // Variables to store submateri and completed submateri
  int totalSubmateri = 0;
  int completedSubmateri = 0;

  // Fetch the progress percentage and submateri details from the API
  Future<void> fetchProgressData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    debugPrint("Token yang diambil: $authToken");

    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/progres/${widget.userId}'), // Update with actual API URL
      headers: {
        'Authorization': 'Bearer $authToken', // If you need to add authentication token
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        progress = data['progress_percentage'] / 100;  // Update progress as a fraction
        totalSubmateri = data['total_submateri'];  // Update total submateri
        completedSubmateri = data['completed_submateri'];  // Update completed submateri
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
        preferredSize: Size.fromHeight(60), 
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
                context.go('/navigasiPengajar');
              },
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loading Spinner while fetching data
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else ...[
                // Profile Section with CircleAvatar and Shadow
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(userProfileImage), // Use dynamic profile image
                    backgroundColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name Section
                Center(
                  child: Text(
                    widget.nama, // Use dynamic user name
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Progres Belajar Title
                Text(
                  'Progres Belajar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 10),
                // Display total_submateri and completed_submateri in a Card
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Submateri',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$totalSubmateri',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Completed Submateri',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$completedSubmateri',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Progress Bar for learning progress
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
            // Linear Progress Bar with rounded corners
            SizedBox(
              height: 30, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), 
                child: LinearProgressIndicator(
                  value: progress, 
                  backgroundColor: Colors.grey[300], 
                  color: secondPrimaryColor,  
                  minHeight: 10,  
                ),
              ),
            ),
            // Percentage text overlaying the progress bar
            Positioned(
              child: Text(
                '${(progress * 100).toStringAsFixed(1)}%',  
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
