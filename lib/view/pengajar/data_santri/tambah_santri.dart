import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';

class TambahSantriPage extends StatefulWidget {
  @override
  _TambahSantriPageState createState() => _TambahSantriPageState();
}

class _TambahSantriPageState extends State<TambahSantriPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _jenjangPendidikanController = TextEditingController();
  String _gender = 'Laki-laki';

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      print("Validation Passed");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Center(child: CircularProgressIndicator()),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('token');
      debugPrint("Token yang diambil: $authToken");

      if (authToken == null) {
        Navigator.of(context).pop();
        print("Token tidak ditemukan!");
        return;
      }

      final Map<String, String> data = {
        'nama_lengkap': _fullNameController.text,
        'alamat': _addressController.text,
        'usia': _dobController.text,
        'no_telp_wali': _phoneController.text,
        'email': _emailController.text,
        'jenis_kelamin': _gender,
        'jenjang_pendidikan': _jenjangPendidikanController.text,
      };

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/tambahSantri'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      Navigator.of(context).pop();

      print("API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Sukses'),
            content: Text('Santri berhasil ditambahkan'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/navigasiPengajar');
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        print("Failed to submit: ${response.body}");
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Gagal'),
            content: Text('Terjadi kesalahan, silakan coba lagi.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  context.go('/navigasiPengajar');
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      print("Validation Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Santri'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/navigasiPengajar');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextFormField(_fullNameController, 'Nama Lengkap'),
                _buildTextFormField(_addressController, 'Alamat'),
                _buildTextFormField(_dobController, 'Usia'),
                _buildTextFormField(_jenjangPendidikanController, 'Jenjang Pendidikan'),
                Row(
                  children: [
                    Text('Jenis Kelamin', style: TextStyle(fontSize: 16)),
                    Radio<String>(
                      value: 'Laki-laki',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value!;
                        });
                      },
                    ),
                    Text('Laki-laki'),
                    Radio<String>(
                      value: 'Perempuan',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value!;
                        });
                      },
                    ),
                    Text('Perempuan'),
                  ],
                ),
                SizedBox(height: 20),
                _buildTextFormField(_phoneController, 'No WA Wali'),
                _buildTextFormField(_emailController, 'Email'),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(double.infinity, 50),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      print("Simpan Taped");
                      await _submitForm();
                    },
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
      ),
    );
  }

  // Fungsi pembuat TextFormField
  Widget _buildTextFormField(TextEditingController controller, String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
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
