import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailDataSantriPage extends StatefulWidget {
  final int id;
  const DetailDataSantriPage({super.key, required this.id});

  @override
  _DetailDataSantriPageState createState() => _DetailDataSantriPageState();
}

class _DetailDataSantriPageState extends State<DetailDataSantriPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _jenjangPendidikanController = TextEditingController();
  String _gender = 'Laki-laki';
  bool _isEditing = false; // Track whether we are in edit mode

  @override
  void initState() {
    super.initState();
    // Panggil API untuk mengambil data pengguna berdasarkan ID
    _fetchUserData();
  }

  // Fungsi untuk mengambil data pengguna berdasarkan ID dengan token dari SharedPreferences
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');

    if (authToken == null) {
      print("Token tidak ditemukan!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak ditemukan!')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/user/${widget.id}'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];

      setState(() {
        _fullNameController.text = data['nama_lengkap'];
        _addressController.text = data['alamat'];
        _dobController.text = data['usia'].toString();
        _phoneController.text = data['no_telp_wali'];
        _emailController.text = data['email'];
        _jenjangPendidikanController.text = data['jenjang_pendidikan'];
        _gender = data['jenis_kelamin'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data pengguna')),
      );
    }
  }

  // API function to update user data
  Future<void> _updateUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');

    if (authToken == null) {
      print("Token tidak ditemukan!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak ditemukan!')),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('${BaseUrl.baseUrl}/updateUser/${widget.id}'),
      headers: {
        'Authorization': 'Bearer $authToken',
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

    if (response.statusCode == 200) {
      // Show the success dialog
      _showSuccessDialog();
    } else {
      // Handle error if the API call fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user')),
      );
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
                // context.go('/navigasiPengajar');
                // context.go('/detail_user', extra: {
                //                 'id': widget.id,
                //               });
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
        title: Text('Detail Santri'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/navigasiPengajar');
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
      body: SingleChildScrollView(
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
