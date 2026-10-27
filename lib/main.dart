import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

// 1. Fungsi Utama untuk menjalankan aplikasi
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Masukkan URL dan Key Supabase Anda di sini
  await Supabase.initialize(
    url: 'https://heaedfjyjpfvpddtgjhk.supabase.co',
    anonKey: 'sb_publishable_uuIu1DiiNhS4aHc3ZSxqrg_F4punPvO',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Cangkang',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const DynamicLoaderScreen(), // Memanggil layar loading
    );
  }
}

// 2. Halaman Loading & Pengambil Data
class DynamicLoaderScreen extends StatefulWidget {
  const DynamicLoaderScreen({super.key});

  @override
  State<DynamicLoaderScreen> createState() => _DynamicLoaderScreenState();
}

class _DynamicLoaderScreenState extends State<DynamicLoaderScreen> {
  String statusText = "Menghubungkan ke server...";
  bool isError = false;
  late final WebViewController _controller;
  bool isHtmlLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted); // Mengizinkan script berjalan
    _loadAppContent();
  }

  // 3. Fungsi Menarik Data dari Supabase
  Future<void> _loadAppContent() async {
    try {
      setState(() {
        statusText = "Mengunduh tampilan terbaru...";
      });

      // Mengambil data dari tabel app_settings (id = 1)
      final data = await Supabase.instance.client
          .from('app_settings')
          .select('html_content')
          .eq('id', 1)
          .single();

      if (data['html_content'] != null) {
        // Jika data HTML ada, masukkan ke dalam WebView
        _controller.loadHtmlString(data['html_content'] as String);
        setState(() {
          isHtmlLoaded = true; // Beri tahu aplikasi untuk mengubah layar ke WebView
        });
      } else {
        setState(() {
          statusText = "Tampilan belum diatur di Admin Kontrol.";
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        statusText = "Gagal terhubung: \n$e";
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika HTML berhasil diunduh, tampilkan WebView (Tampilan Asli Aplikasi)
    if (isHtmlLoaded) {
      return Scaffold(
        body: SafeArea(
          child: WebViewWidget(controller: _controller),
        ),
      );
    }

    // Jika belum berhasil, tampilkan layar Loading / Ruang Tunggu
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Warna biru gelap (Slate 900)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isError)
              const CircularProgressIndicator(color: Colors.blue), // Animasi putar
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isError ? Colors.redAccent : Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}