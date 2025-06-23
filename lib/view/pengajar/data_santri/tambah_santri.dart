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
  final TextEditingController _dobController = TextEditingController(); // For DOB
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _gender = 'Laki-laki';
  String _selectedJenjangPendidikan = 'SD'; // Default value

  // List for dropdown values
  List<String> jenjangPendidikanOptions = ['SD', 'SMP', 'SMA', 'Perguruan Tinggi'];

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
        'usia': _dobController.text,  // Use formatted DOB
        'no_telp_wali': _phoneController.text,
        'email': _emailController.text,
        'jenis_kelamin': _gender,
        'jenjang_pendidikan': _selectedJenjangPendidikan,  // Send selected value
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
                  context.pop();
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
                  context.pop();
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

  // Function to show DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default current date
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        // Format selected date as 'dd/MM/yyyy'
        _dobController.text = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
    }
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
              "Tambah Santri",
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
                context.pop();
              },
            ),
          ),
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
                _buildAddressField(_addressController,'Alamat'),
                _buildDateOfBirthField(), // Date of Birth Picker
                _buildDropdownJenjangPendidikan(), // Jenjang Pendidikan Dropdown
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
                _buildPhoneField(), // No WA Wali input with icon on right
                _buildEmailField(), // Email input with icon on right
                SizedBox(height: 20),
                ElevatedButton(
              onPressed: () async {
                      print("Simpan Taped");
                      await _submitForm();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: secondPrimaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                minimumSize: Size(double.infinity, 40),
              ),
              child: Text(
                'Simpan',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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

  // Fungsi untuk input Alamat dengan tipe longtext (area teks lebih besar)
Widget _buildAddressField(TextEditingController controller, String labelText) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(labelText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      SizedBox(height: 8),
      TextFormField(
        controller: _addressController,
        keyboardType: TextInputType.multiline, // Membuka multiline pada keyboard
        maxLines: 3, // Menentukan tinggi area input, bisa lebih panjang jika diperlukan
        autovalidateMode: AutovalidateMode.onUserInteraction, // Validasi otomatis saat input
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Menghilangkan border default
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Harap masukkan Alamat';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
    ],
  );
}


  // Fungsi pembuat TextFormField dengan desain seperti pada ubah_password.dart
  Widget _buildTextFormField(TextEditingController controller, String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          autovalidateMode: AutovalidateMode.onUserInteraction, // Validasi otomatis saat input
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200], // Warna latar belakang lebih terang
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40), // Sudut melengkung
              borderSide: BorderSide.none, // Menghilangkan border default
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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

  // Fungsi untuk input tanggal lahir
  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tanggal Lahir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: _dobController,
              autovalidateMode: AutovalidateMode.onUserInteraction, // Validasi otomatis saat input
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                hintText: 'Pilih Tanggal Lahir',
                suffixIcon: Icon(Icons.calendar_today, color: Colors.grey), // Menambahkan ikon kalender
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harap pilih Tanggal Lahir';
                }
                return null;
              },
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Fungsi untuk dropdown Jenjang Pendidikan
  Widget _buildDropdownJenjangPendidikan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jenjang Pendidikan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedJenjangPendidikan,
          onChanged: (String? newValue) {
            setState(() {
              _selectedJenjangPendidikan = newValue!;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200], // Warna latar belakang lebih terang
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40), // Sudut melengkung
              borderSide: BorderSide.none, // Menghilangkan border default
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          items: jenjangPendidikanOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Harap pilih Jenjang Pendidikan';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Fungsi untuk input No WA Wali dengan tipe nomor dan ikon di kanan
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No WA Wali', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone, // Set keyboard type to phone
          autovalidateMode: AutovalidateMode.onUserInteraction, // Validasi otomatis saat input
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            suffixIcon: Icon(Icons.phone, color: Colors.grey), // Icon for phone number on the right
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Harap masukkan No WA Wali';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Fungsi untuk input Email dengan tipe email dan ikon di kanan
Widget _buildEmailField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      SizedBox(height: 8),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress, // Set keyboard type to email
        autovalidateMode: AutovalidateMode.onUserInteraction, // Validasi otomatis saat input
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          suffixIcon: Icon(Icons.email, color: Colors.grey), // Icon for email on the right
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Harap masukkan Email';
          }
          // Validasi untuk memastikan email berakhiran @gmail.com
          final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
          if (!regex.hasMatch(value)) {
            return 'Harap masukkan @gmail.com';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
    ],
  );
}

}
