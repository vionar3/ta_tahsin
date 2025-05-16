import 'package:flutter/material.dart';
import 'package:ta_tahsin/core/router/route.dart';
import 'package:ta_tahsin/core/theme.dart';
import 'package:ta_tahsin/view/pengajar/data_santri/model/model_data_santri.dart';

class DataSantriPage extends StatelessWidget {
  const DataSantriPage({super.key});

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
            // Search bar
            TextField(
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
            // Tombol + untuk menambah data santri
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Tindakan ketika tombol + diklik
                        print("Menambahkan data santri...");
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ), // Ikon dengan warna putih
                      label: const Text(
                        'Tambah',
                        style: TextStyle(
                          color: Colors.white,
                        ), // Teks dengan warna putih
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            secondPrimaryColor, // Warna latar belakang tombol
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
                    TextButton.icon(
                      onPressed: () {
                        // Tindakan untuk impor
                      },
                      icon: const Icon(
                        Icons.import_export,
                        color: Colors.white,
                      ), // Ikon dengan warna putih
                      label: const Text(
                        'Import',
                        style: TextStyle(
                          color: Colors.white,
                        ), // Teks dengan warna putih
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            secondPrimaryColor, // Warna latar belakang tombol
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
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Judul Pilih Santri
            Text(
              'Pilih Santri',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: secondPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),

            // Menggunakan SliverList dengan santriList
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      var santri = santriList[index];

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
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 5.0,
                                    ),
                                    leading: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/icon/${santri['image']}',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            santri['nama'],
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
                                      santri['jilid'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onTap: () {
                                      // context.go('/detail_kemajuan', extra: {'nama': santri['nama']});
                                      router.push("/detail_user"); 
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
                    }, childCount: santriList.length),
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
