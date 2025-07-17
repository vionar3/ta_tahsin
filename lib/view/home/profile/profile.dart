import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Untuk parsing JSON
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _email;
  String? _age;
  String? _phone;
  String? _guardianName;
  String? _guardianPhone;
  String? _address;
  String? _gender;
  String? _educationLevel;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from API
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _errorMessage = "Token tidak ditemukan.";
        _isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/user'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _name = data['data']['nama_lengkap'];
        _email = data['data']['email'];
        _age = data['data']['usia'];
        _phone = data['data']['no_telp_wali'];
        _guardianName = data['data']['nama_wali'];
        _guardianPhone = data['data']['no_telp_wali'];
        _address = data['data']['alamat'];
        _gender = data['data']['jenis_kelamin'];
        _educationLevel = data['data']['jenjang_pendidikan'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = "Gagal mengambil data pengguna: ${response.body}";
        _isLoading = false;
      });
    }
  }

  // Logout Function
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/logout'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        prefs.remove('token');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil logout!')),
        );
        context.go('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: ${response.body}')),
        );
      }
    } else {
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
        title: Text("Profile"),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [secondPrimaryColor, Colors.blue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    backgroundImage: AssetImage(
                                        'assets/icon/defaultprofile.jpeg'),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _name ?? "Nama Tidak Ditemukan",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _phone ?? "Nomor Telepon Tidak Ditemukan",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [secondPrimaryColor, Colors.blue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTestResultSection("Tanggal Lahir", _age ?? "-"),
                                  Divider(color: Colors.white),
                                  _buildTestResultSection("Email", _email ?? "-"),
                                  Divider(color: Colors.white),
                                  _buildTestResultSection("Nama Wali",
                                      _guardianName ?? "-"),
                                  Divider(color: Colors.white),
                                  _buildTestResultSection(
                                      "Alamat", _address ?? "-"),
                                  Divider(color: Colors.white),
                                  _buildTestResultSection(
                                      "Jenis Kelamin", _gender ?? "-"),
                                  Divider(color: Colors.white),
                                  _buildTestResultSection(
                                      "Jenjang Pendidikan", _educationLevel ?? "-"),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
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
        _buildInfoLink("Edit Profile", () {
          
          context.go('/edit_profile');
        }),
        Divider(color: Colors.white),
        _buildInfoLink("Progres Belajar", () {
          context.go('/progres_belajar');
        }),
        Divider(color: Colors.white),
        _buildInfoLink("Ubah Password", () {
          context.go('/ubah_password');
        }),
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
                              style: TextStyle(fontSize: 16, color: whiteColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

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
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoLink(String label, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: GestureDetector(
      onTap: onTap,  // Menambahkan aksi saat item ditekan
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Mengatur posisi label dan ikon
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Icon(
            Icons.arrow_forward, 
            color: Colors.white,  // Anda bisa menyesuaikan warna ikon sesuai dengan desain Anda
          ),
        ],
      ),
    ),
  );
}
}
