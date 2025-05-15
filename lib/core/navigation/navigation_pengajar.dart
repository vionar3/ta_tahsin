
import 'package:flutter/material.dart';
import 'package:ta_tahsin/core/theme.dart';

import '../../view/pengajar/data_santri/data_santri.dart';
import '../../view/pengajar/kemajuan/kemajuan.dart';
import '../../view/pengajar/profile/profile.dart';




class NavigationPengajarPage extends StatefulWidget {
  const NavigationPengajarPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NavigationPengajarPageState createState() => _NavigationPengajarPageState();
}

class _NavigationPengajarPageState extends State<NavigationPengajarPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const KemajuanPage(),
    const DataSantriPage(),
    const PengajarProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: secondPrimaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Kemajuan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Data Santri",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
