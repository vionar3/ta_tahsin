import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Pastikan untuk menyesuaikan import theme.dart sesuai lokasi file theme.dart Anda
import 'package:ta_tahsin/core/theme.dart';
import 'package:ta_tahsin/view/pengajar/kemajuan/model/model_data_kemajuan.dart'; // Import kemajuanList

class KemajuanPage extends StatelessWidget {
  const KemajuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kemajuan'),
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

            // Judul Pilih Santri
            Text(
              'Pilih Santri',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:
                    secondPrimaryColor, // Gunakan secondPrimaryColor dari theme.dart
              ),
            ),
            const SizedBox(height: 10),

            // Menggunakan SliverList dengan kemajuanList
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Mengambil data kemajuan dari kemajuanList
                        var kemajuan = kemajuanList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Menampilkan detail subMateri, menggunakan subMateri yang terkait
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 5.0,
                                          ),
                                      leading: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle, // Membuat kontainer berbentuk bulat
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/icon/${kemajuan['image']}',
                                            ), // Gambar asset lokal
                                            fit:
                                                BoxFit
                                                    .cover, // Gambar akan menyesuaikan dengan ukuran kontainer
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              kemajuan['nama'], // Menampilkan nama
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
                                        kemajuan['jilid'], // Menampilkan jilid
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      onTap: () {
                                        context.go('/detail_kemajuan',
                                          extra: {'nama': kemajuan['nama']},
                                        );
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
                      },
                      childCount:
                          kemajuanList
                              .length, // Menyesuaikan jumlah item yang ada pada kemajuanList
                    ),
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
