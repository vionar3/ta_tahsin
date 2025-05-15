import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> logout(BuildContext context) async {
    // Ambil token yang ada di SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      // Panggil API logout untuk menghapus token di server
      final response = await http.post(
        Uri.parse('http://192.168.100.45:8000/api/logout'), // Ganti dengan URL API logout
        headers: {
          'Authorization': 'Bearer $token', // Kirim token di header
        },
      );

      if (response.statusCode == 200) {
        // Jika berhasil logout, hapus token dari SharedPreferences
        prefs.remove('token');
        
        // Arahkan pengguna ke halaman login atau halaman lain setelah logout
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil logout!')),
        );

        // ignore: use_build_context_synchronously
        context.go('/login');
      } else {
        // Jika ada error dari server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: ${response.body}')),
        );
      }
    } else {
      // Jika tidak ada token yang tersimpan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak ditemukan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Profile",
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Section with Gradient Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          secondPrimaryColor,
                          Colors.blue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Profile Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/logo/sho.jpg'),
                        ),
                        const SizedBox(width: 16),

                        // Name and Phone Number to the right
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "irfan",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "083166408735",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // "Hasil Placement Test" Section with Gradient Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          secondPrimaryColor,
                          Colors.blue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTestResultSection("Tgl Lahir", "-"),
                        Divider(color: Colors.white), // White Divider for contrast
                        _buildTestResultSection("Alamat", "-"),
                        Divider(color: Colors.white), // White Divider for contrast
                        _buildTestResultSection("Nama Orang Tua", "-"),
                        Divider(color: Colors.white), // White Divider for contrast
                        _buildTestResultSection("email", "-"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    logout(context); 
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(fontSize: 16,color: whiteColor),
                  ),
                ),
              ],
            ),
            
          ),
        ),
      ),
    );
  }

  // Method to build test result sections
  Widget _buildTestResultSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 6),  // Space between label and value
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Method to create info links
  Widget _buildInfoLink(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.arrow_forward, color: secondPrimaryColor),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: secondPrimaryColor),
          ),
        ],
      ),
    );
  }
}
