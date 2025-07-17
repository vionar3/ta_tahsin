import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/sized/sized.dart';
import 'package:ta_tahsin/core/theme.dart';

import '../../../core/router/route.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPass = true;
  bool isLoading = false; // Menambahkan variabel untuk status loading
  bool isEmailEmpty = false; // Validasi untuk email
  bool isPasswordEmpty = false; // Validasi untuk password

  void updateObsecure() {
    setState(() {
      showPass = !showPass;
    });
  }

  Future<void> login() async {
    setState(() {
      isEmailEmpty = emailController.text.isEmpty;
      isPasswordEmpty = passwordController.text.isEmpty;
    });

    // Cek jika ada input yang kosong
    if (isEmailEmpty || isPasswordEmpty) {
      return; // Jika ada input yang kosong, hentikan proses login
    }

    setState(() {
      isLoading = true; // Menandakan bahwa login sedang diproses
    });

    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/loginWithTelp'),
      body: {
        'no_telp_wali': emailController.text,
        'password': passwordController.text,
      },
    );

    setState(() {
      isLoading = false; // Menandakan bahwa login telah selesai
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['data']['access_token']);

      String peran = data['data']['user']['peran'];
      prefs.setString('peran', peran);

      // Simpan user_id ke dalam SharedPreferences
      int userId = data['data']['user']['id'];
      prefs.setInt('user_id', userId);  // Menyimpan user_id sebagai integer

      if (peran == 'santri') {
        router.push("/navigasi");
      } else if (peran == 'pengajar') {
        router.push("/navigasiPengajar");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(Icons.error, color: Colors.white), // Menambahkan ikon error
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${json.decode(response.body)['data']['message']}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
    backgroundColor: alertTextColor, // Mengubah warna latar belakang menjadi merah
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10), // Menambahkan radius hanya di atas kiri
        topRight: Radius.circular(10), // Menambahkan radius hanya di atas kanan
        bottomLeft: Radius.zero, // Tidak ada radius di bawah kiri
        bottomRight: Radius.zero, // Tidak ada radius di bawah kanan
      ),
    ),
  ),
);
    }
  }

  void showErrorBottomSheet(BuildContext context, String message) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Menjadikan background transparan
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red, // Mengubah warna latar belakang menjadi merah
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.white), // Menambahkan ikon error
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message, // Menampilkan pesan error
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top half: Background image
          Container(
            height: MediaQuery.of(context).size.height * 0.5, // Half the screen height
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/muhajirin4.jpg'), // Your image
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Bottom half: Form section
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              color: Colors.white, // White background for the form
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "No Telp",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: emailController,  // Ubah menjadi controller untuk no_telp jika diperlukan
                      keyboardType: TextInputType.phone,  // Gunakan TextInputType.phone untuk nomor telepon
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.phone,  // Ganti icon dengan ikon telepon
                          color: Colors.grey,
                        ),
                        hintText: "Masukkan No. Telepon",  // Ubah hint text sesuai kebutuhan
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: isEmailEmpty ? 'No Telepon tidak boleh kosong' : null, // Menambahkan pesan error
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isEmailEmpty ? Colors.red : Colors.blue), // Ganti warna border saat error
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Text(
                      "Password",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: passwordController,
                      obscureText: showPass,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        hintText: "Masukkan Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPass ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: updateObsecure,
                        ),
                        errorText: isPasswordEmpty ? 'Password tidak boleh kosong' : null, // Menambahkan pesan error
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isPasswordEmpty ? Colors.red : Colors.blue), // Ganti warna border saat error
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () { // Disable button saat loading
                          login();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondPrimaryColor,
                          foregroundColor: whiteColor,
                          padding: PaddingCustom().paddingVertical(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading 
                            ? CircularProgressIndicator(color: whiteColor) // Menampilkan indikator loading
                            : const Text("Masuk"), // Menampilkan teks "Masuk" ketika tidak loading
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
