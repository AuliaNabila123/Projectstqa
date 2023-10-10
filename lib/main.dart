// Mengimpor pustaka Firebase dan pustaka Flutter yang diperlukan
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Mengimpor halaman-halaman yang akan digunakan dalam aplikasi
import 'package:the_bottle/pages/auth_page.dart';
import 'package:the_bottle/firebase_options.dart';
import 'package:the_bottle/pages/home_page.dart';
import 'package:the_bottle/sandbox.dart';
import 'package:the_bottle/theme.dart';

// TODO: Feature: implement notifications

void main() async {
  // Memastikan bahwa Flutter sudah diinisialisasi sebelum digunakan
  WidgetsFlutterBinding.ensureInitialized();
  // Menginisialisasi Firebase dengan opsi dari DefaultFirebaseOptions
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Menjalankan aplikasi utama (Main)
  runApp(const Main());
}

// Kelas Main adalah stateful widget yang merupakan inti dari aplikasi
class Main extends StatefulWidget {
  static const String name = 'Main';

  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    // Membaca perubahan status otentikasi Firebase
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.hasData) {
          if (sandboxEnabled) return const Sandbox();

          // Membaca pengaturan pengguna dari Firebase Firestore
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('User Settings')
                .doc(authSnapshot.data!.email)
                .snapshots(),
            builder: (context, settingsSnapshot) {
              if (settingsSnapshot.hasData) {
                // Membangun aplikasi dengan tema dan halaman utama yang sesuai
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: settingsSnapshot.data?.data()?['darkMode'] ?? false
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: const HomePage(),
                );
              } else {
                // Menampilkan indikator loading jika pengaturan masih dimuat
                return Center(child: CircularProgressIndicator(color: Colors.grey[300]));
              }
            },
          );
        } else {
          // Jika tidak ada status otentikasi, menampilkan halaman otentikasi
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            home: const AuthPage(),
          );
        }
      },
    );
  }
}