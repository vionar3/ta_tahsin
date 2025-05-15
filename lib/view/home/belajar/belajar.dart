
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/core/theme.dart';

import '../materi/model/model_data_materi.dart';

class BelajarPage extends StatelessWidget {
  const BelajarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Belajar"),
        automaticallyImplyLeading: false,
      ),
      
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                for (var materi in materiList)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        context.go('/materi', extra: {
                          'title': materi['title'],
                          'description': materi['description'],
                          'subMateri': materi['subMateri'],
                        });
                      },
                      child: Center(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: Container(
                            width: 400,
                            height: 230,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  secondPrimaryColor,
                                  Colors.blue
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child:
                                        Container(),
                                  ),
                                  Text(
                                    materi['title'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: whiteColor,
                                    ),
                                  ),
                                  Text(
                                    materi['arti'],
                                    style:  TextStyle(
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
