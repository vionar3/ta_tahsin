
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_tahsin/view/auth/changePass/ubah_password.dart';
import 'package:ta_tahsin/view/home/latihan/latihan.dart';
import 'package:ta_tahsin/view/home/profile/edit_profile.dart';
import 'package:ta_tahsin/view/home/progres/progres.dart';
import 'package:ta_tahsin/view/home/quiz/detail_quiz.dart';
import 'package:ta_tahsin/view/home/quiz/hasil_quiz.dart';
import 'package:ta_tahsin/view/pengajar/data_latihan/detail_data_latihan.dart';
import 'package:ta_tahsin/view/pengajar/data_santri/detail_data_santri.dart';
import 'package:ta_tahsin/view/pengajar/data_santri/tambah_santri.dart';
import 'package:ta_tahsin/view/pengajar/kemajuan/detail_kemajuan.dart';
import 'package:ta_tahsin/view/pengajar/profile/edit_profile_pengajar.dart';
import 'package:ta_tahsin/view/pengajar/profile/ubah_password_pengajar.dart';

import '../../view/auth/login/login.dart';
import '../../view/home/latihan/pelafalan_popup.dart';
import '../../view/home/materi/materi.dart';
import '../../view/home/submateri/submateri.dart';
import '../../view/pengajar/data_santri/data_santri.dart';
import '../../view/pengajar/kemajuan/kemajuan.dart';
import '../navigation/navigation.dart';
import '../navigation/navigation_pengajar.dart';

final router = GoRouter(
  // initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
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
          id: extra['id'],
          title: extra['title'],
          description: extra['description'],
        );
      },
    ),
    GoRoute(
      path: '/submateri',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return SubMateriPage(
          id: extra['id'],
          title: extra['title'],
          description: extra['description'],
          videoLink: extra['videoLink'],
          intro: extra['intro'],
        );
      },
    ),
    // Rute untuk halaman Latihan
GoRoute(
  path: '/latihan',
  builder: (BuildContext context, GoRouterState state) {
    final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
    return LatihanPage(
      id: extra['id'],
      currentStep: extra['currentStep'] ?? 0, // Menambahkan parameter currentStep
    );
  },
),

// Rute untuk halaman Pelafalan
GoRoute(
  path: '/pelafalan',
  builder: (context, state) {
    final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
    final int currentStep = extra['currentStep'];
    final List<dynamic> latihanData = extra['latihanData'];
    final String recordedFilePath = extra['recordedFilePath']; 

    return PelafalanPage(
      id: extra['id'],
      currentStep: currentStep,
      latihanData: latihanData,
      recordedFilePath: recordedFilePath, 
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
  path: '/detail_kemajuan',
  builder: (BuildContext context, GoRouterState state) {
    final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;

    // Mengambil data yang diteruskan (nama dan user_id)
    final String nama = extra['nama'];
    final int userId = extra['user_id'];

    // Mengirimkan data ke halaman DetailKemajuanPage
    return DetailKemajuanPage(
      nama: nama,
      userId: userId,
    );
  },
),

    GoRoute(
      path: '/data_santri',
      builder: (context, state) {
        return const DataSantriPage();  // Halaman Data Santri untuk pengajar
      },
    ),
    GoRoute(
      path: '/detail_user',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return DetailDataSantriPage(
          id: extra['id'],
        );
      },
    ),
    GoRoute(
      path: '/tambah_santri',
      builder: (context, state) {
        return TambahSantriPage();  // Halaman Data Santri untuk pengajar
      },
    ),
    GoRoute(
      path: '/detail_data_latihan',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return DetailDataLatihanPage(
          id: extra['id'],
        );
      },
    ),
    GoRoute(
      path: '/detail_quiz',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return DetailQuizPage(
          id: extra['id'],
          title: extra['title'],
        );
      },
    ),
    GoRoute(
      path: '/hasil_quiz',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return HasilQuizPage(
          totalScore: extra['totalScore'],
          title: extra['title'],
        );
      },
    ),
    GoRoute(
      path: '/progres_belajar',
      builder: (BuildContext context, GoRouterState state) {
        return ProgresBelajarPage(
        );
      },
    ),
    GoRoute(
      path: '/ubah_password',
      builder: (BuildContext context, GoRouterState state) {
        return ChangePasswordPage(
        );
      },
    ),
    GoRoute(
      path: '/ubah_password_pengajar',
      builder: (BuildContext context, GoRouterState state) {
        return ChangePasswordPengajarPage(
        );
      },
    ),
    GoRoute(
      path: '/edit_profile',
      builder: (BuildContext context, GoRouterState state) {
        return EditProfile(
        );
      },
    ),
    GoRoute(
      path: '/edit_profile_pengajar',
      builder: (BuildContext context, GoRouterState state) {
        return EditProfilePengajar(
        );
      },
    ),
  ],
);
