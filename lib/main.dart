import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Views
import 'views/login/masuk_views.dart';
import 'views/dashboard/beranda_views.dart';
import 'views/transaksi/transaksi_views.dart';
import 'views/jadwal_pembayaran/jadwal_pembayaran_views.dart';
import 'views/tabungan/tabungan_views.dart';
import 'views/akun/akun_views.dart';

// Controllers
import 'controllers/autentikasi_controllers.dart';
import 'controllers/beranda_controllers.dart';
import 'controllers/transaksi_controllers.dart';
import 'controllers/jadwal_pembayaran_controllers.dart';
import 'controllers/aplikasi_controllers.dart';

// Services
import 'services/autentikasi_services.dart';
import 'views/login/lupa_password_views.dart';
import 'views/login/daftar_views.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Date Formatting
  await initializeDateFormatting('id_ID', null);

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(
      'Firebase initialization failed: $e. \nPlease update lib/firebase_options.dart with your project keys.',
    );
  }

  // Initialize Services & Controllers
  await initServices();

  runApp(const MyApp());
}

Future<void> initServices() async {
  // Services
  // Initialize Firebase Auth Service
  final authService = LayananAutentikasiFirebase();
  await authService.init();
  Get.put<LayananAutentikasi>(authService);

  // Controllers
  Get.put(KontrolerAplikasi());
  // Inject KontrolerAutentikasi with the service instance
  Get.put(KontrolerAutentikasi(Get.find<LayananAutentikasi>()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sakukuber',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.white,
        dividerColor: Colors.grey[200],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: Colors.grey[800],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.light,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => TampilanMasuk()),
        GetPage(name: '/daftar', page: () => TampilanDaftar()),
        GetPage(name: '/lupa_password', page: () => TampilanLupaPassword()),
        GetPage(
          name: '/dashboard',
          page: () => const TampilanBeranda(),
          binding: BindingsBuilder(() {
            Get.put(KontrolerBeranda());
            Get.put(KontrolerTransaksi());
            Get.put(KontrolerJadwalPembayaran());
          }),
        ),
        GetPage(
          name: '/transaksi',
          page: () => const TampilanTransaksi(),
          binding: BindingsBuilder(() {
            Get.put(KontrolerTransaksi());
          }),
        ),
        GetPage(
          name: '/jadwal',
          page: () => const TampilanJadwalPembayaran(),
          binding: BindingsBuilder(() {
            Get.put(KontrolerJadwalPembayaran());
          }),
        ),
        GetPage(name: '/tabungan', page: () => const TampilanTabungan()),
        GetPage(name: '/akun', page: () => const TampilanAkun()),
      ],
    );
  }
}
