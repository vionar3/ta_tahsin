import 'package:flutter/material.dart';
import 'package:ta_tahsin/core/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DetailDataSantriPage(),
    );
  }
}

class DetailDataSantriPage extends StatefulWidget {
  @override
  _DetailDataSantriPageState createState() => _DetailDataSantriPageState();
}

class _DetailDataSantriPageState extends State<DetailDataSantriPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _gender = 'Laki-laki';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Santri'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(  // Add this to make the screen scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture section
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/icon/defaultprofile.jpeg'),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(height: 20),

              // Title section
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

              // Basic details section
              _buildTextFormField(_fullNameController, 'Nama Lengkap'),
              _buildTextFormField(_dobController, 'Usia'),
              _buildTextFormField(_dobController, 'Jilid Tilawati'),

              // Gender selection section
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

              // Contact details section
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

              _buildTextFormField(_phoneController, 'No WA Wali'),
              _buildTextFormField(_emailController, 'Email'),
              SizedBox(height: 20),

              // Personal details section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: secondPrimaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Text(
                  'Detail Pribadi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: whiteColor),
                ),
              ),
              SizedBox(height: 16),

              _buildTextFormField(_weightController, 'Berat Badan (kg)'),
              _buildTextFormField(_heightController, 'Tinggi Badan (cm)'),
              SizedBox(height: 40),

              // Save button section with shadow effect
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondPrimaryColor, // Customize your color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, 50),
                    elevation: 5,  // Adding shadow to the button
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profil tersimpan')),
                      );
                    }
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
    );
  }

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
