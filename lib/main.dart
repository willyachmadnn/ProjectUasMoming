import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/tabungan_controllers.dart';
import 'firebase_options.dart';
import 'views/login/masuk_views.dart';
import 'views/dashboard/beranda_views.dart';
import 'views/transaksi/transaksi_views.dart';
import 'views/jadwal_pembayaran/jadwal_pembayaran_views.dart';
import 'views/tabungan/tabungan_views.dart';
import 'views/akun/akun_views.dart';
import 'views/login/lupa_password_views.dart';
import 'views/login/daftar_views.dart';
import 'controllers/autentikasi_controllers.dart';
import 'controllers/beranda_controllers.dart';
import 'controllers/transaksi_controllers.dart';
import 'controllers/jadwal_pembayaran_controllers.dart';
import 'controllers/aplikasi_controllers.dart';
import 'services/autentikasi_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await GetStorage.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(
      'Firebase initialization failed: $e. \nPlease update lib/firebase_options.dart with your project keys.',
    );
  }

  await initServices();

  runApp(const MyApp());
}

Future<void> initServices() async {
  final authService = LayananAutentikasiFirebase();
  await authService.init();
  Get.put<LayananAutentikasi>(authService);
  Get.put(KontrolerAplikasi());
  Get.put(KontrolerAutentikasi(Get.find<LayananAutentikasi>()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sakuku',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        cardColor: const Color(0xFFFFFFFF),
        dividerColor: const Color(0xFF64748B).withValues(alpha: 0.2),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF64748B),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF0F172A),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF0F172A)),
          bodyMedium: TextStyle(color: Color(0xFF0F172A)),
          titleLarge: TextStyle(color: Color(0xFF0F172A)),
          titleMedium: TextStyle(color: Color(0xFF0F172A)),
          displayLarge: TextStyle(color: Color(0xFF0F172A)),
          displayMedium: TextStyle(color: Color(0xFF0F172A)),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF0F172A),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        dividerColor: const Color(0xFF94A3B8).withValues(alpha: 0.2),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF94A3B8),
          surface: Color(0xFF1E293B),
          onSurface: Color(0xFFF8FAFC),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFF8FAFC)),
          bodyMedium: TextStyle(color: Color(0xFFF8FAFC)),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Color(0xFFF8FAFC),
        ),
        useMaterial3: true,
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
        GetPage(
          name: '/tabungan',
          page: () => const TampilanTabungan(),
          binding: BindingsBuilder(() {
            Get.put(KontrolerTabungan());
          }),
        ),
        GetPage(name: '/akun', page: () => const TampilanAkun()),
      ],
    );
  }
}
