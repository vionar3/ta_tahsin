
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/view/home/latihan/latihan.dart';

import '../../view/auth/login/login.dart';
import '../../view/home/latihan/pelafalan_popup.dart';
import '../../view/home/materi/materi.dart';
import '../../view/home/submateri/submateri.dart';
import '../../view/pengajar/data_santri/data_santri.dart';
import '../../view/pengajar/kemajuan/kemajuan.dart';
import '../navigation/navigation.dart';
import '../navigation/navigation_pengajar.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/navigasi',
      builder: (context, state) => const NavigationPage(),
    ),
    GoRoute(
      path: '/navigasiPengajar',
      builder: (context, state) => const NavigationPengajarPage(),
    ),
    GoRoute(
      path: '/materi',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return MateriPage(
          title: extra['title'],
          description: extra['description'],
          subMateri: extra['subMateri'],
        );
      },
    ),
    GoRoute(
      path: '/submateri',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return SubMateriPage(
          title: extra['title'],
          description: extra['description'],
          videoLink: extra['videoLink'],
          intro: extra['intro'],
        );
      },
    ),
    GoRoute(
      path: '/latihan',
      builder: (context, state) => LatihanPage(),
    ),
// GoRoute(
//       path: '/pelafalan',
//       builder: (context, state) {
//         final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
//         return PelafalanPage(

//         );
//       },
//     ),
    GoRoute(
      path: '/pelafalan',
      builder: (context, state) {
        // Ambil data dari state.extra yang dikirim melalui context.go()
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        final int currentStep = extra['currentStep']; // Ambil currentStep

        // Kirim data ke PelafalanPage
        return PelafalanPage(
          currentStep:
              currentStep, // Mengirim currentStep ke halaman PelafalanPage
        );
      },
    ),
    GoRoute(
      path: '/kemajuan',
      builder: (context, state) {
        return const KemajuanPage();  // Halaman untuk pengajar
      },
    ),
    GoRoute(
      path: '/data_santri',
      builder: (context, state) {
        return const DataSantriPage();  // Halaman Data Santri untuk pengajar
      },
    ),
  ],
);
