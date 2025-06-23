import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _jenjangPendidikanController = TextEditingController();
  String _gender = 'Laki-laki';
  bool _isEditing = false; // Track whether we are in edit mode
  bool _isLoading = true; // Track whether data is loading

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
        _fullNameController.text = data['data']['nama_lengkap'];
        _addressController.text = data['data']['alamat'];
        _dobController.text = data['data']['usia'];
        _phoneController.text = data['data']['no_telp_wali'];
        _emailController.text = data['data']['email'];
        _jenjangPendidikanController.text = data['data']['jenjang_pendidikan'];
        _gender = data['data']['jenis_kelamin'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update user data using API
Future<void> _updateUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token tidak ditemukan')),
    );
    return;
  }

  final response = await http.post(
    Uri.parse('${BaseUrl.baseUrl}/user/updateBytoken'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'nama_lengkap': _fullNameController.text,
      'alamat': _addressController.text,
      'usia': _dobController.text,
      'no_telp_wali': _phoneController.text,
      'email': _emailController.text,
      'jenjang_pendidikan': _jenjangPendidikanController.text,
      'jenis_kelamin': _gender,
    }),
  );

  // Print response status and body for debugging
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    _showSuccessDialog();
    setState(() {
      _isEditing = false;
    });
    // Optionally navigate to another page or refresh profile
  } else {
    // Handle error and print response body
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mengubah data: ${response.body}')),
    );
    print("Error response: ${response.body}"); // Print error response here
  }
}


  // Show a success dialog after user data is updated successfully
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Berhasil'),
          content: Text('Data santri berhasil diubah.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/navigasi');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note, size: 35),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing; // Toggle edit mode
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/icon/defaultprofile.jpeg'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: secondPrimaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Text(
                        'Detail Dasar',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: whiteColor),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextFormField(_fullNameController, 'Nama Lengkap', _isEditing),
                    _buildTextFormField(_addressController, 'Alamat', _isEditing),
                    _buildTextFormField(_dobController, 'Usia', _isEditing),
                    _buildTextFormField(_jenjangPendidikanController, 'Jenjang Pendidikan', _isEditing),
                    Row(
                      children: [
                        Text('Jenis Kelamin', style: TextStyle(fontSize: 16)),
                        Radio<String>(
                          value: 'Laki-laki',
                          groupValue: _gender,
                          onChanged: _isEditing
                              ? (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                }
                              : null,
                        ),
                        Text('Laki-laki'),
                        Radio<String>(
                          value: 'Perempuan',
                          groupValue: _gender,
                          onChanged: _isEditing
                              ? (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                }
                              : null,
                        ),
                        Text('Perempuan'),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: secondPrimaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Text(
                        'Detail Kontak',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: whiteColor),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextFormField(_phoneController, 'No WA Wali', _isEditing),
                    _buildTextFormField(_emailController, 'Email', _isEditing),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEditing ? secondPrimaryColor : Colors.grey, // Button color based on editing
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(double.infinity, 50),
                          elevation: 5,  // Adding shadow to the button
                        ),
                        onPressed: _isEditing
                            ? () {
                                // Trigger the update user function when editing
                                _updateUserData();
                              }
                            : null,
                        child: Text(
                          "Simpan",
                          style: TextStyle(fontSize: 16, color: whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper function to build TextFormField
  Widget _buildTextFormField(TextEditingController controller, String labelText, bool isEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isEnabled, // Control whether the field is enabled or not
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Harap masukkan $labelText Anda';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
