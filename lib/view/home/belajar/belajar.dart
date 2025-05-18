import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BelajarPage extends StatefulWidget {
  const BelajarPage({super.key});

  @override
  _BelajarPageState createState() => _BelajarPageState();
}

class _BelajarPageState extends State<BelajarPage> {
  List<dynamic> materiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMateri();
  }

  
  Future<void> _fetchMateri() async {
    final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/materi'));

    if (response.statusCode == 200) {
      
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        materiList = data['data']; 
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load materi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Belajar"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() 
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var materi in materiList)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: () {
                              context.go('/materi', extra: {
                                'id': materi['id'],
                                'title': materi['title'],
                                'description': materi['description'],
                                
                              });
                            },
                            child: Center(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  width: 400,
                                  height: 230,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [secondPrimaryColor, Colors.blue],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: Container()),
                                        Text(
                                          materi['title'], 
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: whiteColor,
                                          ),
                                        ),
                                        Text(
                                          materi['subtitle'], 
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: whiteColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
}
