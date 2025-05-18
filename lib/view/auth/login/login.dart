import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void updateObsecure() {
    setState(() {
      showPass = !showPass;
    });
  }

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/login'),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['data']['access_token']);

     
      String peran = data['data']['user']['peran'];

      
      if (peran == 'santri') {
        router.push("/navigasi"); 
      } else if (peran == 'pengajar') {
        router.push("/navigasiPengajar"); 
      }
    } else {
    debugPrint("anjing");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: PaddingCustom().paddingHorizontal(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Selamat Datang,",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: bold,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Masuk Untuk Melanjutkan",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Center(child: Image.asset('assets/logo/sho.jpg', height: 180)),
                const SizedBox(height: 20),
                const Text(
                  "No Telp",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress, 
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.grey,
                    ), 
                    hintText:
                        "Masukkan Email", 
                    border: OutlineInputBorder(
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
                    hintText: "Enter your password",
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
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      
                    },
                    child: Text(
                      "Lupa password?",
                      style: TextStyle(color: secondPrimaryColor, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
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
                    child: const Text("Masuk"),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}