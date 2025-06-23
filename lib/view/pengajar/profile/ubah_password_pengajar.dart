import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordPengajarPage extends StatefulWidget {
  const ChangePasswordPengajarPage({super.key});

  @override
  _ChangePasswordPengajarPageState createState() => _ChangePasswordPengajarPageState();
}

class _ChangePasswordPengajarPageState extends State<ChangePasswordPengajarPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  bool showNewPassword = true;
  bool showConfirmPassword = true;

  // Update visibility for New Password field
  void updateNewPasswordVisibility() {
    setState(() {
      showNewPassword = !showNewPassword;
    });
  }

  // Update visibility for Confirm Password field
  void updateConfirmPasswordVisibility() {
    setState(() {
      showConfirmPassword = !showConfirmPassword;
    });
  }

  Future<void> handleChangePassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');
  debugPrint("Token yang diambil: $authToken");

  // Validasi panjang password minimal 8 karakter
  if (_newPasswordController.text.length < 8) {
    setState(() {
      _errorMessage = 'Password harus minimal 8 karakter';
    });
    return;
  }

  // Validasi jika password baru dan konfirmasi password tidak cocok
  if (_newPasswordController.text != _confirmPasswordController.text) {
    setState(() {
      _errorMessage = 'Password baru dan konfirmasi password tidak cocok';
    });
    return;
  }

  setState(() {
    _errorMessage = null; // Reset error message
  });

  // URL API untuk mengubah password
  String url = '${BaseUrl.baseUrl}/change_password';  // Ganti dengan URL API Anda
  debugPrint("URL yang digunakan: $url");

  // Data yang akan dikirim
  Map<String, dynamic> requestBody = {
    'new_password': _newPasswordController.text,
    'new_password_confirmation': _confirmPasswordController.text,
  };

  debugPrint("Request Body: $requestBody");

  // Kirim request ke API
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json', // Pastikan header ini ada
    },
    body: jsonEncode(requestBody),
  );

  debugPrint("Status code: ${response.statusCode}");
  debugPrint("Response body: ${response.body}");

  if (response.statusCode == 200) {
    // If the password change is successful
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white), // Success icon
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Password berhasil diubah',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green, // Background color for success
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
    ),
  );
  context.pop();
  } else {
    final responseBody = json.decode(response.body);
  setState(() {
    // Displaying error message if available
    _errorMessage = responseBody['message']['new_password']?.first ?? 'Terjadi kesalahan, coba lagi';
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white), // Failure icon
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${json.decode(response.body)['data']['message']}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red, // Background color for failure
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
    ),
  );
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
              "Ubah Password",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password Input Field
            Text(
              'Password Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: showNewPassword,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    showNewPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: updateNewPasswordVisibility,
                ),
                filled: true,
                fillColor: Colors.grey[200], // Lighter background for the field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide.none, // Remove default border
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Confirm Password Input Field
            Text(
              'Konfirmasi Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: showConfirmPassword,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: updateConfirmPasswordVisibility,
                ),
                filled: true,
                fillColor: Colors.grey[200], // Lighter background for the field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide.none, // Remove default border
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Error Message
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 40),
            // Send Button
            ElevatedButton(
              onPressed: () {
            handleChangePassword();
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
                'Selesai',
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
    );
  }
}
