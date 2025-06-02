import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_tahsin/core/baseurl/base_url.dart';
import 'package:ta_tahsin/core/router/route.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:file_picker/file_picker.dart';

class DataSantriPage extends StatefulWidget {
  const DataSantriPage({super.key});

  @override
  _DataSantriPageState createState() => _DataSantriPageState();
}

class _DataSantriPageState extends State<DataSantriPage> {
  List<dynamic> santriList = [];
  List<dynamic> filteredSantriList = [];  
  String searchQuery = "";  
  bool isLoading = true;
  File? file;  

  @override
  void initState() {
    super.initState();
    fetchSantriData();
  }

  Future<void> fetchSantriData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    debugPrint("Token yang diambil: $authToken");

    if (authToken == null) {
      print("Token tidak ditemukan!");
      return;
    }

    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/users/santri'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        santriList = data['data'];
        filteredSantriList = santriList;  
        isLoading = false;  
      });
    } else {
      throw Exception('Gagal memuat data santri');
    }
  }

  
  void filterSantri(String query) {
    final filtered = santriList.where((santri) {
      final nama = santri['nama_lengkap'].toLowerCase();
      final search = query.toLowerCase();
      return nama.contains(search);
    }).toList();

    setState(() {
      filteredSantriList = filtered;
    });
  }

 

  // // Function to handle the file import
  // void onTapImportFile() async {
  //   List<String> fileExt = ["xls", "xlsx"];
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     allowedExtensions: fileExt,
  //     type: FileType.custom,
  //   );
    
  //   try {
  //     if (result != null) {
  //       File file = File(result.files.single.path!);
  //       var bytes = await file.readAsBytes();
        
  //       var excel = Excel.decodeBytes(bytes);
  //       var sheet = excel.tables[excel.tables.keys.first];
  //       if (sheet != null) {
  //         List<Map<String, dynamic>> santriData = [];

  //         // Loop through rows and create the data
  //         for (var row in sheet.rows) {
  //           if (row.isNotEmpty) {
  //             Map<String, dynamic> santri = {
  //               'nama_lengkap': row[0]?.toString(),
  //               'alamat': row[1]?.toString(),
  //               'usia': row[2]?.toString(),
  //               'no_telp_wali': row[3]?.toString(),
  //               'email': row[4]?.toString(),
  //               'jenis_kelamin': row[5]?.toString(),
  //               'jenjang_pendidikan': row[6]?.toString(),
  //             };
  //             santriData.add(santri);
  //           }
  //         }
  //         // Call API to send this data
  //         // await sendSantriData(santriData);
  //       }
  //           }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

//   Future<void> sendSantriData(List<Map<String, dynamic>> santriData) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? authToken = prefs.getString('token');

//   if (authToken == null) {
//     print("Token tidak ditemukan!");  // Debugging log
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Token tidak ditemukan!')),
//     );
//     return;
//   }

//   setState(() {
//     isLoading = true;
//   });

//   try {
//     final response = await http.post(
//       Uri.parse('${BaseUrl.baseUrl}/importSantri'),
//       headers: {
//         'Authorization': 'Bearer $authToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({'santri': santriData}),
//     );

//     setState(() {
//       isLoading = false;
//     });

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Santri data imported successfully')),
//       );
//     } else {
//       var errorData = jsonDecode(response.body);
//       print("Error data: ${errorData.toString()}");  // Debugging log

//       String errorMessage = errorData['meta']['message'] ?? 'Failed to import data';

//       if (errorData['meta']['status'] == 'error') {
//         String validationErrors = '';
//         if (errorData['data'] != null) {
//           var errors = errorData['data'];
//           validationErrors = errors.toString();
//         }

//         // Show specific error message in SnackBar
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $errorMessage $validationErrors')),
//         );
//       }
//     }
//   } catch (e) {
//     setState(() {
//       isLoading = false;
//     });

//     // Handle any other exception (e.g., network error)
//     print("Exception: $e");  // Debugging log
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to import data: $e')),
//     );
//   }
// }


  // Send the parsed Santri data to the API
  // Future<void> sendSantriData(List<Map<String, dynamic>> santriData) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? authToken = prefs.getString('token');

  //   if (authToken == null) {
  //     print("Token tidak ditemukan!");
  //     return;
  //   }

  //   setState(() {
  //     isLoading = true;
  //   });

  //   final response = await http.post(
  //     Uri.parse('${BaseUrl.baseUrl}/importSantri'),
  //     headers: {
  //       'Authorization': 'Bearer $authToken',
  //     },
  //     body: jsonEncode({'santri': santriData}),
  //   );

  //   setState(() {
  //     isLoading = false;
  //   });

  //   if (response.statusCode == 200) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Santri data imported successfully')),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to import data')),
  //     );
  //   }
  // }

// void onTapImportFile() async {
//     List<String> fileExt = ["xls", "xlsx"];
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowedExtensions: fileExt,
//       type: FileType.custom,
//     );
//     try {
//       if (result != null) {
//         file = File(result.files.single.path!);
//         setState(() {});
//       }
//     } catch (e) {
//       log(e.toString() as num);
//     }
//   }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Santri'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            TextField(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  filterSantri(searchQuery);  
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari Santri...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: secondPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        context.go('/tambah_santri');
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Tambah',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: secondPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // TextButton.icon(
                    //   onPressed: () {
                    //     onTapImportFile();
                    //   },
                    //   icon: const Icon(
                    //     Icons.import_export,
                    //     color: Colors.white,
                    //   ),
                    //   label: const Text(
                    //     'Import',
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    //   style: TextButton.styleFrom(
                    //     backgroundColor: secondPrimaryColor,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 12,
                    //     ),
                    //     textStyle: const TextStyle(fontSize: 16),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih Santri',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: secondPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())  
                  : filteredSantriList.isEmpty
                      ? Center(child: Text('Data tidak ditemukan'))  
                      : CustomScrollView(
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate((context, index) {
                                var santri = filteredSantriList[index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                                              leading: Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                      'assets/icon/defaultprofile.jpeg',
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      santri['nama_lengkap'],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Text(
                                                santri['email'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              onTap: () {
                                                context.go('/detail_user', extra: {
                                'id': santri['id'],
                              });
                                                // router.push("/detail_user");  
                                              },
                                            ),
                                            Divider(
                                              color: Colors.grey.withOpacity(0.5),
                                              thickness: 1,
                                              indent: 80,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }, childCount: filteredSantriList.length),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
