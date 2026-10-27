import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart'; // Tambahan untuk notifikasi

void main() async {
  // Wajib ditambahkan jika menjalankan fungsi sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayPal Business',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003087)),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    // Meminta izin notifikasi ke pengguna Android
    _requestNotificationPermission();

    // Mengonfigurasi WebView
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // WAKTU LOGIN: Baris ini memastikan HTML bisa menyimpan data login Anda di HP
      // Secara default di versi terbaru ini sudah aktif, namun penulisan ini memastikan JS berjalan optimal.
      ..loadFlutterAsset('assets/index.html');
  }

  // Fungsi untuk memunculkan pop-up izin notifikasi
  Future<void> _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      debugPrint("Izin notifikasi diberikan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
